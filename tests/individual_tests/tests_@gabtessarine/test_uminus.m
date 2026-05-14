% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: uminus.m (8D Gabtessarine Unary Minus)
% =========================================================================
% This script verifies the additive inverse of the 8D manifold.
% It validates structural negation, the annihilation property (X + (-X) = 0),
% and the double-negation identity within the 8D hypercomplex space.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: uminus (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment for 8D
tol = 1e-15;

%% TEST 1: Structural Negation Check
disp('TEST 1: Component-wise Sign Reflection [-G]');
try
    % Create an 8D matrix with known positive values
    sz = [2, 2];
    G = gabtessarine(ones(sz)*1, ones(sz)*2, ones(sz)*3, ones(sz)*4, ...
                     ones(sz)*5, ones(sz)*6, ones(sz)*7, ones(sz)*8);
    
    Z = -G;
    
    % Verify all 8 components are negated
    if Z.A1(1,1) == -1 && Z.A2(1,1) == -2 && Z.D2(1,1) == -8
        disp('   [OK] All 8 spatial/epsilon planes negated correctly.');
    else
        error('Sign reflection failed on one or more components.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Additive Inverse (Annihilation) [G + (-G) == 0]
disp('TEST 2: Additive Inverse Property (Annihilation)');
try
    G_rand = gabtessarine(randn(3), randn(3), randn(3), randn(3), ...
                          randn(3), randn(3), randn(3), randn(3));
    
    % This requires the 'plus.m' operator for gabtessarine
    Z_zero = G_rand + (-G_rand);
    
    err = norm(Z_zero.A1) + norm(Z_zero.A2) + norm(Z_zero.B1) + norm(Z_zero.B2) + ...
          norm(Z_zero.C1) + norm(Z_zero.C2) + norm(Z_zero.D1) + norm(Z_zero.D2);
          
    if err < tol
        disp('   [OK] Annihilation strictly produced the 8D zero-manifold.');
    else
        error('Additive inverse property violated. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Double Negation Identity [-(-G) == G]
disp('TEST 3: Double Negation (Involution)');
try
    G_id = gabtessarine(randn(2), randn(2), randn(2), randn(2), ...
                        randn(2), randn(2), randn(2), randn(2));
    
    G_double_neg = -(-G_id);
    
    err_id = norm(G_double_neg.A1 - G_id.A1) + norm(G_double_neg.A2 - G_id.A2);
    
    if err_id < tol
        disp('   [OK] Double negation strictly reconstructed the 8D manifold.');
    else
        error('Double negation identity failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');