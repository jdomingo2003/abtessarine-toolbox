% =========================================================================
% abtessarine_Toolbox - Example 11
% Application: Hypercomplex Curve Fitting via QR Decomposition
% =========================================================================
% This script demonstrates the native QR factorization of the toolbox.
% It performs numerically stable Least Squares regression to model a 
% noisy 4D hypercomplex trajectory (e.g., drone/sensor tracking) 
% without explicitly forming the ill-conditioned normal equations.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  Application: Hypercomplex Least Squares Regression (QR)          ');
disp('===================================================================');

% Set the tessarine algebra parameters (standard tessarines)
setabtessarine(-1, 1);

% -------------------------------------------------------------------------
% 1. Simulate a 4D Trajectory Target
% -------------------------------------------------------------------------
disp('1. Generating true 4D trajectory and noisy sensor measurements...');
M = 300; % Number of overdetermined sensor measurements (M > N)
t = linspace(-2, 2, M)';

% True underlying polynomial coefficients for the 4 hypercomplex dimensions
% Degree 3 polynomial: y(t) = W_0 + W_1*t + W_2*t^2 + W_3*t^3
W0 = abtessarine(1.0, -0.5,  0.2,  1.5);
W1 = abtessarine(0.5,  2.0, -1.0,  0.0);
W2 = abtessarine(-0.2, 0.1,  0.8, -0.5);
W3 = abtessarine(0.1, -0.3, -0.1,  0.2);

% Generate the true smooth trajectory
Y_true = W0 + W1.*t + W2.*(t.^2) + W3.*(t.^3);

% Add severe sensor measurement noise to all components
noise = abtessarine(randn(M,1), randn(M,1), randn(M,1), randn(M,1)) * 1.5;
Y_noisy = Y_true + noise;

% -------------------------------------------------------------------------
% 2. Formulate the Overdetermined System Matrix (Vandermonde)
% -------------------------------------------------------------------------
disp('2. Building the Vandermonde system matrix...');
degree = 3;
N = degree + 1; % Number of unknown coefficients (N = 4)

% Build the M x N hypercomplex matrix A (Vandermonde structure)
A = abtzeros(M, N);
for j = 1:N
    col_data = t.^(j-1);
    A(:, j) = abtessarine(col_data, zeros(M,1), zeros(M,1), zeros(M,1));
end

% -------------------------------------------------------------------------
% 3. Numerically Stable Least Squares via QR
% -------------------------------------------------------------------------
disp('3. Solving Least Squares stably via Native Hypercomplex QR...');

tic;
% 3A. Perform Native Hypercomplex QR Decomposition
% Q is M x M (Orthogonal), R is M x N (Upper Triangular)
[Q, R] = qr(A);
time_qr = toc;
fprintf('   -> QR factorization computed natively in %.4f seconds.\n', time_qr);

% 3B. Project the noisy data onto the orthogonal basis
Q_Y = Q' * Y_noisy;

% 3C. Extract the N x N square upper-triangular block of R 
% and the top N elements of Q_Y to solve the exact determined system.
% This avoids attempting to invert a non-square R.
R_sq = abtessarine(R.A(1:N, 1:N), R.B(1:N, 1:N), R.C(1:N, 1:N), R.D(1:N, 1:N));
Q_Y_top = abtessarine(Q_Y.A(1:N, 1), Q_Y.B(1:N, 1), Q_Y.C(1:N, 1), Q_Y.D(1:N, 1));

% 3D. Solve the square system for the weight vector W
W_est = inv(R_sq) * Q_Y_top; 

% -------------------------------------------------------------------------
% 4. Reconstruct the Fitted Model
% -------------------------------------------------------------------------
disp('4. Reconstructing the fitted mathematical model...');
Y_fit = A * W_est;

% -------------------------------------------------------------------------
% 5. Display Results (2x2 Grid Layout for SoftwareX)
% -------------------------------------------------------------------------
disp('5. Generating visualization figure (2x2 grid)...');

figure('Name', 'QR Least Squares Trajectory Fitting', 'Color', 'w', 'Position', [100 100 950 850]);

% Classical Tessarine Notation
components = {'Real Part (1)', 'Imaginary Part (i)', ...
              'Imaginary Part (j)', 'Imaginary Part (k)'};

for i = 1:4
    subplot(2, 2, i);
    hold on; grid on;
    
    switch i
        case 1, y_n = Y_noisy.A; y_t = Y_true.A; y_f = Y_fit.A;
        case 2, y_n = Y_noisy.B; y_t = Y_true.B; y_f = Y_fit.B;
        case 3, y_n = Y_noisy.C; y_t = Y_true.C; y_f = Y_fit.C;
        case 4, y_n = Y_noisy.D; y_t = Y_true.D; y_f = Y_fit.D;
    end
    
    scatter(t, y_n, 12, [0.7 0.7 0.7], 'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName', 'Noisy Data');
    plot(t, y_t, 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Path');
    plot(t, y_f, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, 'DisplayName', 'QR Fit');
    
    title(components{i}, 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (t)'); ylabel('Amplitude');
    
    if i == 1
        legend('Location', 'best', 'FontSize', 9);
    end
    ylim([-7 7]);
end

disp('-------------------------------------------------------------------');