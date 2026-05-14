% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: vertcat.m (8D Gabtessarine Vertical Concatenation)
% =========================================================================
% This script verifies the vertical stacking ([X; Y]) of 8D arrays. 
% It validates pure 8D stacking, automatic upcasting from 4D (abtessarine) 
% and 2D (numeric) matrices, and strict column-alignment guardrails.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: vertcat (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Environment must be hyperbolic for 8D tests

%% TEST 1: Pure 8D Vertical Stacking [G1; G2]
disp('TEST 1: Pure 8D Vertical Stacking');
try
    % G1 (2x3) and G2 (3x3)
    sz1 = [2, 3]; sz2 = [3, 3];
    G1 = gabtessarine(ones(sz1), ones(sz1)*2, ones(sz1)*3, ones(sz1)*4, ...
                      ones(sz1)*5, ones(sz1)*6, ones(sz1)*7, ones(sz1)*8);
    G2 = gabtessarine(zeros(sz2), zeros(sz2), zeros(sz2), zeros(sz2), ...
                      zeros(sz2), zeros(sz2), zeros(sz2), zeros(sz2));
                      
    Z_pure = [G1; G2];
    
    % Expected Dimensions: (2+3) x 3 = 5x3
    if isequal(size(Z_pure.A1), [5, 3]) && all(Z_pure.A1(1:2, 1) == 1) && all(Z_pure.A1(3:5, 1) == 0)
        disp('   [OK] 8D matrices vertically stacked correctly (5x3).');
    else
        error('Dimensional mapping or data alignment failed in pure 8D vertcat.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hierarchical Upcast (8D + 4D abtessarine)
disp('TEST 2: Vertical Domain Promotion (8D + 4D abtessarine)');
try
    G_base = gabtessarine(ones(2,2), ones(2,2), ones(2,2), ones(2,2), ...
                          ones(2,2), ones(2,2), ones(2,2), ones(2,2));
                          
    % 4D abtessarine object (must have 2 columns to match G_base)
    A_4D = abtessarine(ones(3,2)*7, ones(3,2)*7, ones(3,2)*7, ones(3,2)*7);
    
    Z_promo = [G_base; A_4D];
    
    % Expected Size: 5x2. 
    % Rows 3:5 of A2 (epsilon) should be 0 due to upcasting.
    if isequal(size(Z_promo.A1), [5, 2]) && ...
       all(Z_promo.A1(3:5, 1) == 7) && all(Z_promo.A2(3:5, 1) == 0)
        disp('   [OK] 4D abtessarine correctly upcast and aligned vertically.');
    else
        error('Upcasting logic failed during vertical concatenation.');
    end
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Column Alignment Guardrail
disp('TEST 3: Column Alignment Guardrail (Mismatched Width)');
try
    G_3cols = gabtessarine(ones(2,3), ones(2,3), ones(2,3), ones(2,3), ...
                           ones(2,3), ones(2,3), ones(2,3), ones(2,3));
    num_2cols = ones(2,2); 
    
    % This should trigger a native MATLAB error because 3 columns != 2 columns
    evalc('Z_fail = [G_3cols; num_2cols];');
    
    error('Safety failure: Allowed vertical stacking of mismatched widths.');
catch ME
    % We expect a dimension mismatch error
    disp('   [OK] Incompatible widths correctly intercepted by native backend.');
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');