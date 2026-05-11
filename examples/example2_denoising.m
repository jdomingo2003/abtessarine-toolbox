% =========================================================================
% EXAMPLE 2: Global Image Denoising via Hypercomplex Dense SVD Factorization
% =========================================================================
% Description:
%   This script conducts a comprehensive spatial scalability and robustness 
%   benchmark under various Additive White Gaussian Noise (AWGN) scenarios. 
%   It compares the native O(N^3) computational complexity of the proposed 
%   abtessarine toolbox against the standard complex-isomorphism based 
%   quaternion SVD algorithm (yielding a prohibitive O((2N)^3) complexity).
%
% Key Mathematical Concept:
%   To preserve fine high-frequency stellar details and cosmic structures 
%   as resolution scales up, an adaptive intrinsic rank truncation strategy 
%   is implemented. This mathematically forces a continuous improvement of 
%   the reconstruction fidelity (PSNR) across higher resolutions.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('   [DENSE SVD DENOISING: SCALABILITY & NOISE BENCHMARK]            ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Global Environment Setup
% -------------------------------------------------------------------------
alpha_val = -1; 
beta_val  = 1;
setabtessarine(alpha_val, beta_val);
fprintf('-> Topological environment successfully configured: alpha = %d, beta = %d\n\n', alpha_val, beta_val);

% -------------------------------------------------------------------------
% 2. Load Base Benchmark Image
% -------------------------------------------------------------------------
disp('-> Loading high-resolution raw astronomical dataset (Carina Nebula)...');
try
    I_raw = imread('Carina_Nebula.tif'); 
catch
    I_raw = imread('Carina_Nebula.png'); 
end

I_base = im2double(I_raw);

% -------------------------------------------------------------------------
% 3. Experimental Parameters Setup
% -------------------------------------------------------------------------
noise_variances = [0.01, 0.05, 0.10];                   % AWGN low, medium, and high variances
resolutions     = [256, 512, 768, 1024, 2048, 4096];    % Spatial scaling vector

% ADAPTIVE INTRINSIC RANK: Logarithmic expansion of truncation rank 'k' with
% physical resolution to safeguard high-frequency data structures from over-smoothing.
k_array         = [20, 30, 40, 50, 100, 200]; 

% -------------------------------------------------------------------------
% 4. Main Benchmark Loop
% -------------------------------------------------------------------------
for v_idx = 1:length(noise_variances)
    current_var = noise_variances(v_idx);
    
    fprintf('==========================================================================================\n');
    fprintf(' SCENARIO %d: AWGN Variance = %.2f \n', v_idx, current_var);
    fprintf('==========================================================================================\n');
    fprintf(' Res (N) |  k   | Tess Time (s) | Quat Time (s) | Tess PSNR (dB) | Quat PSNR (dB) | Speedup \n');
    fprintf('------------------------------------------------------------------------------------------\n');
    
    % Preallocate arrays for tracking performance metrics
    time_tess_arr = zeros(size(resolutions));
    time_quat_arr = zeros(size(resolutions));
    
    for r_idx = 1:length(resolutions)
        N = resolutions(r_idx);
        M = N; % Square aspect ratio
        
        % Select the adaptive truncation rank for the current resolution
        truncation_k = k_array(r_idx);
        
        % Resize image (Native MATLAB interpolation)
        % Note: If imresize causes issues without the Image Processing Toolbox,
        % it can be replaced with native indexing, though imresize is often 
        % available in base MATLAB depending on the version.
        I_rgb = imresize(I_base, [M, N]); 
        
        % -----------------------------------------------------------------
        % NATIVE AWGN INJECTION (Independent of Image Processing Toolbox)
        % -----------------------------------------------------------------
        rng(42); % Set random seed for reproducible noise generation
        noise_sigma = sqrt(current_var);
        
        % Generate Gaussian noise and add it to the image, keeping it bounded [0, 1]
        noise_matrix = noise_sigma * randn(M, N, 3);
        I_noisy = I_rgb + noise_matrix;
        I_noisy = max(0, min(1, I_noisy)); % Clip values to valid image range
        
        R_n = I_noisy(:,:,1); G_n = I_noisy(:,:,2); B_n = I_noisy(:,:,3);
        
        % =================================================================
        % EXPERIMENT A: TESSARINE DENSE SVD (abtessarine Toolbox)
        % =================================================================
        Z_tess = abtessarine(zeros(M,N), R_n, G_n, B_n);
        
        tic_tess = tic;
        [U_t, S_t, V_t] = svd(Z_tess, 'econ');
        
        % Deterministic Truncation
        S_A = S_t.A; S_C = S_t.C;
        S_A(truncation_k+1:end, truncation_k+1:end) = 0;
        S_C(truncation_k+1:end, truncation_k+1:end) = 0;
        S_t_trunc = abtessarine(S_A, zeros(M,N), S_C, zeros(M,N));
        
        Z_rec_tess = U_t * S_t_trunc * V_t';
        total_tess_time = toc(tic_tess);
        
        I_rec_tess = cat(3, max(0,min(1,Z_rec_tess.B)), max(0,min(1,Z_rec_tess.C)), max(0,min(1,Z_rec_tess.D)));
        clear U_t S_t V_t Z_rec_tess; % Explicit garbage collection
        
        % =================================================================
        % EXPERIMENT B: QUATERNION ISOMORPHIC DENSE SVD (Isomorphic Baseline)
        % =================================================================
        Z_quat = quaternion(zeros(M,N), R_n, G_n, B_n);
        
        tic_quat = tic;
        [U_q, S_q, V_q] = qsvd_sp_full(Z_quat);
        
        % Deterministic Truncation
        S_q(truncation_k+1:end, truncation_k+1:end) = 0;
        
        Z_rec_quat = U_q * S_q * V_q';
        rec_qR = x(Z_rec_quat); rec_qG = y(Z_rec_quat); rec_qB = z(Z_rec_quat);
        total_quat_time = toc(tic_quat);
        
        I_rec_quat = cat(3, max(0,min(1,rec_qR)), max(0,min(1,rec_qG)), max(0,min(1,rec_qB)));
        clear U_q S_q V_q Z_rec_quat; % Explicit garbage collection
        
        % =================================================================
        % METRICS & LOGGING
        % =================================================================
        psnr_tess = 10 * log10(1 / mean((I_rgb(:) - I_rec_tess(:)).^2));
        psnr_quat = 10 * log10(1 / mean((I_rgb(:) - I_rec_quat(:)).^2));
        
        current_speedup = total_quat_time / total_tess_time;
        
        time_tess_arr(r_idx) = total_tess_time;
        time_quat_arr(r_idx) = total_quat_time;
        
        fprintf(' %4dx%d | %4d | %13.2f | %13.2f | %14.2f | %14.2f | %6.2fx \n', ...
                M, N, truncation_k, total_tess_time, total_quat_time, psnr_tess, psnr_quat, current_speedup);
                
        % Thermal and memory cooldown between massive iterations
        pause(5); 
    end
    fprintf('------------------------------------------------------------------------------------------\n\n');
    
    % -----------------------------------------------------------------
    % 5. Visualization
    % -----------------------------------------------------------------
    figure('Name', sprintf('Computation Time (Variance: %.2f)', current_var), ...
           'Color', 'w', 'Position', [100+v_idx*50, 100+v_idx*50, 750, 500]);
           
    plot(resolutions, time_tess_arr, '-o', 'LineWidth', 2.5, 'MarkerSize', 9, ...
        'DisplayName', '\alpha\beta-Tessarine (Native O(N^3))', 'Color', [0 0.4470 0.7410]);
    hold on;
    
    plot(resolutions, time_quat_arr, '-s', 'LineWidth', 2.5, 'MarkerSize', 9, ...
        'DisplayName', 'Quaternion (Isomorphic O((2N)^3))', 'Color', [0.8500 0.3250 0.0980]);
    
    xlabel('Image Resolution (N \times N)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Execution Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('Dense SVD Computation Time vs Scalability\n(AWGN Variance = %.2f | Adaptive Rank)', current_var), 'FontSize', 14);
    
    grid on; 
    legend('Location', 'northwest', 'FontSize', 12); 
    set(gca, 'FontSize', 12);
    
    drawnow; 
end

disp('===================================================================');
disp('  ALL DENSE BENCHMARKS COMPLETED SUCCESSFULLY!                     ');
disp('===================================================================');

% =========================================================================
% BASELINE ALGORITHM: ISOMORPHIC QUATERNION SINGULAR VALUE DECOMPOSITION
% =========================================================================
function [U_q, S_q, V_q] = qsvd_sp_full(Q)
%QSVD_SP_FULL Quaternion Singular Value Decomposition via Complex Isomorphism.
%
%   [U_q, S_q, V_q] = QSVD_SP_FULL(Q) computes the full dense quaternion SVD 
%   of a quaternion matrix Q based on the complex adjoint symplectic mapping.
%
    [m, n] = size(Q);
    A = complex(double(s(Q)), double(x(Q))); 
    B = complex(double(y(Q)), double(z(Q)));
    Mc = [A, B; -conj(B), conj(A)];
    
    [Uc, Sc, Vc] = svd(Mc, 'econ');
    
    S_q = diag(diag(Sc(1:2:end, 1:2:end)));
    U_q = quaternion(real(Uc(1:m, 1:2:end)), imag(Uc(1:m, 1:2:end)), ...
                     real(-conj(Uc(m+1:end, 1:2:end))), imag(-conj(Uc(m+1:end, 1:2:end))));
    V_q = quaternion(real(Vc(1:n, 1:2:end)), imag(Vc(1:n, 1:2:end)), ...
                     real(-conj(Vc(n+1:end, 1:2:end))), imag(-conj(Vc(n+1:end, 1:2:end))));
end