% =========================================================================
% abtessarine_Toolbox - Example 10
% Application: Signal Recovery via Hypercomplex Tikhonov Regularization
% =========================================================================
% This script demonstrates the native Cholesky factorization of the toolbox.
% It recovers a massive multidimensional signal (2000 time steps) distorted 
% by a Rician multipath channel and additive noise. 
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  Application: Hypercomplex Signal Recovery (Cholesky / MMSE)      ');
disp('===================================================================');

setabtessarine(-1, 1);

% -------------------------------------------------------------------------
% 1. Generate the Original Multidimensional Signal (4 channels)
% -------------------------------------------------------------------------
disp('1. Generating original structured 4D signal...');
N = 2000; % Massive increase in time samples for HPC demonstration
t = linspace(0, 8*pi, N)'; % Increased time span to show more wave cycles

% Smooth, distinct waveforms for each hypercomplex component
sig_A = sin(t);
sig_B = cos(1.5 * t);
sig_C = sin(2 * t) .* exp(-0.05 * t);
sig_D = cos(0.5 * t);

X_orig = abtessarine(sig_A, sig_B, sig_C, sig_D);

% -------------------------------------------------------------------------
% 2. Simulate Channel Distortion (Rician Fading) and Noise
% -------------------------------------------------------------------------
disp('2. Simulating channel distortion (LoS + multipath) and noise...');

% Generate a channel matrix with a strong Line-of-Sight (LoS) path.
% HPC Scaling: We divide by sqrt(N) to ensure the spectral radius of the 
% interference remains strictly bounded regardless of matrix size.
scale_factor = 0.5 / sqrt(N); 

H_A = eye(N) + randn(N) * scale_factor;
H_B = randn(N) * scale_factor;
H_C = randn(N) * scale_factor;
H_D = randn(N) * scale_factor;

H = abtessarine(H_A, H_B, H_C, H_D);

% Generate random additive measurement noise
noise = abtessarine(randn(N,1), randn(N,1), randn(N,1), randn(N,1)) * 0.1;

% The received signal is thoroughly scrambled by echoes and noise
Y_recv = H * X_orig + noise; 

% -------------------------------------------------------------------------
% 3. Signal Recovery using MMSE / Tikhonov Regularization (Cholesky)
% -------------------------------------------------------------------------
disp('3. Recovering signal natively via Cholesky factorization...');

% Tikhonov regularization parameter
lambda = 0.5; 

% Create Hypercomplex Identity Matrix
I_mat = abtessarine(eye(N), zeros(N), zeros(N), zeros(N));

% Form the Normal Equations Matrix: Sigma = H'* H + lambda * I
Sigma = H' * H + I_mat * lambda;

% --- CRITICAL HPC FIX: FLOATING-POINT SYMMETRIZATION ---
% Matrix multiplications generate 10^-16 floating-point asymmetries.
% We strictly force Hermitian symmetry to satisfy chol() requirements.
Sigma = 0.5 * (Sigma + Sigma');

tic;
% 3A. Perform Native Hypercomplex Cholesky Factorization
R = chol(Sigma);
time_chol = toc;
fprintf('   -> Cholesky factorization (2000x2000) computed in %.4f seconds.\n', time_chol);

% 3B. Solve the linear system stably: (R' * R) * X_rec = H' * Y
X_rec = inv(R) * (inv(R') * (H' * Y_recv));

% -------------------------------------------------------------------------
% 4. Display Results
% -------------------------------------------------------------------------
disp('4. Generating visualization figure...');
figure('Name', 'Hypercomplex Signal Recovery (N=2000)', 'Color', 'w', 'Position', [100 100 1200 400]);

% Extracting imaginary component 'C' for visualization across all stages
c_orig = X_orig.C;
c_recv = Y_recv.C;
c_rec  = X_rec.C;

subplot(1, 3, 1);
plot(t, c_orig, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
grid on; title('Original Signal (Component $e_2$)', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Time', 'FontSize', 12); ylabel('Amplitude', 'FontSize', 12);
ylim([-1.5 1.5]); xlim([0 max(t)]);

subplot(1, 3, 2);
plot(t, c_recv, 'LineWidth', 1.0, 'Color', [0.8500 0.3250 0.0980]);
grid on; title('Received Signal (Scrambled)', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Time', 'FontSize', 12);
ylim([-1.5 1.5]); xlim([0 max(t)]);

subplot(1, 3, 3);
plot(t, c_rec, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
grid on; title('Recovered Signal (Cholesky)', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Time', 'FontSize', 12);
ylim([-1.5 1.5]); xlim([0 max(t)]);

disp('-------------------------------------------------------------------');