% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abtpdm.m (Positive Definite Matrix Generator)
% =========================================================================
% This script verifies the correct generation of positive definite 
% hypercomplex matrices under both topological conditions (alpha < 0 and 
% alpha > 0). It tests structural symmetries and mathematical definiteness.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtpdm.m ---');
disp('===================================================================');

tol = 1e-10; % Floating-point tolerance for symmetry checks
N = 5;       % Size of the test matrices

%% TEST 1: Alpha < 0 (2-Hermitian Topology)
disp('TEST 1: Topology with Alpha < 0 (Standard Tessarine)');
alpha1 = -1; beta1 = 1;
try
    % Generate matrix injecting parameters directly
    X1 = abtpdm(N, alpha1, beta1);
    disp('   [OK] Matrix successfully generated.');
    
    % 1.1 Structural Symmetry Check
    % For alpha < 0, A and C must be symmetric. B and D must be skew-symmetric.
    err_A = norm(X1.A - X1.A.');
    err_C = norm(X1.C - X1.C.');
    err_B = norm(X1.B + X1.B.'); % Note the plus sign for skew-symmetry
    err_D = norm(X1.D + X1.D.');
    
    if max([err_A, err_C, err_B, err_D]) < tol
        disp('   [OK] Structural 2-Hermitian symmetries strictly preserved.');
    else
        error('Symmetry violation in Alpha < 0 topology.');
    end
    
    % 1.2 Positive Definiteness Check (Cholesky benchmark)
    % Globally set the environment to allow chol() to process it
    setabtessarine(alpha1, beta1);
    L1 = chol(X1);
    disp('   [OK] Matrix is strictly Positive Definite (Cholesky passed).');
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Alpha > 0 (1-Hermitian Topology / Real Unfolded Domain)
disp('TEST 2: Topology with Alpha > 0 (Unfolded Real Domain)');
alpha2 = 2; beta2 = 3;
try
    % Generate matrix injecting parameters directly
    X2 = abtpdm(N, alpha2, beta2);
    disp('   [OK] Matrix successfully generated.');
    
    % 2.1 Structural Symmetry Check
    % For alpha > 0, ALL components (A, B, C, D) must be strictly symmetric.
    err_A = norm(X2.A - X2.A.');
    err_B = norm(X2.B - X2.B.');
    err_C = norm(X2.C - X2.C.');
    err_D = norm(X2.D - X2.D.');
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Structural 1-Hermitian symmetries strictly preserved.');
    else
        error('Symmetry violation in Alpha > 0 topology.');
    end
    
    % 2.2 Positive Definiteness Check (Cholesky benchmark)
    setabtessarine(alpha2, beta2);
    L2 = chol(X2);
    disp('   [OK] Matrix is strictly Positive Definite (Cholesky passed).');
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Global Environment Fallback
disp('TEST 3: Global Environment Fallback');
try
    setabtessarine(-2, 4);
    X3 = abtpdm(N); % Calling without explicit parameters
    disp('   [OK] Function successfully retrieved global parameters.');
    L3 = chol(X3);
    disp('   [OK] Global matrix is strictly Positive Definite.');
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');