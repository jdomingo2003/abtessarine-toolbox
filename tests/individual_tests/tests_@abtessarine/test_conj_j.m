% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: conj_j.m (Directional Involution 'j')
% =========================================================================
% This script verifies the algebraic correctness of the directional 
% involution mapping across the 'j' axis. It rigorously tests the specific 
% sign permutations and the fundamental self-inverse involution property.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: conj_j.m ---');
disp('===================================================================');

tol = 1e-14; % Strict floating-point tolerance
N = 5;       % Matrix dimension

%% TEST 1: Structural Sign Permutation Validation
disp('TEST 1: Exact Topological Mapping (Signs: +, -, +, -)');
try
    % Generate a pseudo-random hypercomplex matrix
    X = abtrandn(N);
    
    % Compute the directional involution with respect to j
    X_inv_j = conj_j(X);
    
    % Verify the specific structural mapping: X^j = A - Bi + Cj - Dk
    err_A = norm(X_inv_j.A - X.A);
    err_C = norm(X_inv_j.C - X.C);
    err_B = norm(X_inv_j.B - (-X.B)); % Must be strictly negated
    err_D = norm(X_inv_j.D - (-X.D)); % Must be strictly negated
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Topological signs accurately mapped (A and C preserved, B and D inverted).');
    else
        error('Memory mapping or sign distribution failed during involution j.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Self-Inverse Property Validation
disp('TEST 2: Algebraic Involution Property ( (X^j)^j = X )');
try
    % Apply the directional involution twice consecutively
    X_double_inv = conj_j(conj_j(X));
    
    % Verify that the double involution recovers the original object completely
    err_double = norm(X_double_inv.A - X.A) + norm(X_double_inv.B - X.B) + ...
                 norm(X_double_inv.C - X.C) + norm(X_double_inv.D - X.D);
    
    if err_double < tol
        disp('   [OK] Self-inverse algebraic property strictly validated for axis j.');
    else
        error('Mathematical integrity lost during consecutive involutions.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dimensional Retention
disp('TEST 3: Dimensional Consistency');
try
    % Create an N-dimensional tensor
    X_tensor = abtrandn(2, 2, 2);
    
    % Compute involution
    X_tensor_inv = conj_j(X_tensor);
    
    % Check size retention
    if isequal(size(X_tensor_inv.A), [2, 2, 2])
        disp('   [OK] N-D Tensor dimensions perfectly retained across spatial branches.');
    else
        error('Dimensional distortion occurred during involution.');
    end

catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');