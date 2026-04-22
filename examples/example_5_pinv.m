% =========================================================================
% abtessarine_Toolbox - Example 5 (pinv)
% High-Performance Computing: Scalability benchmark for Moore-Penrose pinv
% =========================================================================
% This script benchmarks the mean computation time of the pseudoinverse 
% pinv(A), scaling the dimension N from 100 to 1000 in steps of 100. 
% It averages the time over 20 simulations to produce a smooth complexity 
% curve. Since MATLAB's native quaternions lack full SVD support, their 
% pinv is computed via the 4N x 4N real isomorphic representation, proving 
% the massive O((4N)^3) computational bottleneck that abtessarine solves.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  HPC Benchmark: Moore-Penrose Pseudoinverse (pinv) Averaged       ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Simulation Parameters Configuration
% -------------------------------------------------------------------------
N_start = 100;
N_step  = 100;
N_max   = 1000; % Scales up to 1000x1000 matrices

% Array of dimensions: [100, 200, 300, ..., 1000]
N_values = N_start:N_step:N_max; 
num_tests = length(N_values);

% Number of simulations per dimension N (Unified to 20)
num_simulations = 20; 

% Preallocate memory to store MEAN computation times
time_quat_iso  = zeros(1, num_tests);
time_abt_pos   = zeros(1, num_tests);
time_abt_neg   = zeros(1, num_tests);

% -------------------------------------------------------------------------
% 2. Main Benchmarking Loop
% -------------------------------------------------------------------------
for k = 1:num_tests
    n = N_values(k);
    fprintf('\nBenchmarking matrix size: %d x %d (%d simulations)...\n', n, n, num_simulations);
    
    % Temporary arrays to store execution times for current N
    temp_time_quat_iso = zeros(1, num_simulations);
    temp_time_abt_pos  = zeros(1, num_simulations);
    temp_time_abt_neg  = zeros(1, num_simulations);
    
    for s = 1:num_simulations
        % Generate identical random base components for a fair comparison
        C1 = randn(n, n);
        C2 = randn(n, n);
        C3 = randn(n, n);
        C4 = randn(n, n);
        
        % --- Method 1: Standard Quaternion via Real Isomorphism (4N x 4N) ---
        % Because MATLAB's pinv(quaternion) fails due to non-commutativity,
        % the industry standard isomorphic expansion is used.
        R_iso = [C1, -C2, -C3, -C4;
                 C2,  C1, -C4,  C3;
                 C3,  C4,  C1, -C2;
                 C4, -C3,  C2,  C1];
        tic;
        pinv_R = pinv(R_iso); 
        temp_time_quat_iso(s) = toc;
        
        % --- Method 2: abtessarine Alpha > 0 (Native N x N) ---
        setabtessarine(2, 7);
        A_abt_pos = abtessarine(C1, C2, C3, C4);
        tic;
        pinv_abt_pos = pinv(A_abt_pos);
        temp_time_abt_pos(s) = toc;
        
        % --- Method 3: abtessarine Alpha <= 0 (Native N x N) ---
        setabtessarine(-1, 1);
        A_abt_neg = abtessarine(C1, C2, C3, C4);
        tic;
        pinv_abt_neg = pinv(A_abt_neg);
        temp_time_abt_neg(s) = toc;
    end
    
    % Calculate arithmetic mean of the simulations
    time_quat_iso(k) = mean(temp_time_quat_iso);
    time_abt_pos(k)  = mean(temp_time_abt_pos);
    time_abt_neg(k)  = mean(temp_time_abt_neg);
    
    fprintf('  -> Mean Quaternion (Isomorphic 4Nx4N):  %.4f seconds\n', time_quat_iso(k));
    fprintf('  -> Mean abtessarine (+) native time:    %.4f seconds\n', time_abt_pos(k));
    fprintf('  -> Mean abtessarine (-) native time:    %.4f seconds\n', time_abt_neg(k));
end

disp('-------------------------------------------------------------------');
disp('Benchmark completed successfully.');

% -------------------------------------------------------------------------
% 3. Generate Smoothed Plot for SoftwareX
% -------------------------------------------------------------------------
figure('Name', 'HPC Benchmark: Pseudoinverse (Isomorphism vs Native)', 'Color', 'w');

% Standard plot with consistent markers
plot(N_values, time_quat_iso, '-o', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980]); hold on;
plot(N_values, time_abt_pos, '-s', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410]);
plot(N_values, time_abt_neg, '-d', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0.9290 0.6940 0.1250], 'MarkerFaceColor', [0.9290 0.6940 0.1250]);

% Plot aesthetics
grid on;
set(gca, 'FontSize', 12, 'GridAlpha', 0.4, 'LineWidth', 1.2);
xlabel('Matrix Dimension (N)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Mean Computation Time (seconds)', 'FontSize', 14, 'FontWeight', 'bold');
title(sprintf('Performance Comparison: pinv (Mean of %d sims)', num_simulations), 'FontSize', 16, 'FontWeight', 'bold');
legend('Standard Quaternion (4N \times 4N Real Isomorphism)', '\alpha\beta-tessarine (\alpha > 0) [Native]', '\alpha\beta-tessarine (\alpha \leq 0) [Native]', ...
       'Location', 'northwest', 'FontSize', 12);

% Set X-axis limits tightly
xlim([min(N_values) max(N_values)]);