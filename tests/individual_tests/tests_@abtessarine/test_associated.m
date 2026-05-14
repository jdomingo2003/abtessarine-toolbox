% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: associated.m (Idempotent Block Projection)
% =========================================================================
% This script rigorously verifies the algebraic correctness of the 
% associated representations under both standard (alpha < 0) and 
% unrolled (alpha > 0) topological environments. It also tests the 
% strict safety mechanisms for input and environment validation.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: associated.m ---');
disp('===================================================================');

tol = 1e-12; % Strict floating-point tolerance for algebraic comparisons
N = 4;       % Matrix dimension

%% TEST 1: Associated Representation for Alpha < 0
disp('TEST 1: Block Projection under Alpha < 0 Topology');
try
    % Set environment and create random object
    alpha1 = -1; beta1 = 2;
    setabtessarine(alpha1, beta1);
    X = abtrandn(N);
    
    % Compute associated representation
    XE = associated(X);
    
    % Manually compute the expected theoretical results
    g = sqrt(beta1);
    expected_A = X.A + g * X.C;
    expected_C = X.A - g * X.C;
    expected_B = zeros(N);
    expected_D = zeros(N);
    
    % Validate structural mapping
    err_A = norm(XE.A - expected_A);
    err_B = norm(XE.B - expected_B);
    err_C = norm(XE.C - expected_C);
    err_D = norm(XE.D - expected_D);
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Idempotent projection structurally perfect for Alpha < 0.');
        disp('   [OK] Imaginary-equivalent blocks (B and D) strictly mapped to zero.');
    else
        error('Mathematical deviation in the associated representation (Alpha < 0).');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Associated Representation for Alpha > 0
disp('TEST 2: Block Projection under Alpha > 0 Topology (Full Unrolling)');
try
    % Set environment and create random object
    alpha2 = 3; beta2 = 4;
    setabtessarine(alpha2, beta2);
    X = abtrandn(N);
    
    % Compute associated representation
    XE = associated(X);
    
    % Manually compute the expected theoretical results
    g = sqrt(beta2); z = sqrt(alpha2);
    AS = X.A + g * X.C;
    AD = X.A - g * X.C;
    zBS = z * (X.B + g * X.D);
    zBD = z * (X.B - g * X.D);
    
    expected_A = AS + zBS;
    expected_B = AS - zBS;
    expected_C = AD + zBD;
    expected_D = AD - zBD;
    
    % Validate structural mapping
    err_A = norm(XE.A - expected_A);
    err_B = norm(XE.B - expected_B);
    err_C = norm(XE.C - expected_C);
    err_D = norm(XE.D - expected_D);
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] 4-block idempotent expansion structurally perfect for Alpha > 0.');
    else
        error('Mathematical deviation in the fully unrolled representation (Alpha > 0).');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Input Count Protection
disp('TEST 3: Missing Argument Safety Validation');
try
    evalc('associated()');
    
    error('Safety mechanism failed: Allowed execution without providing an input matrix.');
catch ME
    if contains(ME.identifier, 'NotEnoughInputs')
        disp('   [OK] Exception successfully intercepted: Missing input firmly blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.identifier);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: Uninitialized Environment Protection
disp('TEST 4: Unconfigured Environment Safety Validation');
try
    % Purge the global environment
    if isappdata(0, 'Tessarine_Alpha'), rmappdata(0, 'Tessarine_Alpha'); end
    if isappdata(0, 'Tessarine_Beta'),  rmappdata(0, 'Tessarine_Beta'); end
    
    % Attempt to compute associated representation
    evalc('associated(X)');
    
    error('Safety mechanism failed: Permitted mathematical projection in an undefined topological space.');
catch ME
    if contains(ME.identifier, 'NotConfigured') || contains(ME.identifier, 'ParametersNotSet')
        disp('   [OK] Exception successfully intercepted: Uninitialized workspace locked down.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.identifier);
    end
end
disp('-------------------------------------------------------------------');

%% CLEANUP
disp('CLEANUP: Restoring Standard Topology...');
evalc('setabtessarine(-1, 1)');
disp('   [OK] Standard environment restored.');

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');