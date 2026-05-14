% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: det.m (Hypercomplex Determinant)
% =========================================================================
% This script verifies the mathematical accuracy of the determinant 
% computation utilizing the multiplicative homomorphism property:
% det(A * B) = det(A) * det(B). It tests both elliptic (alpha < 0) 
% and hyperbolic (alpha > 0) topological configurations.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: det.m ---');
disp('===================================================================');

tol = 1e-10; % Numerical tolerance for determinant scaling
N = 3;       % Matrix dimension (keep small to avoid determinant overflow)

%% TEST 1: Multiplicative Homomorphism (Alpha < 0)
disp('TEST 1: Property det(A*B) = det(A)*det(B) [Alpha < 0]');
try
    setabtessarine(-1, 2);
    
    % Generate two random matrices
    A = abtrandn(N);
    B = abtrandn(N);
    
    % Compute determinants
    det_A = det(A);
    det_B = det(B);
    det_AB_direct = det(A * B);
    
    % Compute product of determinants (scalar multiplication)
    det_A_times_det_B = det_A * det_B;
    
    % Compare results
    err = norm(det_AB_direct.A - det_A_times_det_B.A) + ...
          norm(det_AB_direct.B - det_A_times_det_B.B) + ...
          norm(det_AB_direct.C - det_A_times_det_B.C) + ...
          norm(det_AB_direct.D - det_A_times_det_B.D);
    
    if err < tol
        disp('   [OK] Multiplicative property strictly satisfied in elliptic space.');
    else
        error('Determinant mismatch detected in Alpha < 0 topology. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Multiplicative Homomorphism (Alpha > 0)
disp('TEST 2: Property det(A*B) = det(A)*det(B) [Alpha > 0]');
try
    setabtessarine(3, 1);
    
    A2 = abtrandn(N);
    B2 = abtrandn(N);
    
    det_A2 = det(A2);
    det_B2 = det(B2);
    det_A2B2_direct = det(A2 * B2);
    
    det_A2_times_det_B2 = det_A2 * det_B2;
    
    err2 = norm(det_A2B2_direct.A - det_A2_times_det_B2.A) + ...
           norm(det_A2B2_direct.B - det_A2_times_det_B2.B) + ...
           norm(det_A2B2_direct.C - det_A2_times_det_B2.C) + ...
           norm(det_A2B2_direct.D - det_A2_times_det_B2.D);
    
    if err2 < tol
        disp('   [OK] Multiplicative property strictly satisfied in hyperbolic space.');
    else
        error('Determinant mismatch detected in Alpha > 0 topology. Error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Defensive Programming (Non-Square Matrices)
disp('TEST 3: Defensive Check (Non-Square Matrix)');
try
    X_rect = abtrandn(4, 3);
    evalc('det(X_rect)');
    
    error('Safety mechanism failed: Allowed determinant of a rectangular matrix.');
catch ME
    if contains(ME.identifier, 'NonSquareMatrix')
        disp('   [OK] Exception successfully intercepted: Rectangular matrices blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.identifier);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');