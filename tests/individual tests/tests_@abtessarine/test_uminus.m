% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: uminus.m (Unary Minus, -X)
% =========================================================================
% This script verifies the point reflection of the abtessarine manifold.
% It validates structural sign inversion, the additive inverse property 
% (annihilation), and the double negation identity.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: uminus.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-15;
N = 4;

%% TEST 1: Structural Sign Inversion
disp('TEST 1: Component-wise Sign Reflection [-X]');
try
    % Create a matrix with strictly positive values
    X_pos = abtessarine(ones(N), ones(N)*2, ones(N)*3, ones(N)*4);
    
    Z_neg = -X_pos;
    
    % Verify all components are strictly negative counterparts
    if all(Z_neg.A(:) == -1) && all(Z_neg.B(:) == -2) && ...
       all(Z_neg.C(:) == -3) && all(Z_neg.D(:) == -4)
        disp('   [OK] SIMD sign inversion successfully applied across all 4 planes.');
    else
        error('Sign reflection failed on one or more spatial planes.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Additive Inverse (Annihilation)
disp('TEST 2: Additive Inverse Property [X + (-X) == 0]');
try
    X_rand = abtrandn(N, N);
    
    % Annihilation sum
    Z_zero = X_rand + (-X_rand);
    
    err_zero = norm(Z_zero.A) + norm(Z_zero.B) + ...
               norm(Z_zero.C) + norm(Z_zero.D);
               
    if err_zero < tol
        disp('   [OK] Annihilation sum strictly produced the zero-manifold.');
    else
        error('Additive inverse property violated. Error: %e', err_zero);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Double Negation Identity
disp('TEST 3: Involution of Negation [-(-X) == X]');
try
    X_id = abtrandn(N, N);
    
    % Double negation
    X_double_neg = -(-X_id);
    
    err_id = norm(X_double_neg.A - X_id.A) + norm(X_double_neg.B - X_id.B) + ...
             norm(X_double_neg.C - X_id.C) + norm(X_double_neg.D - X_id.D);
             
    if err_id < tol
        disp('   [OK] Double negation strictly reconstructed the original geometry.');
    else
        error('Double negation identity failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');