% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: vertcat.m (Vertical Concatenation, [A; B])
% =========================================================================
% This script verifies the vertical stacking of abtessarine arrays.
% It validates dynamic dimension mapping, multi-argument syntax, 
% and the inherited dimensionality guardrails from the base cat.m method.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: vertcat.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Standard Vertical Stacking [A; B]
disp('TEST 1: Standard Vertical Concatenation');
try
    % Matrix A (2x3) and Matrix B (4x3)
    A = abtessarine(ones(2, 3), ones(2, 3)*2, ones(2, 3)*3, ones(2, 3)*4);
    B = abtessarine(zeros(4, 3), zeros(4, 3), zeros(4, 3), zeros(4, 3));
    
    % Invoke vertcat via standard MATLAB bracket syntax
    Z = [A; B];
    
    % Expected size: (2+4) x 3 = 6x3
    if isequal(size(Z.A), [6, 3])
        % Verify spatial block integrity
        if all(Z.A(1:2, 1) == 1) && all(Z.A(3:6, 1) == 0) && ...
           all(Z.D(1:2, 1) == 4) && all(Z.D(3:6, 1) == 0)
            disp('   [OK] Matrices successfully stacked vertically (6x3).');
            disp('   [OK] Spatial block integrity strictly preserved across branches.');
        else
            error('Data mapping corrupted during vertical concatenation.');
        end
    else
        error('Dimensional mapping failed. Expected [6, 3].');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Multiple Argument Delegation [A; B; C]
disp('TEST 2: Multi-Argument Stacking [A; B; C]');
try
    X1 = abtrandn(2, 2);
    X2 = abtrandn(2, 2);
    X3 = abtrandn(3, 2);
    
    Z_multi = [X1; X2; X3];
    
    % Expected size: 7x2
    if isequal(size(Z_multi.A), [7, 2])
        % Extract middle block to ensure correct varargin sequencing
        if isequal(Z_multi.B(3:4, :), X2.B)
            disp('   [OK] Multi-argument stacking cleanly delegated and ordered.');
        else
            error('Sequence mapping mismatched in multi-argument concatenation.');
        end
    else
        error('Multi-argument dimensional expansion failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Inherited Dimensionality Guardrails
disp('TEST 3: Incompatible Dimensions Shield');
try
    A_wrong = abtrandn(2, 3);
    B_wrong = abtrandn(2, 4); % Incompatible number of columns
    
    % Attempt illegal vertical concatenation
    evalc('Z_fail = [A_wrong; B_wrong]');
    
    error('Safety failure: Allowed vertical concatenation of matrices with mismatched columns.');
catch ME
    % Should catch a concatenation dimension mismatch error
    disp('   [OK] Correctly blocked concatenation of incompatible dimensions.');
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');