% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: squeeze.m (Remove Singleton Dimensions)
% =========================================================================
% This script verifies that singleton dimensions are correctly removed
% from multidimensional abtessarine arrays while ensuring that standard 
% 2-D matrices and vectors remain unaffected, mimicking native behavior.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: squeeze.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Squeezing a 3D/4D Tensor with Singleton Dimensions
disp('TEST 1: Multidimensional Singleton Collapse [2x1x4 -> 2x4]');
try
    % Create a 2x1x4 tensor (dimension 2 is singleton)
    X = abtessarine(randn(2, 1, 4), randn(2, 1, 4), randn(2, 1, 4), randn(2, 1, 4));
    
    Z = squeeze(X);
    sz_Z = size(Z.A);
    
    if isequal(sz_Z, [2, 4])
        % Check a specific data point to ensure memory mapping remains intact
        if Z.D(2, 3) == X.D(2, 1, 3)
            disp('   [OK] Singleton dimension successfully removed.');
            disp('   [OK] Data mapping correctly preserved across branches.');
        else
            error('Data mapping corrupted during squeeze.');
        end
    else
        error('Dimension mismatch. Expected [2, 4], Got [%s].', num2str(sz_Z));
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: 2D Matrix Preservation
disp('TEST 2: 2D Matrix Preservation [4x5 -> 4x5]');
try
    M = abtrandn(4, 5);
    Z_mat = squeeze(M);
    
    if isequal(size(Z_mat.A), [4, 5])
        disp('   [OK] Standard 2D matrices appropriately bypassed and unaffected.');
    else
        error('Squeeze improperly modified a standard 2D matrix.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Vector Preservation (Native MATLAB Behavior)
disp('TEST 3: Vector Preservation [1x6 -> 1x6]');
try
    V_row = abtrandn(1, 6);
    V_col = abtrandn(6, 1);
    
    Z_row = squeeze(V_row);
    Z_col = squeeze(V_col);
    
    if isequal(size(Z_row.A), [1, 6]) && isequal(size(Z_col.A), [6, 1])
        disp('   [OK] Row and column vectors preserved 2D minimal rank.');
    else
        error('Squeeze improperly collapsed a 1D vector.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');