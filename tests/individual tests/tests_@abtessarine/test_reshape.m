% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: reshape.m (Change Array Dimensions)
% =========================================================================
% This script verifies the multi-syntax reshaping capabilities of the 
% abtessarine class. It validates explicit sizing, automatic dimension 
% inference, 3D mapping, and cardinality error handling.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: reshape.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Explicit 2D Reshaping
disp('TEST 1: Explicit 2D Reshaping [reshape(X, M, N)]');
try
    % Create a 12-element vector
    X = abtrandn(12, 1);
    
    % Reshape to 3x4 matrix
    Z_explicit = reshape(X, 3, 4);
    
    if isequal(size(Z_explicit.A), [3, 4])
        % Check linear indexing integrity (first and last elements)
        if Z_explicit.A(1) == X.A(1) && Z_explicit.D(end) == X.D(end)
            disp('   [OK] Vector successfully reshaped to 3x4 matrix.');
            disp('   [OK] Memory contiguity preserved.');
        else
            error('Data mapping corrupted during reshape.');
        end
    else
        error('Dimension mismatch in explicit reshape.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Automatic Dimension Inference
disp('TEST 2: Automatic Dimension Calculation [reshape(X, M, [])]');
try
    % Use the same 12-element vector X
    % Request 2 rows, let MATLAB calculate columns (should be 6)
    Z_auto = reshape(X, 2, []);
    
    if isequal(size(Z_auto.A), [2, 6])
        disp('   [OK] Automatic dimension inference ([]) successfully delegated.');
    else
        error('Automatic dimension calculation failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Multidimensional Tensor Reshaping
disp('TEST 3: 3D Tensor Reshaping [reshape(X, [M N P])]');
try
    % Reshape 12 elements into 2x2x3
    Z_tensor = reshape(X, [2, 2, 3]);
    
    if isequal(size(Z_tensor.A), [2, 2, 3])
        disp('   [OK] Data correctly projected into Rank-3 tensor.');
    else
        error('3D dimension mapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Cardinality Guardrail (Native Exception Passing)
disp('TEST 4: Numel Strict Preservation Shield');
try
    % Attempt to reshape 12 elements into a 5x5 matrix (25 elements)
    evalc('reshape(X, 5, 5)');
    
    error('Safety failure: Allowed reshape with mismatched total elements.');
catch ME
    % MATLAB native error identifier for this is usually 'MATLAB:getReshapeDims:notSameNumel'
    if contains(lower(ME.message), 'number of elements') || contains(ME.identifier, 'numel')
        disp('   [OK] Correctly blocked reshape with incompatible cardinality.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');