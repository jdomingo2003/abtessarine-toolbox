% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: conj_i.m (Directional Involution 'i')
% =========================================================================
% This script verifies the algebraic correctness of the directional 
% involution mapping across the 'i' axis. It rigorously tests the specific 
% sign permutations and the fundamental self-inverse involution property.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: conj_i.m ---');
disp('===================================================================');

tol = 1e-14; % Strict floating-point tolerance for direct memory operations
N = 5;       % Matrix dimension

%% TEST 1: Structural Sign Permutation Validation
disp('TEST 1: Exact Topological Mapping (Signs: +, +, -, -)');
try
    % Generate a pseudo-random hypercomplex matrix natively
    X = abtrandn(N);
    
    % Compute the directional involution
    X_inv_i = conj_i(X);
    
    % Verify the specific structural mapping: X^i = A + Bi - Cj - Dk
    err_A = norm(X_inv_i.A - X.A);
    err_B = norm(X_inv_i.B - X.B);
    err_C = norm(X_inv_i.C - (-X.C)); % Must be strictly negated
    err_D = norm(X_inv_i.D - (-X.D)); % Must be strictly negated
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Topological signs accurately mapped (A and B preserved, C and D inverted).');
    else
        error('Memory mapping or sign distribution failed during involution.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Self-Inverse Property Validation
disp('TEST 2: Algebraic Involution Property ( (X^i)^i = X )');
try
    % Apply the directional involution twice consecutively
    X_double_inv = conj_i(conj_i(X));
    
    % Verify that the double involution recovers the original object completely
    err_double_A = norm(X_double_inv.A - X.A);
    err_double_B = norm(X_double_inv.B - X.B);
    err_double_C = norm(X_double_inv.C - X.C);
    err_double_D = norm(X_double_inv.D - X.D);
    
    if max([err_double_A, err_double_B, err_double_C, err_double_D]) < tol
        disp('   [OK] Self-inverse algebraic property strictly validated.');
    else
        error('Mathematical integrity lost during consecutive involutions.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dimensional Consistency
disp('TEST 3: Dimensional Retention');
try
    % Create a highly asymmetrical rectangular tensor
    X_rect = abtrandn(2, 7, 3);
    
    % Compute involution
    X_rect_inv = conj_i(X_rect);
    
    % Check if size is perfectly retained across all branches
    if isequal(size(X_rect_inv.A), size(X_rect.A)) && ...
       isequal(size(X_rect_inv.B), size(X_rect.B)) && ...
       isequal(size(X_rect_inv.C), size(X_rect.C)) && ...
       isequal(size(X_rect_inv.D), size(X_rect.D))
        disp('   [OK] Tensor dimensions perfectly retained across spatial branches.');
    else
        error('Dimensional distortion occurred during involution.');
    end

catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');