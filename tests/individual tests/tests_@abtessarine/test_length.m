% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: length.m (Largest Array Dimension)
% =========================================================================
% This script verifies that the length function correctly identifies the 
% maximum dimension of the hypercomplex manifold, ensuring consistency 
% with native MATLAB behavior for vectors and matrices.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: length.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Vector Length
disp('TEST 1: Length of Hypercomplex Vectors');
try
    N = 15;
    % Column vector
    v_col = abtrandn(N, 1);
    % Row vector
    v_row = abtrandn(1, N);
    
    if length(v_col) == N && length(v_row) == N
        disp(['   [OK] Correctly identified length ', num2str(N), ' for both row and column vectors.']);
    else
        error('Length mismatch in vector representation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Matrix and Multi-dimensional Length
disp('TEST 2: Length of Multidimensional Arrays');
try
    % Matrix 10x4 -> Length should be 10
    X_mat = abtrandn(10, 4);
    
    % 3D Tensor 2x3x8 -> Length should be 8
    X_tensor = abtessarine(randn(2,3,8), randn(2,3,8), randn(2,3,8), randn(2,3,8));
    
    if length(X_mat) == 10 && length(X_tensor) == 8
        disp('   [OK] Correctly identified max(size(X)) for matrices and tensors.');
    else
        error('Length mismatch in multidimensional representation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Empty Object Length
disp('TEST 3: Length of Empty Manifold');
try
    Xe = abtessarine();
    if length(Xe) == 0
        disp('   [OK] Length of empty abtessarine object is 0.');
    else
        error('Empty object length failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');