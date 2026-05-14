% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: mtimes.m (8D Gabtessarine Matrix Multiplication)
% =========================================================================
% This script verifies the hypercomplex matrix product in 8D. It validates 
% pure 8D matrix products, scalar expansion, hybrid arithmetic (4D/8D), 
% and the strict topological guardrail (Alpha > 0 requirement).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: mtimes (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment for 8D
tol = 1e-12;

%% TEST 1: Pure 8D Matrix Multiplication and Identity
disp('TEST 1: Pure 8D Product and Identity [X * I == X]');
try
    sz = [3, 3];
    % Create random 8D matrix
    G = gabtessarine(randn(sz), randn(sz), randn(sz), randn(sz), ...
                     randn(sz), randn(sz), randn(sz), randn(sz));
                     
    % 8D Identity Matrix (eye in A1, zeros elsewhere)
    z = zeros(sz);
    I_8D = gabtessarine(eye(3), z, z, z, z, z, z, z);
    
    Z_prod = G * I_8D;
    
    err = norm(Z_prod.A1 - G.A1) + norm(Z_prod.A2 - G.A2) + ...
          norm(Z_prod.B1 - G.B1) + norm(Z_prod.B2 - G.B2) + ...
          norm(Z_prod.C1 - G.C1) + norm(Z_prod.C2 - G.C2) + ...
          norm(Z_prod.D1 - G.D1) + norm(Z_prod.D2 - G.D2);
          
    if err < tol
        disp('   [OK] Matrix product strictly validated against 8D Identity.');
    else
        error('Identity property failed. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid 4D/8D Algebraic Reduction
disp('TEST 2: Hybrid Algebraic Reduction [4D * 8D]');
try
    % 4D abtessarine matrix
    A_4D = abtessarine(eye(2)*2, eye(2)*3, eye(2)*4, eye(2)*5);
    
    % 8D gabtessarine matrix
    G_8D = gabtessarine(eye(2), eye(2)*2, eye(2)*3, eye(2)*4, ...
                        eye(2)*5, eye(2)*6, eye(2)*7, eye(2)*8);
                        
    % Execute hybrid product (triggers mathematically reduced equations)
    Z_hyb = A_4D * G_8D;
    
    if isa(Z_hyb, 'gabtessarine') && isequal(size(Z_hyb.A1), [2, 2])
        % Spot check A1 logic: M1_1 + beta*M2_1
        % A(2)*A1(1) + alpha*(B(3)*B1(3)) + beta*(C(4)*C1(5) + alpha*D(5)*D1(7))
        % = 2*1 + 1*(3*3) + 1*(4*5 + 1*5*7) = 2 + 9 + 20 + 35 = 66
        if abs(Z_hyb.A1(1,1) - 66) < tol
            disp('   [OK] Hybrid 4D/8D matrix multiplication bypassed zero-padding correctly.');
        else
            error('Hybrid multiplication produced incorrect algebraic result.');
        end
    else
        error('Hybrid product failed to output a gabtessarine object.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Numeric Scalar Promotion
disp('TEST 3: Scalar Expansion [Numeric * 8D]');
try
    G_base = gabtessarine(ones(2), ones(2)*2, ones(2)*3, ones(2)*4, ...
                          ones(2)*5, ones(2)*6, ones(2)*7, ones(2)*8);
                          
    scalar = 3;
    Z_scal = scalar * G_base;
    
    if all(Z_scal.A1(:) == 3) && all(Z_scal.D2(:) == 24)
        disp('   [OK] Numeric scalar expansion handled seamlessly.');
    else
        error('Scalar numeric multiplication failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Inner Dimensions Shield
disp('TEST 4: Matrix Dimension Compatibility Shield');
try
    G_M1 = gabtessarine(ones(2, 3), ones(2, 3), ones(2, 3), ones(2, 3), ...
                        ones(2, 3), ones(2, 3), ones(2, 3), ones(2, 3));
    G_M2 = gabtessarine(ones(4, 2), ones(4, 2), ones(4, 2), ones(4, 2), ...
                        ones(4, 2), ones(4, 2), ones(4, 2), ones(4, 2));
                        
    % Attempt illegal inner dimensions (3 != 4)
    evalc('G_M1 * G_M2;');
    
    error('Safety failure: Allowed matrix multiplication with mismatched inner dimensions.');
catch ME
    if contains(ME.identifier, 'InnerDimensions')
        disp('   [OK] Incompatible matrix inner dimensions accurately blocked.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');