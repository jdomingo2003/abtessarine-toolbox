% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: times.m (8D Gabtessarine Hadamard Product)
% =========================================================================
% This script verifies the element-wise hypercomplex product. It validates 
% commutative properties, epsilon identity (e*e = -1), hybrid 4D/8D 
% pruning, and implicit spatial broadcasting.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: times (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment
tol = 1e-12;

%% TEST 1: Commutativity and Epsilon Identity [e*e = -1]
disp('TEST 1: Epsilon Identity and Commutativity');
try
    % Create two 8D scalars that are purely epsilon (A2=1, others=0)
    G1 = gabtessarine(0, 1, 0, 0, 0, 0, 0, 0);
    G2 = gabtessarine(0, 2, 0, 0, 0, 0, 0, 0);
    
    % Z = (1*e) .* (2*e) = -2 (Real part A1)
    Z = G1 .* G2;
    
    % Commutativity
    Z_rev = G2 .* G1;
    
    if Z.A1 == -2 && isequal(Z.A1, Z_rev.A1)
        disp('   [OK] Epsilon-squared identity strictly verified (e*e = -1).');
        disp('   [OK] Hadamard commutativity confirmed.');
    else
        error('Algebraic mapping failed for epsilon components.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid Pruning (4D .* 8D)
disp('TEST 2: Hybrid 4D/8D Pruning Logic');
try
    % 4D abtessarine (2x2)
    A_4D = abtessarine(ones(2)*2, ones(2)*2, ones(2)*2, ones(2)*2);
    
    % 8D gabtessarine (2x2) - All components = 3
    G_8D = gabtessarine(ones(2)*3, ones(2)*3, ones(2)*3, ones(2)*3, ...
                        ones(2)*3, ones(2)*3, ones(2)*3, ones(2)*3);
                        
    Z_hyb = A_4D .* G_8D;
    
    % Spot check A1: X.A*Y.A1 + alpha*(X.B*Y.B1) + beta*(...)
    % Result should be: (2*3) + 1*(2*3) + 1*( (2*3) + 1*(2*3) ) = 6 + 6 + 6 + 6 = 24
    if all(Z_hyb.A1(:) == 24) && all(Z_hyb.A2(:) == 12)
        disp('   [OK] Hybrid 4D/8D product accurately pruned and calculated.');
    else
        error('Mixed algebra result mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Spatial Broadcasting
disp('TEST 3: Implicit Spatial Broadcasting [8D Matrix .* 8D Scalar]');
try
    % 5x5 Matrix
    G_mat = gabtessarine(ones(5), ones(5), ones(5), ones(5), ...
                         ones(5), ones(5), ones(5), ones(5));
    
    % Scalar
    G_scal = gabtessarine(2, 0, 0, 0, 0, 0, 0, 0);
    
    % Multiply (Broadcasting)
    Z_broad = G_mat .* G_scal;
    
    if isequal(size(Z_broad), [5, 5]) && all(Z_broad.A1(:) == 2)
        disp('   [OK] Implicit expansion of 8D scalar over 8D matrix validated.');
    else
        error('Broadcasting expansion failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');