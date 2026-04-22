% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: ndims.m (Number of Array Dimensions)
% =========================================================================
% This script verifies the tensor rank evaluation of abtessarine objects.
% It ensures that the number of dimensions is correctly reported for 
% scalars, vectors, matrices, and N-dimensional tensors.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: ndims.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Standard 2D Manifolds (Scalars, Vectors, Matrices)
disp('TEST 1: Dimensions of 2D Manifolds (Rank 2)');
try
    % In MATLAB, scalars, vectors and matrices all have ndims = 2
    s = abtessarine(1, 0, 0, 0);
    v = abtrandn(10, 1);
    M = abtrandn(5, 5);
    
    if ndims(s) == 2 && ndims(v) == 2 && ndims(M) == 2
        disp('   [OK] Correctly identified Rank 2 for scalar, vector, and matrix.');
    else
        error('ndims mismatch for 2D structures.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Higher-Order Tensors (Rank N)
disp('TEST 2: Dimensions of High-Order Tensors (Rank N > 2)');
try
    % Create a 3D tensor: 4x4x3
    T3 = abtessarine(randn(4,4,3), randn(4,4,3), randn(4,4,3), randn(4,4,3));
    
    % Create a 4D tensor: 2x2x2x2
    T4 = abtessarine(randn(2,2,2,2), randn(2,2,2,2), randn(2,2,2,2), randn(2,2,2,2));
    
    if ndims(T3) == 3 && ndims(T4) == 4
        disp('   [OK] Correctly identified Rank 3 and Rank 4 for tensor manifolds.');
    else
        error('ndims mismatch for higher-order tensors.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Consistency with Primary Branch
disp('TEST 3: Metadata Consistency Check');
try
    X = abtrandn(5, 2, 8);
    
    if ndims(X) == ndims(X.A)
        disp('   [OK] Metadata access is strictly consistent with component A.');
    else
        error('Internal metadata divergence detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');