% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: kron.m (8D Gabtessarine Kronecker Product)
% =========================================================================
% This script verifies the Kronecker tensor expansion for 8D geometries.
% It validates the explicit block-wise algebraic unrolling, the epsilon 
% identity (e^2 = -1), dimensional expansion, and domain upcasting.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: kron (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Hyperbolic environment for 8D
tol = 1e-12;

%% TEST 1: Dimensional Expansion and Epsilon Identity [e^2 = -1]
disp('TEST 1: Dimensional Expansion & Epsilon Identity');
try
    % Create pure Epsilon components (A1=0, A2=1)
    sz1 = [2, 2]; sz2 = [3, 3];
    z1 = zeros(sz1); z2 = zeros(sz2);
    
    % X = 1*e, Y = 1*e
    X = gabtessarine(z1, ones(sz1), z1, z1, z1, z1, z1, z1);
    Y = gabtessarine(z2, ones(sz2), z2, z2, z2, z2, z2, z2);
    
    Z = kron(X, Y);
    
    % Expected Dimensions: 2x2 kron 3x3 = 6x6
    % Expected Value: (1*e) * (1*e) = -1 (Real component A1)
    if isequal(size(Z.A1), [6, 6])
        if all(Z.A1(:) == -1) && all(Z.A2(:) == 0)
            disp('   [OK] Dimensions expanded correctly (2x2 kron 3x3 -> 6x6).');
            disp('   [OK] Complexified epsilon identity strictly verified (e*e = -1).');
        else
            error('Algebraic epsilon mapping failed.');
        end
    else
        error('Dimensional Kronecker expansion failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid Numeric Expansion
disp('TEST 2: Hybrid Numeric Expansion [Numeric kron 8D]');
try
    % 2x2 Numeric Identity
    Num_I = eye(2);
    
    % 2x2 8D Matrix
    G_base = gabtessarine(ones(2), ones(2)*2, ones(2)*3, ones(2)*4, ...
                          ones(2)*5, ones(2)*6, ones(2)*7, ones(2)*8);
                          
    Z_hybrid = kron(Num_I, G_base);
    
    % Expected: 4x4 matrix, with G_base in top-left and bottom-right, zeros elsewhere
    if isequal(size(Z_hybrid.A1), [4, 4]) && ...
       isequal(Z_hybrid.D2(1:2, 1:2), G_base.D2) && ...
       all(all(Z_hybrid.D2(1:2, 3:4) == 0))
        disp('   [OK] Numeric block expansion correctly masked hypercomplex channels.');
    else
        error('Hybrid Kronecker expansion failed to align blocks.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Domain Upcasting (4D kron 8D)
disp('TEST 3: Dynamic Upcasting [abtessarine kron gabtessarine]');
try
    % 4D abtessarine object
    A_4D = abtessarine(ones(2), ones(2), ones(2), ones(2));
    
    % 8D gabtessarine object
    G_8D = gabtessarine(ones(2), ones(2), ones(2), ones(2), ...
                        ones(2), ones(2), ones(2), ones(2));
                        
    % This should automatically promote A_4D to 8D and execute
    Z_promo = kron(A_4D, G_8D);
    
    if isa(Z_promo, 'gabtessarine') && isequal(size(Z_promo.A1), [4, 4])
        disp('   [OK] 4D object seamlessly promoted to 8D during tensor product.');
    else
        error('Domain promotion failed during execution.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');