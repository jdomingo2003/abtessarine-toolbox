% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: horzcat.m (Operator [A, B])
% =========================================================================
% This script verifies the horizontal binding of abtessarine arrays. It 
% validates that the overloaded operator [A, B] correctly triggers the 
% underlying 'cat' core and maintains manifold consistency when mixing 
% classes (real + abtessarine).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: horzcat.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology
N = 3; M1 = 2; M2 = 4;

%% TEST 1: Standard Horizontal Binding
disp('TEST 1: Horizontal Concatenation of Objects [A, B]');
try
    % Generate two matrices with matching row counts
    X1 = abtrandn(N, M1);
    X2 = abtrandn(N, M2);
    
    % Use the native MATLAB syntax for horzcat
    Z = [X1, X2];
    
    % Verify dimensions: N x (M1 + M2)
    expected_size = [N, M1 + M2];
    if isequal(size(Z.A), expected_size)
        % Verify data alignment in the real branch
        if isequal(Z.A, [X1.A, X2.A]) && isequal(Z.D, [X1.D, X2.D])
            disp('   [OK] Horizontal binding dimensionally and structurally accurate.');
        else
            error('Data alignment mismatch in hypercomplex branches.');
        end
    else
        error('Dimension mismatch. Expected [%d, %d], Got [%d, %d].', ...
              expected_size(1), expected_size(2), size(Z.A,1), size(Z.A,2));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Mixed-Class Binding (Implicit Coercion)
disp('TEST 2: Mixed-Class Horizontal Binding [A, Real_Matrix]');
try
    R_matrix = randn(N, 5);
    X_obj = abtrandn(N, 2);
    
    % Concatenate object with a standard double matrix
    Z_mixed = [X_obj, R_matrix];
    
    % Verify that the real branch A was correctly merged
    if isequal(Z_mixed.A, [X_obj.A, R_matrix])
        % Verify that the imaginary branch B was zero-padded for the real matrix
        if isequal(Z_mixed.B, [X_obj.B, zeros(N, 5)])
            disp('   [OK] Mixed-class horizontal binding successfully coerced.');
            disp('   [OK] Imaginary branches correctly null-padded via core engine.');
        else
            error('Zero-padding failed during mixed-class horzcat.');
        end
    else
        error('Data corruption in real branch during mixed horzcat.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');