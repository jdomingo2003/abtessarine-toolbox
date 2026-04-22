% =========================================================================
% abtessarine_Toolbox - Example 5
% High-Performance Computing: Scalability benchmark for matrix inversion
% =========================================================================
% This script benchmarks the mean computation time of the matrix inverse 
% inv(A), scaling the dimension N from 100 to 1000 in steps of 100. 
% It averages the time over 20 simulations to produce a smooth O(N^3) 
% complexity curve, comparing standard MATLAB quaternions with the native 
% abtessarine framework (for both alpha > 0 and alpha <= 0).
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  HPC Benchmark: Matrix Inversion Complexity O(N^3) (Averaged)     ');
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
time_quat      = zeros(1, num_tests);
time_abt_pos   = zeros(1, num_tests);
time_abt_neg   = zeros(1, num_tests);

% -------------------------------------------------------------------------
% 2. Main Benchmarking Loop
% -------------------------------------------------------------------------
for k = 1:num_tests
    n = N_values(k);
    fprintf('\nBenchmarking matrix size: %d x %d (%d simulations)...\n', n, n, num_simulations);
    
    % Temporary arrays to store execution times for current N
    temp_time_quat    = zeros(1, num_simulations);
    temp_time_abt_pos = zeros(1, num_simulations);
    temp_time_abt_neg = zeros(1, num_simulations);
    
    for s = 1:num_simulations
        % Generate identical random base components for a fair comparison
        C1 = randn(n, n);
        C2 = randn(n, n);
        C3 = randn(n, n);
        C4 = randn(n, n);
        
        % --- Method 1: Standard MATLAB Quaternion ---
        A_quat = quaternion(C1, C2, C3, C4);
        tic;
        inv_quat = inv(A_quat);
        temp_time_quat(s) = toc;
        
        % --- Method 2: abtessarine Alpha > 0 ---
        setabtessarine(2, 7);
        A_abt_pos = abtessarine(C1, C2, C3, C4);
        tic;
        inv_abt_pos = inv(A_abt_pos);
        temp_time_abt_pos(s) = toc;
        
        % --- Method 3: abtessarine Alpha <= 0 ---
        setabtessarine(-1, 1);
        A_abt_neg = abtessarine(C1, C2, C3, C4);
        tic;
        inv_abt_neg = inv(A_abt_neg);
        temp_time_abt_neg(s) = toc;
    end
    
    % Calculate arithmetic mean of the simulations
    time_quat(k)    = mean(temp_time_quat);
    time_abt_pos(k) = mean(temp_time_abt_pos);
    time_abt_neg(k) = mean(temp_time_abt_neg);
    
    fprintf('  -> Mean Quaternion time:  %.4f seconds\n', time_quat(k));
    fprintf('  -> Mean abtessarine (+):  %.4f seconds\n', time_abt_pos(k));
    fprintf('  -> Mean abtessarine (-):  %.4f seconds\n', time_abt_neg(k));
end

disp('-------------------------------------------------------------------');
disp('Benchmark completed successfully.');

% -------------------------------------------------------------------------
% 3. Generate Smoothed Plot for SoftwareX
% -------------------------------------------------------------------------
figure('Name', 'HPC Benchmark: Matrix Inversion Averaged', 'Color', 'w');

% Standard plot with consistent markers
plot(N_values, time_quat, '-o', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980]); hold on;
plot(N_values, time_abt_pos, '-s', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410]);
plot(N_values, time_abt_neg, '-d', 'LineWidth', 2.5, 'MarkerSize', 7, 'Color', [0.9290 0.6940 0.1250], 'MarkerFaceColor', [0.9290 0.6940 0.1250]);

% Plot aesthetics
grid on;
set(gca, 'FontSize', 12, 'GridAlpha', 0.4, 'LineWidth', 1.2);
xlabel('Matrix Dimension (N)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Mean Computation Time (seconds)', 'FontSize', 14, 'FontWeight', 'bold');
title(sprintf('Performance Comparison: Matrix Inversion (Mean of %d sims)', num_simulations), 'FontSize', 16, 'FontWeight', 'bold');
legend('Standard MATLAB quaternion', '\alpha\beta-tessarine (\alpha > 0)', '\alpha\beta-tessarine (\alpha \leq 0)', ...
       'Location', 'northwest', 'FontSize', 12);

% Set X-axis limits tightly
xlim([min(N_values) max(N_values)]);