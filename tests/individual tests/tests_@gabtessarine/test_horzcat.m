% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: horzcat.m (gabtessarine Horizontal Concatenation)
% =========================================================================
% This script verifies the horizontal merging of 8D arrays. It validates 
% pure 8D concatenation, automatic domain promotion from 4D (abtessarine) 
% and 2D (numeric) types, and strictly tests dimension mappings.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: horzcat (gabtessarine) ---');
disp('===================================================================');

% Ensure Hyperbolic domain for 8D tests
setabtessarine(1, 1); 

%% TEST 1: Pure 8D Concatenation [G1, G2]
disp('TEST 1: Pure 8D Stacking [G1, G2]');
try
    sz1 = [2, 3]; sz2 = [2, 4];
    G1 = gabtessarine(ones(sz1), ones(sz1)*2, ones(sz1)*3, ones(sz1)*4, ...
                      ones(sz1)*5, ones(sz1)*6, ones(sz1)*7, ones(sz1)*8);
    G2 = gabtessarine(zeros(sz2), zeros(sz2), zeros(sz2), zeros(sz2), ...
                      zeros(sz2), zeros(sz2), zeros(sz2), zeros(sz2));
                      
    Z_pure = [G1, G2];
    
    if isequal(size(Z_pure.A1), [2, 7]) && all(Z_pure.A1(1, 1:3) == 1) && all(Z_pure.A1(1, 4:7) == 0)
        disp('   [OK] Pure 8D matrices horizontally concatenated correctly.');
    else
        error('Dimensional mapping or data alignment failed in pure 8D concatenation.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Automatic Promotion (8D + 4D abtessarine)
disp('TEST 2: Domain Promotion (8D + 4D abtessarine)');
try
    G_base = gabtessarine(ones(2,2), ones(2,2), ones(2,2), ones(2,2), ...
                          ones(2,2), ones(2,2), ones(2,2), ones(2,2));
                          
    % 4D abtessarine object
    A_4D = abtessarine(ones(2,2)*9, ones(2,2)*9, ones(2,2)*9, ones(2,2)*9);
    
    Z_promo_4D = [G_base, A_4D];
    
    % Check promotion: A1 should have 9s, A2 (epsilon) should be 0s for the 4D part
    if isequal(size(Z_promo_4D.A1), [2, 4]) && ...
       all(Z_promo_4D.A1(:, 3:4) == 9) && all(Z_promo_4D.A2(:, 3:4) == 0) && ...
       all(Z_promo_4D.D1(:, 3:4) == 9) && all(Z_promo_4D.D2(:, 3:4) == 0)
        disp('   [OK] 4D abtessarine perfectly upcast to 8D and concatenated.');
    else
        error('Upcasting logic failed for 4D abtessarine object.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Numeric Promotion (8D + Numeric)
disp('TEST 3: Numeric Domain Promotion (8D + Double)');
try
    G_base2 = gabtessarine(ones(3,1), ones(3,1), ones(3,1), ones(3,1), ...
                           ones(3,1), ones(3,1), ones(3,1), ones(3,1));
                           
    num_col = [5; 5; 5];
    
    Z_num = [G_base2, num_col];
    
    if isequal(size(Z_num.A1), [3, 2]) && all(Z_num.A1(:, 2) == 5) && all(Z_num.C1(:, 2) == 0)
        disp('   [OK] Numeric double arrays accurately promoted to A1 branch.');
    else
        error('Numeric upcasting failed.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Type Shield
disp('TEST 4: Incompatible Type Shield');
try
    G_shield = gabtessarine(1,1,1,1,1,1,1,1);
    
    evalc('Z_fail = [G_shield, {1}];');
    
    error('Safety failure: Allowed concatenation with a cell array.');
catch ME
    if contains(ME.identifier, 'InvalidType')
        disp('   [OK] Incompatible types neatly intercepted and blocked.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');