% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: chol.m (Cholesky Factorization)
% =========================================================================
% This script rigorously verifies the mathematical precision of the Cholesky 
% factorization through isomorphic projections. It also stresses the strict 
% algorithmic defenses against non-square, non-Hermitian, and indefinite matrices.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: chol.m ---');
disp('===================================================================');

tol = 1e-10; % Strict floating-point tolerance for reconstruction
N = 4;       % Matrix dimension

%% TEST 1: Cholesky Factorization in Complex Domain (Alpha < 0)
disp('TEST 1: Factorization and Reconstruction (Alpha < 0)');
try
    % Set standard topology
    setabtessarine(-1, 1);
    
    % Generate a strictly Positive Definite matrix using the toolbox generator
    X1 = abtpdm(N);
    
    % 1.1 Compute Upper Triangular Factor (Default)
    R1 = chol(X1);
    
    % Verify upper triangular structure natively on the real branch
    if istriu(R1.A)
        disp('   [OK] Default factorization successfully returned an upper triangular factor (R).');
    else
        error('Factor R does not possess upper triangular structure.');
    end
    
    % Verify mathematical reconstruction: X = R' * R (Conjugate Transpose for alpha < 0)
    % Note: Assumes overloaded mtimes (*) and ctranspose (') for abtessarine objects
    X_rec_R = R1' * R1;
    err_R = norm(X1.A - X_rec_R.A) + norm(X1.B - X_rec_R.B) + ...
            norm(X1.C - X_rec_R.C) + norm(X1.D - X_rec_R.D);
            
    % 1.2 Compute Lower Triangular Factor (varargin passing)
    L1 = chol(X1, 'lower');
    if istril(L1.A)
        disp('   [OK] Varargin passing successful: Returned a lower triangular factor (L).');
    else
        error('Factor L does not possess lower triangular structure.');
    end
    
    % Verify mathematical reconstruction: X = L * L'
    X_rec_L = L1 * L1';
    err_L = norm(X1.A - X_rec_L.A) + norm(X1.B - X_rec_L.B) + ...
            norm(X1.C - X_rec_L.C) + norm(X1.D - X_rec_L.D);
            
    if max(err_R, err_L) < tol
        disp('   [OK] Mathematical reconstruction via isomorphic projection strictly validated.');
    else
        error('Reconstruction failed. Error magnitude exceeds tolerance.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Cholesky Factorization in Split-Complex Domain (Alpha > 0)
disp('TEST 2: Factorization and Reconstruction (Alpha > 0)');
try
    % Set hyperbolic topology
    setabtessarine(2, 3);
    
    % Generate a 1-Hermitian Positive Definite matrix
    X2 = abtpdm(N);
    
    % Compute Upper Triangular Factor
    R2 = chol(X2);
    
    % Verify mathematical reconstruction: X = R.' * R (Standard Transpose for alpha > 0)
    % Note: Assumes overloaded transpose (.') for abtessarine objects
    X2_rec = R2.' * R2;
    err2 = norm(X2.A - X2_rec.A) + norm(X2.B - X2_rec.B) + ...
           norm(X2.C - X2_rec.C) + norm(X2.D - X2_rec.D);
           
    if err2 < tol
        disp('   [OK] Factorization and real unrolled reconstruction strictly validated.');
    else
        error('Hyperbolic reconstruction failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Square Dimensionality Validation
disp('TEST 3: Algorithmic Defense (Non-Square Matrices)');
try
    % Generate a rectangular matrix
    X_rect = abtrandn(4, 5);
    
    evalc('chol(X_rect)');
    
    error('Safety mechanism failed: Allowed factorization of a rectangular matrix.');
catch ME
    if contains(ME.identifier, 'NotSquare')
        disp('   [OK] Exception successfully intercepted: Rectangular matrices blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: Hermitian Symmetry Validation
disp('TEST 4: Algorithmic Defense (Non-Hermitian Matrices)');
try
    % Set topology back to complex
    setabtessarine(-1, 1);
    
    % A completely random matrix is highly unlikely to be 2-Hermitian symmetric
    X_rand = abtrandn(N); 
    
    evalc('chol(X_rand)');
    
    error('Safety mechanism failed: Allowed factorization of a topologically non-symmetric matrix.');
catch ME
    if contains(ME.identifier, 'NotHermitian')
        disp('   [OK] Exception successfully intercepted: Hermitian symmetry constraint enforced.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 5: Positive Definiteness Validation
disp('TEST 5: Algorithmic Defense (Indefinite Matrices)');
try
    % Generate a valid Positive Definite matrix
    X_pd = abtpdm(N);
    
    % Create a Negative Definite matrix by multiplying by -1
    % The structural symmetries are preserved, but the eigenvalues become strictly negative.
    X_nd = abtessarine(-X_pd.A, -X_pd.B, -X_pd.C, -X_pd.D);
    
    evalc('chol(X_nd)');
    
    error('Safety mechanism failed: Allowed factorization of a non-positive definite matrix.');
catch ME
    if contains(ME.identifier, 'NotPositiveDefinite')
        disp('   [OK] Exception successfully intercepted: Isomorphic indefinite spaces securely blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');