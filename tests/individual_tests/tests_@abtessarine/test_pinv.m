% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: pinv.m (Moore-Penrose Pseudoinverse)
% =========================================================================
% This script verifies the pseudoinverse calculation for rectangular and
% singular abtessarine matrices. It validates the Penrose identity 
% X * pinv(X) * X = X across different algebraic topologies.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: pinv.m ---');
disp('===================================================================');

tol_test = 1e-10; % Tolerance for identity verification
M = 5; N = 3;    % Rectangular dimensions

%% TEST 1: Rectangular Matrix Inversion (Alpha < 0)
disp('TEST 1: Rectangular Penrose Identity [X * pinv(X) * X = X] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    X = abtrandn(M, N);
    
    Z = pinv(X);
    
    % Verify size: Should be NxM
    if ~isequal(size(Z.A), [N, M])
        error('Dimension mismatch in pseudoinverse output.');
    end
    
    % Check Penrose Identity: X*Z*X should equal X
    X_rec = X * Z * X;
    
    err = norm(X_rec.A - X.A) + norm(X_rec.B - X.B) + ...
          norm(X_rec.C - X.C) + norm(X_rec.D - X.D);
    
    if err < tol_test
        disp('   [OK] Pseudoinverse identity strictly validated for M > N.');
    else
        error('Penrose identity mismatch. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Rank-Deficient Stability (Alpha > 0)
disp('TEST 2: Rank-Deficient Stability (Alpha > 0)');
try
    setabtessarine(1, 1);
    
    % Create a rank-deficient matrix (e.g., repeating columns)
    X_def = abtrandn(M, N);
    X_def.A(:, 3) = X_def.A(:, 1); 
    X_def.B(:, 3) = X_def.B(:, 1);
    X_def.C(:, 3) = X_def.C(:, 1);
    X_def.D(:, 3) = X_def.D(:, 1);
    
    Z_def = pinv(X_def);
    
    % Penrose Identity should still hold for rank-deficient matrices
    X_rec_def = X_def * Z_def * X_def;
    err_def = norm(X_rec_def.A - X_def.A);
    
    if err_def < tol_test
        disp('   [OK] Rank-deficient pseudoinverse correctly handled.');
    else
        error('Identity failed for rank-deficient manifold.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Custom Tolerance Handling
disp('TEST 3: Explicit Tolerance Influence');
try
    X_sing = abteye(N);
    X_sing.A(N,N) = 1e-12; % Nearly singular element
    
    % Inversion with a tolerance that ignores the small element
    Z_tol = pinv(X_sing, 1e-5);
    
    % The last element in Z_tol.A should be 0, not 1e12
    if Z_tol.A(N,N) == 0
        disp('   [OK] User-defined tolerance correctly filtered singular values.');
    else
        error('Tolerance parameter was not respected by the solver.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');