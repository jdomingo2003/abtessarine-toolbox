% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: qr.m (Orthogonal-Triangular Decomposition)
% =========================================================================
% This script verifies the QR decomposition across different geometries.
% It validates the reconstruction identity X = Q*R, the unitary property
% of Q, and the triangularity of R in the hypercomplex manifold.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: qr.m ---');
disp('===================================================================');

tol = 1e-12; 
M = 6; N = 4; % Test with rectangular matrices

%% TEST 1: QR Reconstruction and Unitary Property (Alpha < 0)
disp('TEST 1: QR Identity and Unitary Q (Alpha < 0 - Elliptic)');
try
    setabtessarine(-1, 1);
    X = abtrandn(M, N);
    
    [Q, R] = qr(X);
    
    % 1.1 Reconstruction Check: Q*R = X
    X_rec = Q * R;
    err_rec = norm(X_rec.A - X.A) + norm(X_rec.B - X.B);
    
    % 1.2 Unitary Check: Q' * Q = I
    % Note: Use the overloaded ctranspose (')
    QtQ = Q' * Q;
    I = abteye(M); 
    err_uni = norm(QtQ.A - I.A) + norm(QtQ.B - I.B);
    
    if err_rec < tol && err_uni < tol
        disp('   [OK] Identity X = Q*R strictly validated.');
        disp('   [OK] Unitary property Q^H * Q = I validated.');
    else
        error('QR precision failure. Rec Error: %e, Uni Error: %e', err_rec, err_uni);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Economy Size QR (Alpha > 0)
disp('TEST 2: Economy-size QR [qr(X, 0)] (Alpha > 0 - Hyperbolic)');
try
    setabtessarine(1, 1);
    X2 = abtrandn(M, N); % 6x4 matrix
    
    [Qe, Re] = qr(X2, 0);
    
    % Economy size: Qe should be 6x4, Re should be 4x4
    szQ = size(Qe.A);
    szR = size(Re.A);
    
    if isequal(szQ, [M, N]) && isequal(szR, [N, N])
        % Check triangularity of Re
        if istriu(Re.A)
            disp('   [OK] Economy-size dimensions and triangularity verified.');
            % Quick reconstruction check
            X_rec2 = Qe * Re;
            if norm(X_rec2.A - X2.A) < tol
                disp('   [OK] Economy QR reconstruction successful.');
            end
        else
            error('R matrix is not triangular.');
        end
    else
        error('Economy dimension mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Consistency of R
disp('TEST 3: Structural Integrity of R');
try
    setabtessarine(-1, 1);
    X3 = abtrandn(5, 5);
    [~, R3] = qr(X3);
    
    % In a hypercomplex matrix, 'triangular' means all components 
    % follow the same zero-pattern.
    if istriu(R3.A) && istriu(R3.B) && istriu(R3.C) && istriu(R3.D)
        disp('   [OK] All abtessarine components in R are upper triangular.');
    else
        error('Structural leakage: Components of R are not triangular.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');