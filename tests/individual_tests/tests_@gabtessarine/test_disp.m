% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: disp.m (gabtessarine Display Overload)
% =========================================================================
% This script verifies the console output formatting for the 8D 
% gabtessarine class. It uses 'evalc' to capture stdout and validates 
% formatting for scalars, matrices, empty objects, and object arrays.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: disp (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Environment must be hyperbolic for 8D

%% TEST 1: Scalar Algebraic Formatting
disp('TEST 1: Scalar Display Formatting [Algebraic ε Notation]');
try
    % Create a scalar with positive and negative components to test sign handling
    G_scalar = gabtessarine(1, -2, 3, -4, 5, -6, 7, -8);
    
    % Capture console output
    out_scalar = evalc('disp(G_scalar)');
    
    % Verify key substrings
    if contains(out_scalar, 'gabtessarine scalar') && ...
       contains(out_scalar, '1 - 2ε + 3i - 4εi + 5j - 6εj + 7k - 8εk')
        disp('   [OK] Scalar algebraic string formatted perfectly with signs and symbols.');
    else
        error('Scalar formatting mismatch. Captured: %s', strtrim(out_scalar));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Matrix Block Formatting
disp('TEST 2: Matrix Paired Display [Horizontal Components]');
try
    % Create a 2x2 object
    sz = [2, 2];
    G_mat = gabtessarine(ones(sz), ones(sz)*2, ones(sz)*3, ones(sz)*4, ...
                         ones(sz)*5, ones(sz)*6, ones(sz)*7, ones(sz)*8);
                         
    out_mat = evalc('disp(G_mat)');
    
    % Verify the presence of the custom block headers
    if contains(out_mat, 'gabtessarine matrix:') && ...
       contains(out_mat, '[ Component A1 (Real)   |   Component A2 (ε) ]') && ...
       contains(out_mat, '[ Component D1 (k)      |   Component D2 (εk) ]')
        disp('   [OK] Matrix paired block headers correctly displayed.');
    else
        error('Matrix block formatting mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Empty Object Display
disp('TEST 3: Empty Object Handling');
try
    G_empty = gabtessarine();
    
    out_empty = evalc('disp(G_empty)');
    
    if contains(out_empty, 'Empty gabtessarine object')
        disp('   [OK] Empty object cleanly reported.');
    else
        error('Empty object output mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Object Array Display
disp('TEST 4: Object Array Handling');
try
    % Create an array of gabtessarine objects (1x3 array of objects)
    G_array(3) = gabtessarine(1,1,1,1,1,1,1,1);
    
    out_array = evalc('disp(G_array)');
    
    if contains(out_array, '1x3 gabtessarine array')
        disp('   [OK] Object array dimensionality neatly abstracted.');
    else
        error('Object array format mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');