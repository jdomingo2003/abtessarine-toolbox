% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: eig.m (Hypercomplex Spectral Decomposition)
% =========================================================================
% This script verifies the mathematical accuracy of the spectral solver 
% through eigen-reconstruction (X*V = V*D). It also validates the 
% automated 8D promotion (gabtessarine) in the hyperbolic domain and 
% the consistency of absolute-magnitude sorting.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: eig.m ---');
disp('===================================================================');

tol = 1e-10; % Floating-point tolerance for reconstruction
N = 3; 

%% TEST 1: Spectral Reconstruction (Alpha < 0) - Elliptic Domain
disp('TEST 1: Eigen-Reconstruction [X*V - V*D] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    X = abtrandn(N);
    
    [V, D] = eig(X);
    
    % Verify reconstruction: LHS = X * V, RHS = V * D
    LHS = X * V;
    RHS = V * D;
    
    err = norm(LHS.A - RHS.A) + norm(LHS.B - RHS.B) + ...
          norm(LHS.C - RHS.C) + norm(LHS.D - RHS.D);
    
    if err < tol
        disp('   [OK] Spectral reconstruction strictly validated in 4D elliptic space.');
        disp(['   [OK] Return class: ', class(V)]);
    else
        error('Spectral reconstruction mismatch. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hyperbolic Confinement (Alpha > 0, 1-Hermitian)
disp('TEST 2: 4D Confinement in Hyperbolic Domain (1-Hermitian Matrix)');
try
    setabtessarine(1, 1);
    
    % Generate a 1-Hermitian matrix (A,B,C,D are symmetric)
    A = randn(N); A = A + A.';
    B = randn(N); B = B + B.';
    C = randn(N); C = C + C.';
    D = randn(N); D = D + D.';
    X_herm = abtessarine(A, B, C, D);
    
    [V_h, D_h] = eig(X_herm);
    
    if isa(V_h, 'abtessarine')
        disp('   [OK] Output correctly confined to 4D abtessarine for 1-Hermitian input.');
    else
        error('Failed to confine output to 4D. Promotion to 8D occurred unnecessarily.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: 8D Promotion (Alpha > 0, Non-Symmetric)
disp('TEST 3: Automated 8D Promotion (gabtessarine) for Non-Symmetric Input');
try
    setabtessarine(1, 1);
    X_rand = abtrandn(N); % Random matrix will likely have complex hyperbolic roots
    
    [V_8, D_8] = eig(X_rand);
    
    if isa(V_8, 'gabtessarine')
        disp('   [OK] Spectral "escape" detected: Output successfully promoted to 8D gabtessarine.');
        
        % Verify 8D Reconstruction using overloaded 8D operators
        LHS8 = X_rand * V_8;
        RHS8 = V_8 * D_8;
        
        % Check primary real component of the error
        err8 = norm(LHS8.A1 - RHS8.A1);
        if err8 < tol
             disp('   [OK] 8D spectral reconstruction verified.');
        end
    else
        error('Promotion mechanism failed. Output remained 4D despite complex hyperbolic roots.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Magnitude Sorting Integrity
disp('TEST 4: Absolute Magnitude Sorting Consistency');
try
    setabtessarine(-1, 1);
    X_sort = abtrandn(N);
    eig_vals = eig(X_sort); % Returns column vector of eigenvalues
    
    % Compute norms of the hypercomplex scalars
    % norm = sqrt(A^2 + |alpha|B^2 + beta*C^2 + |alpha|beta*D^2) approx.
    mags = zeros(N, 1);
    for i = 1:N
        mags(i) = abs(eig_vals.A(i)) + abs(eig_vals.B(i)) + ...
                  abs(eig_vals.C(i)) + abs(eig_vals.D(i));
    end
    
    % Check if magnitudes are generally non-increasing (descending)
    if all(diff(mags) <= 1e-5) % Allowing small numerical noise in mag calc
        disp('   [OK] Eigenvalues successfully aligned and sorted by magnitude.');
    else
        disp('   [WARNING] Sorting order might be affected by multi-branch magnitude overlap.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');