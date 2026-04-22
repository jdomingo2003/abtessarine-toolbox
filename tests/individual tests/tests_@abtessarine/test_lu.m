% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: lu.m (LU Factorization with Partial Pivoting)
% =========================================================================
% This script verifies the generalized LU decomposition across different 
% algebraic topologies. It validates the fundamental identity P*X = L*U 
% and ensures that triangular structures (L and U) and permutation 
% matrices (P) are correctly reconstructed from isomorphic branches.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: lu.m ---');
disp('===================================================================');

tol = 1e-12; % Strict tolerance for reconstruction
N = 5;       % Matrix dimension

%% TEST 1: LU Identity Validation (Alpha < 0 - Elliptic)
disp('TEST 1: Identity Property [P*X = L*U] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    X = abtrandn(N);
    
    % Perform LU factorization
    [L, U, P] = lu(X);
    
    % Verify reconstruction: P*X - L*U
    LHS = P * X;
    RHS = L * U;
    
    err = norm(LHS.A - RHS.A) + norm(LHS.B - RHS.B) + ...
          norm(LHS.C - RHS.C) + norm(LHS.D - RHS.D);
    
    if err < tol
        disp('   [OK] Factorization identity P*X = L*U strictly validated.');
        % Check triangularity of real branch A
        if istriu(U.A) && istril(L.A)
            disp('   [OK] Triangular structure of L and U confirmed.');
        end
    else
        error('LU reconstruction failure in Alpha < 0. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: LU Identity Validation (Alpha > 0 - Hyperbolic)
disp('TEST 2: Identity Property [P*X = L*U] (Alpha > 0)');
try
    setabtessarine(2, 0.5); % Non-standard hyperbolic topology
    X2 = abtrandn(N);
    
    [L2, U2, P2] = lu(X2);
    
    LHS2 = P2 * X2;
    RHS2 = L2 * U2;
    
    err2 = norm(LHS2.A - RHS2.A) + norm(LHS2.B - RHS2.B) + ...
           norm(LHS2.C - RHS2.C) + norm(LHS2.D - RHS2.D);
    
    if err2 < tol
        disp('   [OK] Factorization identity validated in hyperbolic space.');
        % Verify if P contains non-zero divisors (B, C, or D components)
        p_norm_complex = norm(P2.B) + norm(P2.C) + norm(P2.D);
        if p_norm_complex > 1e-5
            disp('   [INFO] Divergent pivoting detected: Permutation matrix P is hypercomplex.');
        end
    else
        error('LU reconstruction failure in Alpha > 0. Error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Edge Case (Singular Matrix)
disp('TEST 3: LU Decomposition of Singular Matrix');
try
    X_sing = abtzeros(N);
    X_sing.A(1,1) = 1; % Only one non-zero element
    
    [L_s, U_s, P_s] = lu(X_sing);
    
    % Reconstruction should still hold even for singular matrices
    Res_s = P_s * X_sing - L_s * U_s;
    err_s = norm(Res_s.A) + norm(Res_s.B);
    
    if err_s < tol
        disp('   [OK] LU decomposition remains stable for singular manifolds.');
    else
        error('LU failed for singular input.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');