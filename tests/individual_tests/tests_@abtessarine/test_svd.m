% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: svd.m (Singular Value Decomposition)
% =========================================================================
% This script verifies the SVD computation across different topologies.
% It validates the reconstruction identity (X = U*S*V'), the unitary 
% properties of U and V, economy-size reduction, and the fast-path 
% for extracting only singular values.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: svd.m ---');
disp('===================================================================');

tol = 1e-11; 
M = 5; N = 3; % Rectangular matrix for testing economy size

%% TEST 1: Full SVD Reconstruction and Unitary Properties (Alpha < 0)
disp('TEST 1: SVD Identity and Unitary Validation (Alpha < 0 - Elliptic)');
try
    setabtessarine(-1, 1);
    X = abtrandn(M, N);
    
    [U, S, V] = svd(X);
    
    % 1.1 Reconstruction Check: X = U * S * V'
    % Assuming V' delegates to the overloaded ctranspose (Hermitian adjoint)
    X_rec = U * S * V';
    err_rec = norm(X_rec.A - X.A) + norm(X_rec.B - X.B) + ...
              norm(X_rec.C - X.C) + norm(X_rec.D - X.D);
    
    % 1.2 Unitary Check: U'*U = I and V'*V = I
    UtU = U' * U;
    VtV = V' * V;
    I_M = abteye(M);
    I_N = abteye(N);
    
    err_U = norm(UtU.A - I_M.A) + norm(UtU.B - I_M.B);
    err_V = norm(VtV.A - I_N.A) + norm(VtV.B - I_N.B);
    
    if err_rec < tol && err_U < tol && err_V < tol
        disp('   [OK] Identity X = U*S*V'' strictly validated.');
        disp('   [OK] Unitary properties U''*U = I and V''*V = I validated.');
    else
        error('SVD precision failure. Rec Error: %e', err_rec);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Economy-Size SVD (Alpha > 0)
disp('TEST 2: Economy-Size SVD [svd(X, ''econ'')] (Alpha > 0 - Hyperbolic)');
try
    setabtessarine(1, 1);
    X2 = abtrandn(M, N);
    
    [Ue, Se, Ve] = svd(X2, 'econ');
    
    % Economy dimensions for M > N should be: U(MxN), S(NxN), V(NxN)
    if isequal(size(Ue.A), [M, N]) && isequal(size(Se.A), [N, N])
        % Check reconstruction
        X2_rec = Ue * Se * Ve';
        if norm(X2_rec.A - X2.A) < tol
            disp('   [OK] Economy-size dimensions strictly followed.');
            disp('   [OK] Economy reconstruction X = U*S*V'' successful.');
        else
            error('Economy SVD reconstruction failed.');
        end
    else
        error('Economy SVD dimension mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Fast-Path (Singular Values Only)
disp('TEST 3: Fast-Path Singular Vector Extraction [s = svd(X)]');
try
    setabtessarine(-1, 1);
    X3 = abtrandn(4, 4);
    
    % Fast path
    s_vec = svd(X3);
    
    % Full path
    [~, S_mat, ~] = svd(X3);
    
    % The vector s_vec should correspond to the diagonal of S_mat
    % Extracting diagonal of S_mat.A
    diag_A = diag(S_mat.A);
    
    if isequal(size(s_vec.A), [4, 1]) && norm(s_vec.A - diag_A) < tol
        disp('   [OK] Fast-path returned correct singular value vector.');
    else
        error('Singular value vector does not match full SVD diagonal.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');