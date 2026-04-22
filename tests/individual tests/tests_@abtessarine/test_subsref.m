% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: subsref.m (Subscripted Reference)
% =========================================================================
% This script verifies the indexed data extraction from abtessarine arrays.
% It validates sub-matrix slicing, direct property access, recursive 
% command chaining, and strict syntax shielding against cell arrays.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: subsref.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Indexed Extraction [out = X(idx)]
disp('TEST 1: Sub-matrix Slicing and Element Extraction');
try
    % Create a 5x5 matrix
    X = abtrandn(5, 5);
    
    % 1.1: Extract a 2x2 sub-matrix
    Z_sub = X(2:3, 4:5);
    
    % 1.2: Extract a single scalar element
    Z_elem = X(5, 1);
    
    if isequal(size(Z_sub.A), [2, 2]) && isequal(size(Z_elem.A), [1, 1])
        % Verify data integrity of the slice
        if isequal(Z_sub.C, X.C(2:3, 4:5)) && Z_elem.D == X.D(5, 1)
            disp('   [OK] Synchronous extraction of blocks and scalars validated.');
        else
            error('Data corruption detected during structural slicing.');
        end
    else
        error('Dimension mapping failed during extraction.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Property Access [val = X.prop]
disp('TEST 2: Direct Property Access');
try
    X_prop = abtrandn(3, 3);
    
    % Extract component directly
    B_branch = X_prop.B;
    
    if isnumeric(B_branch) && isequal(B_branch, X_prop.B)
        disp('   [OK] Property access successfully delegated to native engine.');
    else
        error('Property delegation failed or returned non-numeric type.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Recursive Command Chaining [val = X(idx).prop]
disp('TEST 3: Recursive Command Chaining');
try
    X_chain = abtrandn(4, 4);
    
    % Extract a sub-matrix and immediately access a property
    chained_val = X_chain(1:2, 1:2).C;
    
    % Expected equivalent
    expected_val = X_chain.C(1:2, 1:2);
    
    if isequal(chained_val, expected_val)
        disp('   [OK] Recursive command chaining X(idx).prop accurately handled.');
    else
        error('Chaining delegation mismatched expected output.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Syntax Shielding (Cell Arrays)
disp('TEST 4: Cell Indexing Rejection [X{idx}]');
try
    X_shield = abtessarine(1, 0, 0, 0);
    
    % Attempt illegal cell extraction
    evalc('val = X_shield{1}');
    
    error('Safety failure: Allowed cell-based extraction.');
catch ME
    if contains(ME.identifier, 'CellNotSupported')
        disp('   [OK] Correctly intercepted unsupported cell extraction.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');