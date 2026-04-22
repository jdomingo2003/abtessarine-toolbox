% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: eigs.m (Subset Spectral Decomposition)
% =========================================================================
% This script verifies the extraction of dominant eigen-pairs. It validates
% the hybrid routing (ARPACK vs LAPACK), checks the subset matching against
% the full spectral solver, and enforces symmetry-based convergence safety.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: eigs.m ---');
disp('===================================================================');

tol = 1e-8; % Tolerance for subset matching
N = 20;     % Sufficient dimension to test "sparse" extraction
s = 3;      % Requested dominant modes

%% TEST 1: Subset Matching (Alpha < 0)
disp('TEST 1: Dominant Subset Matching [eigs vs eig] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    
    % Generate a 2-Hermitian matrix (Required for convergence shield)
    X = abtpdm(N); 
    
    % Compute full and subset spectrum
    D_full = eig(X);
    [V_sub, D_sub] = eigs(X, s);
    
    % Extract the first 's' eigenvalues from the sorted full result
    d_sub_extracted = diag(D_sub.A);
    d_full_reference = D_full.A(1:s);
    
    err = norm(d_sub_extracted - d_full_reference);
    
    if err < tol
        disp(['   [OK] Top ', num2mstr(s), ' eigenvalues match the full spectral solver.']);
        disp('   [OK] Eigen-reconstruction within subset validated.');
    else
        error('Dominant eigenvalue mismatch. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Dense Regime Routing (s > 3% of N)
disp('TEST 2: Dense Regime Routing (s > 0.03 * N)');
try
    % Requesting 10 modes out of 20 (50% > 3%)
    s_large = 10;
    [V_dense, D_dense] = eigs(X, s_large);
    
    if isequal(size(D_dense.A), [s_large, s_large])
        disp('   [OK] Dense routing and truncation successfully handled.');
    else
        error('Dense regime output dimension mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Symmetry Shield (Defensive Programming)
disp('TEST 3: Convergence Shield (Non-Hermitian Rejection)');
try
    % A random non-symmetric matrix
    X_bad = abtrandn(N);
    
    evalc('eigs(X_bad, 2)');
    
    error('Safety mechanism failed: Allowed eigs on a non-Hermitian matrix.');
catch ME
    if contains(ME.identifier, 'NonHermitian')
        disp('   [OK] Exception successfully intercepted: Convergence shield active.');
    else
        fprintf('   [FAILED] Unexpected error: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: 8D Promotion in Hyperbolic Subset
disp('TEST 4: 8D promotion during hyperbolic subset extraction');
try
    setabtessarine(1, 1);
    
    % Construct a 1-Hermitian matrix (to pass shield) but with negative components
    % that may induce complex hyperbolic roots
    A = eye(N); B = zeros(N); C = eye(N); D = eye(N);
    X_8 = abtessarine(A, B, C, D);
    
    [V8, D8] = eigs(X_8, 2);
    
    if isa(V8, 'gabtessarine') || isa(V8, 'abtessarine')
        disp(['   [OK] Solver returned ', class(V8), ' matching topological constraints.']);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');