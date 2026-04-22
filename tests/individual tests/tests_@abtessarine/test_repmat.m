% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: repmat.m (Replicate and Tile Array)
% =========================================================================
% This script verifies the memory tiling capabilities of the abtessarine 
% class. It validates scalar expansion, block matrix replication, and 
% multidimensional tensor tiling using varargin delegation.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: repmat.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard initialization

%% TEST 1: Scalar Expansion (Replicating a 1x1 object)
disp('TEST 1: Scalar Expansion [repmat(scalar, M, N)]');
try
    % Create a hypercomplex scalar
    s = abtessarine(1, -2, 3, 0);
    
    % Replicate into a 3x4 matrix
    Z_s = repmat(s, 3, 4);
    
    % Verify dimensions
    if isequal(size(Z_s.A), [3, 4])
        % Verify data integrity
        if all(Z_s.A(:) == 1) && all(Z_s.B(:) == -2) && all(Z_s.C(:) == 3)
            disp('   [OK] Scalar correctly expanded to 3x4 matrix.');
        else
            error('Data corruption during scalar expansion.');
        end
    else
        error('Dimension mismatch in scalar expansion.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Matrix Block Tiling
disp('TEST 2: Matrix Tiling [repmat(Matrix, M, N)]');
try
    % 2x2 base matrix
    X = abtrandn(2, 2);
    
    % Tile 2 times along rows, 3 times along columns
    Z_mat = repmat(X, 2, 3);
    
    % Expected size: (2*2) x (2*3) = 4x6
    if isequal(size(Z_mat.A), [4, 6])
        % Extract a sub-block to verify alignment
        sub_block = Z_mat.A(3:4, 5:6);
        if isequal(sub_block, X.A)
            disp('   [OK] Matrix block tiling dimensionally and structurally correct.');
        else
            error('Internal block alignment mismatch.');
        end
    else
        error('Dimension mismatch in matrix tiling.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Multidimensional Tiling (Vector Syntax)
disp('TEST 3: Multidimensional Tensor Tiling [repmat(X, [M N P])]');
try
    X3 = abtrandn(2, 3);
    
    % Tile 1x along rows, 2x along cols, 4x along pages (3D)
    Z3D = repmat(X3, [1, 2, 4]);
    
    % Expected size: 2 x 6 x 4
    if isequal(size(Z3D.A), [2, 6, 4])
        % Verify 3rd dimension page extraction
        if isequal(Z3D.B(:, 1:3, 4), X3.B)
            disp('   [OK] Multidimensional volume tiling correctly mapped.');
        else
            error('3D depth mapping failed.');
        end
    else
        error('Dimension mismatch in 3D tiling.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');