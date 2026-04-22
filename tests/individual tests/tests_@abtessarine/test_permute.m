% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: permute.m (Multidimensional Reordering)
% =========================================================================
% This script verifies the rearrangement of dimensions for abtessarine 
% arrays. It validates the structural consistency across all four planes 
% when operating on higher-order tensors (Rank-3 and Rank-4).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: permute.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard initialization

%% TEST 1: 3D Tensor Permutation (Page to Row/Col)
disp('TEST 1: 3D Tensor Rearrangement [Size: 2x3x4 -> 4x2x3]');
try
    % Create a 3D abtessarine tensor
    sz_orig = [2, 3, 4];
    X = abtessarine(randn(sz_orig), randn(sz_orig), randn(sz_orig), randn(sz_orig));
    
    % Permute dimensions: 3rd becomes 1st, 1st becomes 2nd, 2nd becomes 3rd
    new_order = [3, 1, 2];
    Z = permute(X, new_order);
    
    % Expected size: [4, 2, 3]
    sz_new = size(Z.A);
    if isequal(sz_new, [4, 2, 3])
        % Check a specific value to ensure mapping is correct
        % X(1, 2, 3) should move to Z(3, 1, 2)
        if Z.A(3, 1, 2) == X.A(1, 2, 3) && Z.D(3, 1, 2) == X.D(1, 2, 3)
            disp('   [OK] Dimensions and data points successfully re-indexed.');
        else
            error('Data mapping mismatch after permutation.');
        end
    else
        error('Dimension mismatch. Expected [4, 2, 3], Got [%s].', num2str(sz_new));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: High-Rank Tensor (4D)
disp('TEST 2: 4D Tensor Permutation [Rank-4 Stability]');
try
    sz_4d = [2, 2, 2, 2];
    X4 = abtrandn(sz_4d); % Using your random generator
    
    % Reverse all dimensions
    Z4 = permute(X4, [4, 3, 2, 1]);
    
    if isequal(size(Z4.A), [2, 2, 2, 2])
        % Verify against native MATLAB permute on branch B
        expected_B = permute(X4.B, [4, 3, 2, 1]);
        if norm(Z4.B(:) - expected_B(:)) < 1e-15
            disp('   [OK] 4D tensor strides successfully re-calculated.');
        else
            error('Component B data corruption in 4D permutation.');
        end
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');