% =========================================================================
% EXAMPLE 2: Robustness in Kinematic Linear Systems
% =========================================================================
% This script tests the overloaded backslash operator (\) for solving 
% overdetermined linear systems under additive noise conditions.

clear classes; clc; close all;
fprintf('--- Running Example 2: Kinematic Linear Systems ---\n');

% 1. Set the classical tessarine environment (alpha = -1, beta = 1)
setabtessarine(-1, 1);

% 2. Define the system configuration
N = 50; 
disp(['Generating a well-conditioned ', num2str(N), 'x', num2str(N), ' transition matrix...']);
% Create a diagonally dominant matrix to ensure stability
M = abtrandn(N, N) + N * abteye(N); 
x_true = abtrandn(N, 1); % True spatial coordinates

noise_variances = [0.01, 0.05, 0.1, 0.25, 0.5];
errors = zeros(size(noise_variances));

% 3. Test the solver against different noise levels
disp('Solving systems...');
for idx = 1:length(noise_variances)
    nv = noise_variances(idx);
    
    % Add simulated sensor noise to the observation vector 'b'
    noise = nv * abtrandn(N, 1);
    b_noisy = (M * x_true) + noise;
    
    % Solve the system using native MATLAB syntax
    x_est = M \ b_noisy;
    
    % Calculate estimation error
    estimation_error = norm(x_true - x_est);
    errors(idx) = estimation_error;
    
    fprintf('Noise Variance: %4.2f | Estimation Error: %6.4f\n', nv, estimation_error);
end

% 4. Visualization
figure('Name', 'Robustness Analysis', 'Position', [200, 200, 600, 400]);
plot(noise_variances, errors, '-ok', 'LineWidth', 2, 'MarkerFaceColor', 'r');
grid on;
xlabel('Additive Noise Variance');
ylabel('Reconstruction Error ||x_{true} - x_{est}||');
title('Linear System Robustness (M \ b)', 'Interpreter', 'none');

disp('Example 2 completed successfully.');