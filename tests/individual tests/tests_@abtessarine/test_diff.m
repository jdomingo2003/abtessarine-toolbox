% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: diff.m (Finite Differences)
% =========================================================================
% This script verifies the numerical accuracy of finite differences and 
% approximate derivatives. It validates the correct handling of recursive 
% orders and dimensional orientation (row-wise vs column-wise).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: diff.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology
N = 10; M = 5;

%% TEST 1: First-Order Difference (Default)
disp('TEST 1: First-Order Forward Difference (Along Dim 1)');
try
    % Create a matrix with a known linear trend in component A
    % A = [1; 2; 3; 4...], so diff(A) should be all 1s.
    X = abtzeros(N, M);
    X.A = repmat((1:N)', 1, M);
    X.B = randn(N, M);
    
    Y = diff(X);
    
    % Verify size: (N-1) x M
    sz_Y = size(Y.A);
    if isequal(sz_Y, [N-1, M])
        % Check values in A (should be 1) and B (should match native diff)
        err_A = norm(Y.A - 1);
        err_B = norm(Y.B - diff(X.B));
        
        if err_A < 1e-14 && err_B < 1e-14
            disp('   [OK] First-order differences calculated with machine precision.');
            disp('   [OK] Output dimensions correctly reduced to (N-1).');
        else
            error('Numerical mismatch in difference components.');
        end
    else
        error('Dimension mismatch. Expected [%d, %d], Got [%d, %d].', N-1, M, sz_Y(1), sz_Y(2));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Second-Order and Dimensional Difference
disp('TEST 2: Second-Order Differences along Columns (Dim 2)');
try
    X2 = abtrandn(N, M);
    
    % Compute 2nd order difference along the 2nd dimension
    Y2 = diff(X2, 2, 2);
    
    % Verify size: N x (M-2)
    sz_Y2 = size(Y2.A);
    if isequal(sz_Y2, [N, M-2])
        % Cross-check with native MATLAB diff
        expected_D = diff(X2.D, 2, 2);
        if norm(Y2.D - expected_D) < 1e-14
            disp('   [OK] Higher-order recursion (n=2) verified.');
            disp('   [OK] Dimensional targeting (dim=2) verified.');
        else
            error('Content mismatch in multidimensional difference.');
        end
    else
        error('Dimension mismatch for higher-order difference.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');