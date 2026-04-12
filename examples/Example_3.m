% =========================================================================
% EXAMPLE 3: High-Performance Computing (HPC) Benchmark
% =========================================================================
% This script evaluates the computational acceleration achieved by mapping 
% hypercomplex operations directly to MATLAB's BLAS/LAPACK core.

clear classes; clc; close all;
fprintf('--- Running Example 3: HPC Scalability Benchmark ---\n');

% 1. Environment configuration (alpha = -1, beta = 1)
setabtessarine(-1, 1);
alpha = -1; beta = 1;

% 2. Define matrix sizes (from 50 to 200 in steps of 50)
matrix_sizes = 50:50:200; 
speedups = zeros(size(matrix_sizes));

for idx = 1:length(matrix_sizes)
    N = matrix_sizes(idx);
    fprintf('\nBenchmarking size: %d x %d...\n', N, N);
    
    % Generate random matrices
    T1 = abtrandn(N, N);
    T2 = abtrandn(N, N);
    
    % -------------------------------------------------------------------
    % METHOD A: TOOLBOX VECTORIZED APPROACH (BLAS/LAPACK Core)
    % -------------------------------------------------------------------
    tic;
    T_out_fast = T1 * T2;
    time_toolbox = toc;
    fprintf('  Toolbox time: %8.4f seconds\n', time_toolbox);
    
    % -------------------------------------------------------------------
    % METHOD B: TRADITIONAL NESTED LOOPS (Native MATLAB)
    % -------------------------------------------------------------------
    % Manually compute component A to estimate the computational cost
    Out_A = zeros(N); 
    tic;
    for r = 1:N
        for c = 1:N
            for k = 1:N
                Out_A(r,c) = Out_A(r,c) + ...
                    T1.A(r,k)*T2.A(k,c) + ...
                    alpha * T1.B(r,k)*T2.B(k,c) + ...
                    beta  * T1.C(r,k)*T2.C(k,c) - ...
                    alpha * beta * T1.D(r,k)*T2.D(k,c);
            end
        end
    end
    % Multiply by 4 to estimate the total time for all 4 components
    time_loop = toc * 4; 
    fprintf('  Loops time:   %8.4f seconds (Estimated)\n', time_loop);
    
    % -------------------------------------------------------------------
    % RESULTS
    % -------------------------------------------------------------------
    speedup = time_loop / time_toolbox;
    speedups(idx) = speedup;
    fprintf('  -> SPEEDUP: %.1fx FASTER\n', speedup);
end

% 3. Visualization: Line plot
figure('Name', 'HPC Benchmark', 'Position', [300, 300, 600, 400]);
plot(matrix_sizes, speedups, '-sb', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 8);
grid on;
xlabel('Matrix Size (N x N)');
ylabel('Speedup Factor (Toolbox vs Loops)');
title('Computational Acceleration Scaling (ab-Tessarine Toolbox)');

disp('Example 3 completed successfully.');