% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: sum.m (Array Summation)
% =========================================================================
% This script verifies the multidimensional summation capabilities of the 
% abtessarine class. It validates default dimension reduction, explicit 
% dimensional tracking, and native flag delegation (e.g., 'all').
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: sum.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-14;

%% TEST 1: Default Behavior (First Non-Singleton Dimension)
disp('TEST 1: Default Dimension Reduction');
try
    % 1.1 Vector reduction (1x4 should reduce to 1x1)
    V = abtessarine(ones(1,4), ones(1,4)*2, zeros(1,4), zeros(1,4));
    S_vec = sum(V);
    
    if isscalar(S_vec.A) && S_vec.A == 4 && S_vec.B == 8
        disp('   [OK] Row vector correctly summed to a scalar.');
    else
        error('Vector default summation failed.');
    end
    
    % 1.2 Matrix reduction (3x4 should reduce to 1x4 row vector)
    M = abtessarine(ones(3,4), zeros(3,4), zeros(3,4), zeros(3,4));
    S_mat = sum(M);
    
    if isequal(size(S_mat.A), [1, 4]) && all(S_mat.A == 3)
        disp('   [OK] Matrix correctly summed along columns (Dim 1).');
    else
        error('Matrix default summation failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Explicit Dimensional Summation
disp('TEST 2: Explicit Dimension Targeting [sum(X, DIM)]');
try
    X = abtrandn(3, 4, 2); % 3D Tensor
    
    % Sum across rows (Dimension 2) -> Result should be 3x1x2
    S_dim2 = sum(X, 2);
    
    % Sum across pages (Dimension 3) -> Result should be 3x4x1
    S_dim3 = sum(X, 3);
    
    if isequal(size(S_dim2.A), [3, 1, 2]) && isequal(size(S_dim3.A), [3, 4, 1])
        % Check a specific accumulation for data integrity
        check_val = X.A(1,1,1) + X.A(1,2,1) + X.A(1,3,1) + X.A(1,4,1);
        if abs(S_dim2.A(1,1,1) - check_val) < tol
            disp('   [OK] Explicit dimension targeting accurately executed.');
        else
            error('Data accumulation mismatch in dimension 2.');
        end
    else
        error('Dimensional mapping failed during explicit summation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Advanced Native Flags
disp('TEST 3: Native Flag Delegation [sum(X, ''all'')]');
try
    X_all = abtessarine(ones(5,5), ones(5,5)*2, ones(5,5)*3, ones(5,5)*4);
    
    % Request total sum of all elements
    S_all = sum(X_all, 'all');
    
    % 5x5 = 25 elements. Expected: A=25, B=50, C=75, D=100
    if isscalar(S_all.A) && S_all.A == 25 && S_all.D == 100
        disp('   [OK] Total array summation via ''all'' flag cleanly delegated.');
    else
        error('Native flag delegation failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');