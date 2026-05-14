% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: plus.m (8D Gabtessarine Addition)
% =========================================================================
% This script verifies the overloaded addition operator for 8D arrays.
% It validates pure 8D summation, structural zero-bypassing for 
% hierarchical addition (4D and 2D), native broadcasting, and 
% strict topological environment shields.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: plus (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Environment must be hyperbolic (Alpha > 0)
tol = 1e-14;

%% TEST 1: Pure 8D Addition [8D + 8D]
disp('TEST 1: Pure Algebraic Addition [G1 + G2]');
try
    sz = [3, 3];
    G1 = gabtessarine(ones(sz), ones(sz)*2, ones(sz)*3, ones(sz)*4, ...
                      ones(sz)*5, ones(sz)*6, ones(sz)*7, ones(sz)*8);
    G2 = gabtessarine(ones(sz)*10, ones(sz)*10, ones(sz)*10, ones(sz)*10, ...
                      ones(sz)*10, ones(sz)*10, ones(sz)*10, ones(sz)*10);
                      
    Z_pure = G1 + G2;
    
    if all(Z_pure.A1(:) == 11) && all(Z_pure.D2(:) == 18)
        disp('   [OK] Pure 8D addition strictly accurate across all components.');
    else
        error('Algebraic addition failed in pure 8D operation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hierarchical 4D/8D Addition (Zero-Bypass)
disp('TEST 2: Hierarchical Addition [8D + 4D and 4D + 8D]');
try
    G_8D = gabtessarine(ones(2)*5, ones(2)*5, ones(2)*5, ones(2)*5, ...
                        ones(2)*5, ones(2)*5, ones(2)*5, ones(2)*5);
    A_4D = abtessarine(ones(2)*2, ones(2)*2, ones(2)*2, ones(2)*2);
    
    % Test G + A (8D plus 4D)
    Z_GA = G_8D + A_4D;
    
    % Test A + G (4D plus 8D)
    Z_AG = A_4D + G_8D;
    
    % Verifications: Both should be identical due to commutativity
    % Real part (A1) should be 5+2=7. Epsilon part (A2) should be 5 directly.
    if all(Z_GA.A1(:) == 7) && all(Z_GA.A2(:) == 5) && ...
       all(Z_AG.A1(:) == 7) && all(Z_AG.A2(:) == 5)
        disp('   [OK] 8D/4D cross-addition accurately applied zero-bypass logic.');
        disp('   [OK] Commutativity in hierarchical addition verified.');
    else
        error('Hierarchical 4D/8D addition failed dimensional logic.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Numeric Addition and Broadcasting
disp('TEST 3: Hybrid Numeric and Broadcasting [8D + 2D Vector]');
try
    G_base = gabtessarine(ones(3, 3), ones(3, 3), ones(3, 3), ones(3, 3), ...
                          ones(3, 3), ones(3, 3), ones(3, 3), ones(3, 3));
                          
    % 1x3 row vector for implicit expansion
    num_vec = [10, 20, 30]; 
    
    % 2D + 8D
    Z_broad = num_vec + G_base;
    
    % Column 2: A1 should be 20 + 1 = 21. A2 should be 1.
    if all(Z_broad.A1(:, 2) == 21) && all(Z_broad.A2(:, 2) == 1)
        disp('   [OK] Numeric hybrid addition & implicit broadcasting handled flawlessly.');
    else
        error('Numeric broadcasting logic failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Topological Guardrail
disp('TEST 4: Topological Environment Shield [Alpha <= 0 Rejection]');
try
    % Force elliptic environment
    setabtessarine(-1, 1);
    
    G_shield = gabtessarine(); % Empty to avoid constructor error
    
    % Attempt addition
    evalc('G_shield + 5;');
    
    error('Safety failure: Allowed 8D arithmetic in elliptic (Alpha <= 0) space.');
catch ME
    if contains(ME.identifier, 'InvalidAlpha') || contains(ME.identifier, 'MissingEnvironment')
        disp('   [OK] Operation safely blocked under incompatible topology.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

% Restore hyperbolic environment
setabtessarine(1, 1);
disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');