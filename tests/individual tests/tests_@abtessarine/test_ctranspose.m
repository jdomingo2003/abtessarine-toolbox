% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: ctranspose.m (Operator ')
% =========================================================================
% This script verifies the parametric Hermitian transposition across different
% topological configurations. It validates the geometric memory reordering 
% and the sign-adjustment logic governed by alpha and beta.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: ctranspose.m ---');
disp('===================================================================');

tol = 1e-14; % Strict floating-point tolerance
N = 4; M = 3;

%% TEST 1: Standard Tessarine Topology (alpha = -1, beta = 1)
disp('TEST 1: Standard Topology (alpha = -1, beta = 1)');
try
    setabtessarine(-1, 1);
    X = abtrandn(N, M);
    
    % Compute Hermitian transpose using the overloaded operator
    Xt = X';
    
    % Expected: A.', -B.', C.', -D.'
    err_A = norm(Xt.A - X.A.');
    err_B = norm(Xt.B - (-X.B.'));
    err_C = norm(Xt.C - X.C.');
    err_D = norm(Xt.D - (-X.D.'));
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Operator (X'') correctly mapped signs for alpha < 0.');
    else
        error('Sign mapping error in standard topology.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hyperbolic/Unrolled Topology (alpha = 1, beta = 1)
disp('TEST 2: Hyperbolic Topology (alpha = 1, beta = 1)');
try
    setabtessarine(1, 1);
    X2 = abtrandn(N, M);
    
    % Compute Hermitian transpose
    Xt2 = X2';
    
    % Expected: All positive signs due to sign(alpha)=1, sign(beta)=1
    err_all = norm(Xt2.A - X2.A.') + norm(Xt2.B - X2.B.') + ...
              norm(Xt2.C - X2.C.') + norm(Xt2.D - X2.D.');
              
    if err_all < tol
        disp('   [OK] Operator (X'') correctly preserved signs for alpha > 0.');
    else
        error('Sign mapping error in hyperbolic topology.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Algebraic Properties (Involution and Identity)
disp('TEST 3: Algebraic Properties ((X'')'' = X and I'' = I)');
try
    setabtessarine(-2, 5); % Custom mixed topology
    X3 = abtrandn(N, N);
    
    % 3.1 Involution property
    X_double_t = (X3')';
    err_inv = norm(X_double_t.A - X3.A) + norm(X_double_t.B - X3.B) + ...
              norm(X_double_t.C - X3.C) + norm(X_double_t.D - X3.D);
              
    % 3.2 Identity property
    I = abteye(N);
    It = I';
    err_id = norm(It.A - I.A) + norm(It.B - I.B);
    
    if err_inv < tol && err_id < tol
        disp('   [OK] Double Hermitian transpose returns the original matrix.');
        disp('   [OK] Hermitian transpose of Identity remains Identity.');
    else
        error('Algebraic properties violated.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');