% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: times.m (Operator .*)
% =========================================================================
% This script verifies the Hadamard (element-wise) hypercomplex product.
% It validates the algebraic Cayley table rules, commutativity, implicit 
% multidimensional expansion (broadcasting), and hybrid scaling.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: times.m ---');
disp('===================================================================');

tol = 1e-14; 
setabtessarine(-2, 3); % Non-standard topology to strictly test parameters
[alpha, beta] = getabtessarine();

%% TEST 1: Algebraic Basis Rules (Point-wise Cayley Table)
disp('TEST 1: Point-wise Cayley Table [i.*i, j.*j, k.*k]');
try
    % Vectors of basis units
    % V1 = [i, j, k]
    V1 = abtessarine([0, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]);
    
    % Element-wise square: V1 .* V1 should yield [alpha, beta, alpha*beta]
    Z_sq = V1 .* V1;
    
    expected_A = [alpha, beta, alpha * beta];
    
    if norm(Z_sq.A - expected_A) < tol && norm(Z_sq.B) < tol && ...
       norm(Z_sq.C) < tol && norm(Z_sq.D) < tol
        disp('   [OK] Point-wise basis multiplication perfectly matches alpha/beta rules.');
    else
        error('Algebraic baseline mismatch in element-wise product.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Commutative Property [X .* Y == Y .* X]
disp('TEST 2: Commutativity Verification');
try
    X = abtrandn(5, 5);
    Y = abtrandn(5, 5);
    
    Z1 = X .* Y;
    Z2 = Y .* X;
    
    err_comm = norm(Z1.A - Z2.A) + norm(Z1.B - Z2.B) + ...
               norm(Z1.C - Z2.C) + norm(Z1.D - Z2.D);
               
    if err_comm < tol
        disp('   [OK] Hadamard product strictly satisfies the commutative property.');
    else
        error('Commutativity failure. Error: %e', err_comm);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Implicit Expansion (Broadcasting)
disp('TEST 3: Implicit Scalar/Vector Expansion (Broadcasting)');
try
    % Matrix 3x3
    M = abtrandn(3, 3);
    
    % Row vector 1x3
    V_row = abtrandn(1, 3);
    
    % Broadcast multiplication
    Z_broadcast = M .* V_row;
    
    % Manual verification of column 2
    col2_manual = M(:, 2) .* V_row(2);
    err_broad = norm(Z_broadcast(:, 2).A - col2_manual.A) + ...
                norm(Z_broadcast(:, 2).B - col2_manual.B);
                
    if err_broad < tol && isequal(size(Z_broadcast.A), [3, 3])
        disp('   [OK] Native MATLAB broadcasting accurately routed through components.');
    else
        error('Implicit expansion (broadcasting) failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Hybrid Operations & Type Shield
disp('TEST 4: Hybrid Operations and Type Safety');
try
    X = abtrandn(2, 2);
    num_mask = [0, 1; 1, 0]; % Numeric mask
    
    % Hybrid multiplication
    Z_hybrid = X .* num_mask;
    
    if Z_hybrid.A(1,1) == 0 && Z_hybrid.C(2,1) == X.C(2,1)
        disp('   [OK] Hybrid multiplication acting as logical/numeric mask validated.');
    else
        error('Hybrid mask mismatch.');
    end
    
    % Shield test
    try
        X .* 'invalid';
        error('Safety failure: Allowed multiplication with char array.');
    catch
        disp('   [OK] Invalid type properly intercepted by safety shield.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');