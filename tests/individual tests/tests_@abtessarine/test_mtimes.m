% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: mtimes.m (Operator *)
% =========================================================================
% This script verifies the fundamental hypercomplex matrix product. It 
% validates the algebraic basis rules (alpha, beta dependencies), 
% associative properties, and hybrid scaling with numeric types.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: mtimes.m ---');
disp('===================================================================');

tol = 1e-14; 
setabtessarine(-2, 3); % Non-standard parameters to stress the logic
[alpha, beta] = getabtessarine();

%% TEST 1: Algebraic Basis Verification
disp('TEST 1: Algebraic Basis Rules [i^2, j^2, k^2]');
try
    % Define fundamental units as abtessarine scalars
    ui = abtessarine(0, 1, 0, 0); % i
    uj = abtessarine(0, 0, 1, 0); % j
    uk = abtessarine(0, 0, 0, 1); % k
    
    % i * i = alpha
    res_i2 = ui * ui;
    err_i = abs(res_i2.A - alpha);
    
    % j * j = beta
    res_j2 = uj * uj;
    err_j = abs(res_j2.A - beta);
    
    % k * k = alpha * beta
    res_k2 = uk * uk;
    err_k = abs(res_k2.A - (alpha * beta));
    
    % i * j = k
    res_ij = ui * uj;
    err_ij = abs(res_ij.D - 1);
    
    if max([err_i, err_j, err_k, err_ij]) < tol
        disp('   [OK] Fundamental algebraic product rules strictly satisfied.');
    else
        error('Basis multiplication error detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Associative Property [(A*B)*C == A*(B*C)]
disp('TEST 2: Associative Property Verification');
try
    A = abtrandn(3, 3);
    B = abtrandn(3, 3);
    C = abtrandn(3, 3);
    
    Z1 = (A * B) * C;
    Z2 = A * (B * C);
    
    err_assoc = norm(Z1.A - Z2.A) + norm(Z1.B - Z2.B) + ...
                norm(Z1.C - Z2.C) + norm(Z1.D - Z2.D);
    
    if err_assoc < tol * 10 % Slight tolerance increase for multi-stage products
        disp('   [OK] Associative property (A*B)*C = A*(B*C) validated.');
    else
        error('Associativity failure. Deviation: %e', err_assoc);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Hybrid and Scalar Multiplication
disp('TEST 3: Hybrid Numeric-Abtessarine Scaling');
try
    X = abtrandn(2, 2);
    S = 5;
    R = [1, 2; 3, 4];
    
    % Scalar * Object
    Z_scalar = S * X;
    % Matrix * Object
    Z_mat = R * X;
    
    if isequal(Z_scalar.A, S * X.A) && isequal(Z_mat.A, R * X.A)
        disp('   [OK] Hybrid multiplication correctly delegated to BLAS.');
    else
        error('Hybrid scaling mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Dimension Guardrail
disp('TEST 4: Inner Dimension Mismatch Shield');
try
    A_wrong = abtrandn(4, 5);
    B_wrong = abtrandn(2, 3);
    
    evalc('A_wrong * B_wrong');
    
    error('Safety failure: Allowed multiplication with incompatible dimensions.');
catch ME
    if contains(ME.identifier, 'InnerDimensions')
        disp('   [OK] Correctly blocked incompatible matrix dimensions.');
    else
        fprintf('   [FAILED] Unexpected error: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');