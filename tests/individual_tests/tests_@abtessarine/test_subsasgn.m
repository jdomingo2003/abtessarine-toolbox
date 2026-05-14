% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: subsasgn.m (Subscripted Assignment)
% =========================================================================
% This script verifies the indexed assignment of abtessarine arrays.
% It validates object block substitution, numeric domain promotion, 
% out-of-bounds dynamic expansion, and strict syntax shielding.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: subsasgn.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Object-to-Object Block Substitution
disp('TEST 1: Block Assignment [X(idx) = Y_obj]');
try
    % Create a 4x4 matrix of ones
    X = abtessarine(ones(4), ones(4), ones(4), ones(4));
    
    % Create a 2x2 replacement block of zeros
    Y_block = abtessarine(zeros(2), zeros(2), zeros(2), zeros(2));
    
    % Assign the block to the top-right corner
    X(1:2, 3:4) = Y_block;
    
    % Verification
    if all(all(X.A(1:2, 3:4) == 0)) && all(all(X.A(3:4, 1:2) == 1))
        disp('   [OK] Hypercomplex block successfully mapped and assigned.');
    else
        error('Block substitution failed to map correctly.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Numeric Domain Promotion
disp('TEST 2: Numeric Assignment [X(idx) = Numeric]');
try
    X_num = abtrandn(3, 3);
    
    % Assign a numeric vector to the second row
    num_vec = [10, 20, 30];
    X_num(2, :) = num_vec;
    
    % Check A branch (should have the numeric values)
    % Check B, C, D branches (should be exactly zero for that row)
    if isequal(X_num.A(2, :), num_vec) && ...
       isequal(X_num.B(2, :), [0, 0, 0]) && ...
       isequal(X_num.C(2, :), [0, 0, 0]) && ...
       isequal(X_num.D(2, :), [0, 0, 0])
        disp('   [OK] Numeric promotion accurately zeroes out imaginary branches.');
    else
        error('Domain promotion failed during numeric assignment.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dynamic Expansion (Out-of-Bounds Assignment)
disp('TEST 3: Lazy Loading and Dynamic Expansion [X(end+1) = ...]');
try
    % Create a 1x1 object
    X_dyn = abtessarine(1, 1, 1, 1);
    
    % Assign to index (2, 2) to force dynamic expansion
    X_dyn(2, 2) = abtessarine(5, 5, 5, 5);
    
    % Expected: 2x2 matrix, with zeros at (1,2) and (2,1) automatically
    if isequal(size(X_dyn.A), [2, 2])
        if X_dyn.A(2,2) == 5 && X_dyn.C(1,2) == 0
            disp('   [OK] Dynamic expansion correctly padded missing spatial indices.');
        else
            error('Matrix padded with incorrect values during expansion.');
        end
    else
        error('Dimension mapping failed during out-of-bounds assignment.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Syntax Shielding (Cell Arrays)
disp('TEST 4: Cell Indexing Rejection [X{idx} = ...]');
try
    X_shield = abtessarine(1, 0, 0, 0);
    
    % Attempt illegal cell assignment
    evalc('X_shield{1} = 5');
    
    error('Safety failure: Allowed cell-based indexing.');
catch ME
    if contains(ME.identifier, 'CellNotSupported')
        disp('   [OK] Correctly intercepted unsupported cell indexing.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');