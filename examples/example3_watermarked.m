% =========================================================================
% EXAMPLE 3: Digital Image Watermarking via Hypercomplex QR Decomposition
% =========================================================================
% Description:
%   This script evaluates the computational efficiency, mathematical 
%   robustness, and physical scalability of the abtessarine toolbox for 
%   digital image watermarking. It benchmarks the native hypercomplex 
%   QR decomposition against the state-of-the-art Structure-Preserving 
%   Quaternion QR (SP-QR) algorithm by Jia et al. (2018).
%
% Key Mathematical Concept:
%   To prevent magnitude distortion or energy leakage during the orthogonal
%   projection, the topological space is forced to its isometric bicomplex 
%   state (alpha = -1, beta = 1).
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('   [HYPERCOMPLEX QR WATERMARKING: SCALABILITY BENCHMARK]           ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Global Environment Setup
% -------------------------------------------------------------------------
% Configure the environment to the strictly isometric tessarine state
alpha_val = -1; 
beta_val  = 1;
setabtessarine(alpha_val, beta_val);
fprintf('-> Topological environment successfully configured: alpha = %d, beta = %d\n\n', alpha_val, beta_val);

% -------------------------------------------------------------------------
% 2. Load Host and Watermark Datasets
% -------------------------------------------------------------------------
disp('-> Loading high-resolution datasets (Autumn_Forest & Architecture)...');
try
    I_host_base = im2double(imread('Autumn_Forest.jpg'));
    I_wm_base   = im2double(imread('Modern_Architecture.jpg')); 
catch
    I_host_base = im2double(imread('Autumn_Forest.png'));
    I_wm_base   = im2double(imread('Modern_Architecture.png')); 
end

% =========================================================================
% WARM-UP PHASE: JIT Compiler & CPU Cache Wake-up
% =========================================================================
% MATLAB's Just-In-Time (JIT) compiler requires a first execution pass to 
% optimize the bytecode. This dummy execution ensures accurate O(N^3) timing.
disp('-> Warming up MATLAB JIT Compiler and LAPACK/BLAS engine...');

dummy_H = abtessarine(zeros(64,64), rand(64,64), rand(64,64), rand(64,64));
[~, ~] = qr(dummy_H);

dummy_Q = quaternion(zeros(32,32), rand(32,32), rand(32,32), rand(32,32));
[~, ~] = sp_qr_jia(dummy_Q);

pause(1);
disp('-> Warm-up complete. Commencing accurate scalability benchmark.');
disp(' ');

% -------------------------------------------------------------------------
% 3. Experimental Parameters Setup 
% -------------------------------------------------------------------------
base_gains  = [0.01, 0.05, 0.1];           % Base embedding strengths
resolutions = [256, 512, 1024, 2048];      % Spatial scaling vector

% -------------------------------------------------------------------------
% 4. Main Benchmark Loop
% -------------------------------------------------------------------------
for k_idx = 1:length(base_gains)
    current_base_k = base_gains(k_idx);
    
    fprintf('==========================================================================================\n');
    fprintf(' SCENARIO %d: Base Gain = %.2f (Energy-Preserving Mode) \n', k_idx, current_base_k);
    fprintf('==========================================================================================\n');
    fprintf(' Res (N) | k_adapt | Tess Time (s) | Quat Time (s) | Tess PSNR (dB) | Quat PSNR (dB) | Speedup \n');
    fprintf('------------------------------------------------------------------------------------------\n');
    
    % Preallocate arrays for tracking performance metrics
    time_tess_arr = zeros(size(resolutions));
    time_quat_arr = zeros(size(resolutions));
    
    for r_idx = 1:length(resolutions)
        res = resolutions(r_idx);
        
        % ADAPTIVE GAIN: Scale down the gain as resolution increases to 
        % preserve total watermark energy, preventing artificial degradation.
        k_adaptive = current_base_k * (256 / res);
        
        % Dynamic resizing of matrices
        I_host = imresize(I_host_base, [res, res]);
        I_wm   = imresize(I_wm_base, [res, res]);
        
        R_h = I_host(:,:,1); G_h = I_host(:,:,2); B_h = I_host(:,:,3);
        R_w = I_wm(:,:,1);   G_w = I_wm(:,:,2);   B_w = I_wm(:,:,3);
        
        % =================================================================
        % EXPERIMENT A: TESSARINES (abtessarine Toolbox)
        % =================================================================
        H_tess = abtessarine(zeros(res,res), R_h, G_h, B_h);
        W_tess = abtessarine(zeros(res,res), R_w, G_w, B_w);
        
        tic_tess = tic;
        [Q_t, R_t] = qr(H_tess);                     % Native overloaded LAPACK call
        R_wm_tess = R_t + k_adaptive * W_tess;       % Embedding process
        H_marked_tess = Q_t * R_wm_tess;             % Reconstruction
        time_tess = toc(tic_tess);
        
        I_rec_tess = cat(3, max(0, min(1, H_marked_tess.B)), ...
                            max(0, min(1, H_marked_tess.C)), ...
                            max(0, min(1, H_marked_tess.D)));
                            
        % =================================================================
        % EXPERIMENT B: QUATERNIONS (Iterative SP-QR Baseline)
        % =================================================================
        H_quat = quaternion(zeros(res,res), R_h, G_h, B_h);
        W_quat = quaternion(zeros(res,res), R_w, G_w, B_w);
        
        tic_quat = tic;
        [Q_q, R_q] = sp_qr_jia(H_quat);              % Structure-Preserving Householder updates
        R_wm_quat = R_q + k_adaptive * W_quat;       % Embedding process
        H_marked_quat = Q_q * R_wm_quat;             % Reconstruction
        time_quat = toc(tic_quat);
        
        I_rec_quat = cat(3, max(0, min(1, x(H_marked_quat))), ...
                            max(0, min(1, y(H_marked_quat))), ...
                            max(0, min(1, z(H_marked_quat))));
                            
        % =================================================================
        % METRICS LOGGING
        % =================================================================
        psnr_tess = 10 * log10(1 / mean((I_host(:) - I_rec_tess(:)).^2));
        psnr_quat = 10 * log10(1 / mean((I_host(:) - I_rec_quat(:)).^2));
        current_speedup = time_quat / time_tess;
        
        time_tess_arr(r_idx) = time_tess;
        time_quat_arr(r_idx) = time_quat;
        
        fprintf(' %4dx%-4d| %7.4f | %13.4f | %13.4f | %14.2f | %14.2f | %6.2fx \n', ...
                res, res, k_adaptive, time_tess, time_quat, psnr_tess, psnr_quat, current_speedup);
                
        % Thermal cooldown between iterations
        pause(2); 
    end
    fprintf('------------------------------------------------------------------------------------------\n\n');
    
    % -----------------------------------------------------------------
    % 5. Visualization
    % -----------------------------------------------------------------
    figure('Name', sprintf('QR Computation Time (Base Gain: %.2f)', current_base_k), ...
           'Color', 'w', 'Position', [100+k_idx*50, 100+k_idx*50, 750, 500]);
           
    plot(resolutions, time_tess_arr, '-o', 'LineWidth', 2.5, 'MarkerSize', 9, ...
        'DisplayName', '\alpha\beta-Tessarine (Native O(N^3))', 'Color', [0 0.4470 0.7410]);
    hold on;
    
    plot(resolutions, time_quat_arr, '-s', 'LineWidth', 2.5, 'MarkerSize', 9, ...
        'DisplayName', 'Quaternion SP-QR (Iterative)', 'Color', [0.8500 0.3250 0.0980]);
    
    xlabel('Image Resolution (N \times N)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Execution Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('QR Decomposition Time vs Scalability\n(Base Gain = %.2f | Energy-Preserving)', current_base_k), 'FontSize', 14);
    
    grid on; 
    legend('Location', 'northwest', 'FontSize', 12); 
    set(gca, 'FontSize', 12, 'XTick', resolutions);
    
    drawnow;
end

disp('===================================================================');
disp('  ALL QR SCALABILITY TESTS COMPLETED SUCCESSFULLY!                   ');
disp('===================================================================');

% =========================================================================
% BASELINE ALGORITHM: STRUCTURE-PRESERVING QUATERNION QR
% =========================================================================
function [Qq, Rq] = sp_qr_jia(Q)
%SP_QR_JIA Structure-Preserving Quaternion QR Decomposition.
%
%   [Qq, Rq] = SP_QR_JIA(Q) computes the quaternion QR decomposition of a 
%   quaternion matrix Q based on the symplectic complex isomorphism.
%
%   Note: This implementation is mathematically rigorous but computationally 
%   expensive due to the iterative execution of symplectic Householder 
%   reflections within MATLAB's interpreted environment.

    [m, n] = size(Q);
    
    % 1. Map to complex symplectic matrix (2m x 2n)
    C1 = complex(double(s(Q)), double(x(Q)));
    C2 = complex(double(y(Q)), double(z(Q)));
    Mc = [C1, C2; -conj(C2), conj(C1)];
    
    % Initialize orthogonal and upper triangular components
    Rc = Mc;
    Qc = eye(2*m);
    
    % 2. Iterative Structure-Preserving Householder Reflections
    for k = 1:n
        idx1 = k:m; 
        idx2 = m+k:2*m; 
        idx = [idx1, idx2];
        
        col1 = k:n; 
        col2 = n+k:2*n; 
        cols = [col1, col2];
        
        % Extract working column
        x_vec = Rc(idx, k);
        alpha = norm(x_vec);
        
        if alpha > 1e-14
            x1_1 = x_vec(1);
            if abs(x1_1) == 0; phase = 1; else; phase = x1_1 / abs(x1_1); end
            
            % Compute symplectic Householder vectors
            u = x_vec; 
            u(1) = u(1) + alpha * phase; 
            u = u / norm(u);
            
            u1 = u(1:length(idx1)); 
            u2 = u(length(idx1)+1:end);
            v = [conj(u2); -conj(u1)];
            
            % Apply reflection to the trailing submatrix (R update)
            subR = Rc(idx, cols);
            subR = subR - 2 * u * (u' * subR) - 2 * v * (v' * subR);
            Rc(idx, cols) = subR;
            
            % Accumulate orthogonal transformations (Q update)
            subQ = Qc(:, idx);
            subQ = subQ - 2 * (subQ * u) * u' - 2 * (subQ * v) * v';
            Qc(:, idx) = subQ;
        end
    end
    
    % 3. Extract and reconstruct quaternion matrices
    R1 = Rc(1:n, 1:n); R2 = Rc(1:n, n+1:2*n);
    Rq = quaternion(real(R1), imag(R1), real(R2), imag(R2));
    
    Q1 = Qc(1:m, 1:n); Q2 = Qc(1:m, n+1:2*n);
    Qq = quaternion(real(Q1), imag(Q1), real(Q2), imag(Q2));
end