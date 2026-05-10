% =========================================================================
% EXAMPLE 1, Experiment II:
%       Color Image In-painting via Hypercomplex Truncated SVD 
%       (Algorithmic Stabilization on High-Frequency Textures)
% =========================================================================
% Description:
%   This script analyzes the stabilization behavior and computational plateaus 
%   of iterative hypercomplex SVD solvers at high truncation ranks (k >= 150)
%   using a highly textured dataset. It evaluates multiple missing-data 
%   saturation scenarios to demonstrate the efficiency of the proposed 
%   commutative 'abtessarine' toolbox over the quaternion isomorphic 
%   alternative (qsvds_sp).
%
% Reference:
%   Section 3.2.4: "Experiment II: Algorithmic Stabilization on High-Frequency 
%   Textures".
%
% Key Mathematical Concept:
%   When k reaches a high fraction of the matrix dimensions, truncated solvers 
%   (svds) dynamically trigger transitions to full LAPACK operations. Because of 
%   its compact native dimensions, the abtessarine toolbox safely undergoes 
%   this dense stabilization without incurring out-of-memory overheads, 
%   successfully bounding computation times.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  [SVT IN-PAINTING BENCHMARK: ALGORITHMIC STABILIZATION]          ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Global Environment Setup
% -------------------------------------------------------------------------
% Configured to the benchmark environment: alpha = -1, beta = 1.5
alpha_val = -1;
beta_val  = 1.5;
setabtessarine(alpha_val, beta_val);
fprintf('-> Topological environment successfully configured: alpha = %.1f, beta = %.1f\n\n', alpha_val, beta_val);

% -------------------------------------------------------------------------
% 2. Load Textured High-Resolution Image (No Resizing)
% -------------------------------------------------------------------------
disp('-> Loading native full-resolution high-frequency image (Autumn Forest)...');
try
    I_raw = imread('Autumn_Forest.jpg'); 
catch
    I_raw = imread('Autumn_Forest.png'); 
end

% The image is strictly kept at its native massive resolution.
I_rgb = im2double(I_raw); 
[M, N, ~] = size(I_rgb);
fprintf('   Native test resolution: %d x %d\n', M, N);
fprintf('   Quaternion Isomorphic Matrix size: %d x %d\n\n', 2*M, 2*N);

% -------------------------------------------------------------------------
% 3. Experimental Parameters Setup
% -------------------------------------------------------------------------
% Missing data scenarios (5%, 10%, and 20% saturation rates)
missing_rates = [0.05, 0.10, 0.20]; 

% Adaptive iterations mapped to the damage level to prevent structural overfitting
iters_array   = [5, 10, 15]; 

% High truncation ranks used to observe solver heuristics and the plateau effect
rank_ks       = [20, 50, 100, 150, 350]; 

R = I_rgb(:,:,1); G = I_rgb(:,:,2); B = I_rgb(:,:,3);

% -------------------------------------------------------------------------
% 4. Main Benchmark Loop
% -------------------------------------------------------------------------
for scenario = 1:length(missing_rates)
    current_missing = missing_rates(scenario);
    current_iters   = iters_array(scenario);
    
    fprintf('==========================================================================================\n');
    fprintf(' EXPERIMENT %d: Missing Rate = %.0f%% | Adaptive Iterations = %d\n', scenario, current_missing*100, current_iters);
    fprintf('==========================================================================================\n');
    
    rng(42); % Set random seed for reproducible masking across runs
    Mask = rand(M, N) > current_missing; 
    
    % Arrays for tracking performance metrics
    time_tess_arr = zeros(size(rank_ks));
    time_quat_arr = zeros(size(rank_ks));
    speedup_arr   = zeros(size(rank_ks));
    
    fprintf('  k   | Tess Time (s) | Quat Time (s) | Tess PSNR (dB) | Quat PSNR (dB) | Speedup \n');
    fprintf('------------------------------------------------------------------------------------------\n');
    
    for idx = 1:length(rank_ks)
        rank_k = rank_ks(idx);
        
        % =================================================================
        % EXPERIMENT A: TESSARINE APPROACH (Native Dimensions)
        % =================================================================
        Z_orig_tess = abtessarine(zeros(M,N), R, G, B);
        Z_rec_tess = Z_orig_tess;
        Z_rec_tess.B = Z_rec_tess.B .* Mask;
        Z_rec_tess.C = Z_rec_tess.C .* Mask;
        Z_rec_tess.D = Z_rec_tess.D .* Mask;
        
        tic_tess = tic; 
        for iter = 1:current_iters
            [U_k, S_k, V_k] = svds(Z_rec_tess, rank_k);
            Z_low = U_k * S_k * V_k';
            
            % Data consistency enforcement
            Z_rec_tess.B = R .* Mask + Z_low.B .* (~Mask);
            Z_rec_tess.C = G .* Mask + Z_low.C .* (~Mask);
            Z_rec_tess.D = B .* Mask + Z_low.D .* (~Mask);
        end
        time_tess = toc(tic_tess); 
        
        I_rec_tess = cat(3, max(0, min(1, Z_rec_tess.B)), max(0, min(1, Z_rec_tess.C)), max(0, min(1, Z_rec_tess.D)));
        clear U_k S_k V_k Z_low; % Free RAM explicitly
                            
        % =================================================================
        % EXPERIMENT B: QUATERNION APPROACH (Complex Isomorphism)
        % =================================================================
        rec_qR = R .* Mask; rec_qG = G .* Mask; rec_qB = B .* Mask;
        Z_rec_quat = quaternion(zeros(M,N), rec_qR, rec_qG, rec_qB);
        
        tic_quat = tic; 
        for iter = 1:current_iters
            [U_qk, S_qk, V_qk] = qsvds_sp(Z_rec_quat, rank_k);
            Z_low_quat = U_qk * S_qk * V_qk';
            
            low_R = x(Z_low_quat); low_G = y(Z_low_quat); low_B = z(Z_low_quat);
            
            % Data consistency enforcement
            rec_qR = R .* Mask + low_R .* (~Mask); 
            rec_qG = G .* Mask + low_G .* (~Mask); 
            rec_qB = B .* Mask + low_B .* (~Mask);
            
            Z_rec_quat = quaternion(zeros(M,N), rec_qR, rec_qG, rec_qB);
        end
        time_quat = toc(tic_quat);
        
        I_rec_quat = cat(3, max(0, min(1, rec_qR)), max(0, min(1, rec_qG)), max(0, min(1, rec_qB)));
        clear U_qk S_qk V_qk Z_low_quat; % Free RAM explicitly
                            
        % =================================================================
        % METRICS LOGGING
        % =================================================================
        mse_tess = mean((I_rgb(:) - I_rec_tess(:)).^2); psnr_tess = 10 * log10(1 / mse_tess);
        mse_quat = mean((I_rgb(:) - I_rec_quat(:)).^2); psnr_quat = 10 * log10(1 / mse_quat);
        current_speedup = time_quat / time_tess;
        
        time_tess_arr(idx) = time_tess; time_quat_arr(idx) = time_quat; speedup_arr(idx) = current_speedup;
        
        fprintf(' %4d | %13.2f | %13.2f | %14.2f | %14.2f | %6.2fx \n', ...
                rank_k, time_tess, time_quat, psnr_tess, psnr_quat, current_speedup);
                
        % -----------------------------------------------------------------
        % THERMAL & MEMORY COOLDOWN
        % Prevents CPU throttling and allows OS to run garbage collection on 
        % massive native-resolution arrays.
        % -----------------------------------------------------------------
        pause(30); 
    end
    fprintf('------------------------------------------------------------------------------------------\n\n');
    
    % -----------------------------------------------------------------
    % 5. Visualization
    % -----------------------------------------------------------------
    figure('Name', sprintf('Scenario: %.0f%% Missing Data', current_missing*100), ...
           'Color', 'w', 'Position', [100+scenario*50, 100+scenario*50, 800, 500]);
    plot(rank_ks, time_tess_arr, '-o', 'LineWidth', 2.5, 'MarkerSize', 10, ...
        'DisplayName', '\alpha\beta-Tessarine Algebra (svds)', 'Color', [0 0.4470 0.7410]);
    hold on;
    plot(rank_ks, time_quat_arr, '-s', 'LineWidth', 2.5, 'MarkerSize', 10, ...
        'DisplayName', 'Quaternion Isomorphism (qsvds\_sp)', 'Color', [0.8500 0.3250 0.0980]);
    xlabel('Truncation Rank (k)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Total Execution Time (seconds)', 'FontSize', 13, 'FontWeight', 'bold');
    title(sprintf('In-painting Computation Time vs Rank k (Autumn Forest)\n(Missing Data: %.0f%% | Iters: %d)', current_missing*100, current_iters), ...
        'FontSize', 14);
    grid on; legend('Location', 'northwest', 'FontSize', 12); set(gca, 'FontSize', 12);
    
    ylim([0, max(time_quat_arr)*1.1]);
    drawnow; 
end

disp('===================================================================');
disp('  ALL STABILIZATION BENCHMARKS COMPLETED SUCCESSFULLY!             ');
disp('===================================================================');

% =========================================================================
% BASELINE ALGORITHM: TRUNCATED QUATERNION SVD VIA COMPLEX ISOMORPHISM
% =========================================================================
function [U_q, S_q, V_q] = qsvds_sp(Q, k)
%QSVDS_SP Truncated Quaternion SVD via Symplectic Complex Mapping.
%
%   [U_q, S_q, V_q] = QSVDS_SP(Q, k) computes the rank-k SVD of a quaternion 
%   matrix Q using standard complex iterative Lanczos/Arnoldi solvers.

    [m, n] = size(Q);
    A = complex(double(s(Q)), double(x(Q))); B = complex(double(y(Q)), double(z(Q)));
    Mc = [A, B; -conj(B), conj(A)];
    
    % Request 2*k eigenvalues due to the isomorphic eigenvalues duplication
    [Uc, Sc, Vc] = svds(Mc, 2*k);
    
    % Reconstruct hypercomplex components
    S_q = diag(diag(Sc(1:2:end, 1:2:end)));
    U_q = quaternion(real(Uc(1:m, 1:2:end)), imag(Uc(1:m, 1:2:end)), ...
                     real(-conj(Uc(m+1:end, 1:2:end))), imag(-conj(Uc(m+1:end, 1:2:end))));
    V_q = quaternion(real(Vc(1:n, 1:2:end)), imag(Vc(1:n, 1:2:end)), ...
                     real(-conj(Vc(n+1:end, 1:2:end))), imag(-conj(Vc(n+1:end, 1:2:end))));
end