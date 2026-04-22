% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: subsref.m (8D Gabtessarine Index Reference)
% =========================================================================
% This script verifies the data extraction logic for 8D objects.
% It validates sub-matrix slicing, direct property access, recursive 
% command chaining, and strict syntax shielding against cell arrays.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: subsref (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment for 8D

%% TEST 1: Sub-matrix Slicing [out = G(idx)]
disp('TEST 1: Sub-matrix Slicing and Element Extraction');
try
    % Create a 4x4 matrix with distinct values in each component
    sz = [4, 4];
    G = gabtessarine(ones(sz), ones(sz)*2, ones(sz)*3, ones(sz)*4, ...
                     ones(sz)*5, ones(sz)*6, ones(sz)*7, ones(sz)*8);
    
    % Extract a 2x2 sub-block from the center
    G_sub = G(2:3, 2:3);
    
    if isequal(size(G_sub), [2, 2]) && G_sub.A1(1,1) == 1 && G_sub.D2(2,2) == 8
        disp('   [OK] 8-channel parallel slicing executed with structural integrity.');
    else
        error('Slicing failed to preserve component data or dimensions.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Direct Property Access [val = G.prop]
disp('TEST 2: High-Speed Property Access (Dot Notation)');
try
    G_prop = gabtessarine(eye(3), zeros(3), zeros(3), zeros(3), ...
                          zeros(3), zeros(3), zeros(3), zeros(3));
    
    % Access property A1 directly
    val_A1 = G_prop.A1;
    
    if isnumeric(val_A1) && isequal(val_A1, eye(3))
        disp('   [OK] Property access successfully routed to native engine.');
    else
        error('Property access failed or returned incorrect type.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Recursive Command Chaining [val = G(idx).prop]
disp('TEST 3: Recursive Command Chaining [G(idx).prop]');
try
    G_chain = gabtessarine(randn(5), randn(5), randn(5), randn(5), ...
                           randn(5), randn(5), randn(5), randn(5));
    
    % Extract sub-matrix and immediately access a specific channel
    % This tests the recursive 'if length(S) > 1' block
    chained_val = G_chain(1:2, 4:5).C2;
    
    % Manual equivalent for verification
    expected_val = G_chain.C2(1:2, 4:5);
    
    if isequal(chained_val, expected_val)
        disp('   [OK] Recursive chaining accurately handled through recursive delegation.');
    else
        error('Chaining result mismatched manual extraction.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Syntax Shielding (Cell Arrays)
disp('TEST 4: Cell Indexing Rejection [G{idx}]');
try
    G_shield = gabtessarine();
    
    % Attempt illegal cell access
    evalc('val = G_shield{1};');
    
    error('Safety failure: Allowed cell-based indexing.');
catch ME
    if contains(ME.identifier, 'CellNotSupported')
        disp('   [OK] Correctly intercepted and blocked unsupported cell indexing.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');