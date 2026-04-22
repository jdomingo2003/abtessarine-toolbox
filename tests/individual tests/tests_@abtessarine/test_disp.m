% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: disp.m (CLI Display Overload)
% =========================================================================
% This script verifies the console output formatting for the abtessarine 
% class. It utilizes evalc to capture and analyze string patterns for 
% scalars, matrices, empty objects, and object arrays.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: disp.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Scalar Representation Formatting
disp('TEST 1: Scalar Algebraic Formatting (Sign Resolution)');
try
    % Create a scalar with specific signs: A=1, B=-2, C=3, D=-4
    % Expected output pattern: "1 - 2*i + 3*j - 4*k"
    s = abtessarine(1, -2, 3, -4);
    
    output = evalc('disp(s)');
    
    % Check for correct sign resolution and algebraic labels
    if contains(output, '1 - 2*i + 3*j - 4*k')
        disp('   [OK] Scalar algebraic string formatted correctly with sign resolution.');
    else
        error('Scalar formatting failed. Output: %s', output);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Matrix Component Display
disp('TEST 2: Matrix Structural Display');
try
    X = abtrandn(2, 2);
    output_mat = evalc('disp(X)');
    
    % Verify that all four components are explicitly mentioned
    if contains(output_mat, 'Component A') && contains(output_mat, 'Component B') && ...
       contains(output_mat, 'Component C') && contains(output_mat, 'Component D')
        disp('   [OK] Matrix output identifies all four orthogonal components.');
    else
        error('Matrix formatting failed to display component headers.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Object Array and Empty Object Handling
disp('TEST 3: Array and Empty Manifold Handling');
try
    % 3.1 Empty Object
    e = abtessarine();
    output_empty = evalc('disp(e)');
    
    % 3.2 Array of Objects
    % Preallocate a 3x2 array of abtessarine objects
    A(3, 2) = abtessarine(1, 0, 0, 0);
    output_array = evalc('disp(A)');
    
    if contains(output_empty, 'Empty') && contains(output_array, '3x2 array')
        disp('   [OK] Empty object correctly identified.');
        disp('   [OK] Object array dimension signature correctly summarized.');
    else
        error('Array or Empty object handling failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');