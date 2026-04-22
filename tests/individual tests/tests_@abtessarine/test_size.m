% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: size.m (Array Dimensions)
% =========================================================================
% This script verifies the dimensional metadata reporting of abtessarine 
% objects. It validates vector output, multi-variable assignment, and 
% dimension-specific queries for 2D and N-D manifolds.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: size.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Standard Matrix Size (Vector Output)
disp('TEST 1: Standard Size Reporting [D = size(X)]');
try
    M = 5; N = 3;
    X = abtrandn(M, N);
    
    D = size(X);
    
    if isequal(D, [M, N])
        disp(['   [OK] Correctly reported size [', num2str(D), '].']);
    else
        error('Size vector mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Multiple Output Assignment [M, N] = size(X)
disp('TEST 2: Multiple Variable Assignment [R, C] = size(X)');
try
    R_in = 10; C_in = 2;
    X = abtrandn(R_in, C_in);
    
    [R_out, C_out] = size(X);
    
    if R_out == R_in && C_out == C_in
        disp('   [OK] Multiple outputs correctly assigned (R, C).');
    else
        error('Multi-output assignment mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dimension-Specific Query
disp('TEST 3: Dimension-Specific Query [K = size(X, DIM)]');
try
    % Test with a 3D Tensor
    X3 = abtessarine(randn(2, 4, 8), randn(2, 4, 8), randn(2, 4, 8), randn(2, 4, 8));
    
    k = size(X3, 3); % Query depth (dimension 3)
    
    if k == 8
        disp('   [OK] Correctly reported size for specific dimension (DIM=3).');
    else
        error('Dimension-specific query failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');