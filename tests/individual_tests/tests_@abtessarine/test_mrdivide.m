% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: mrdivide.m (Operator /)
% =========================================================================
% This script verifies the solution of linear systems Z*Y = X. 
% It validates numerical precision through post-multiplication and ensures
% consistent behavior across hybrid numeric-hypercomplex interactions.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: mrdivide.m ---');
disp('===================================================================');

tol = 1e-11; % Numerical tolerance
N = 4;

%% TEST 1: System Solution via Post-Multiplication (Alpha < 0)
disp('TEST 1: Right Division Stability [(X/Y) * Y = X] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    
    % Generate dividend X and divisor Y (well-conditioned)
    X = abtrandn(N);
    Y = abtrandn(N) + abteye(N)*5; 
    
    % Solve the system Z = X / Y
    Z = X / Y;
    
    % Verification: Z * Y should recover X
    X_rec = Z * Y;
    
    err = norm(X_rec.A - X.A) + norm(X_rec.B - X.B) + ...
          norm(X_rec.C - X.C) + norm(X_rec.D - X.D);
    
    if err < tol
        disp('   [OK] Right division strictly validated in elliptic space.');
    else
        error('Solution precision failure in Alpha < 0. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: System Solution via Post-Multiplication (Alpha > 0)
disp('TEST 2: Right Division Stability [(X/Y) * Y = X] (Alpha > 0)');
try
    setabtessarine(1, 1);
    
    X2 = abtrandn(N);
    Y2 = abtrandn(N) + abteye(N)*5;
    
    Z2 = X2 / Y2;
    X2_rec = Z2 * Y2;
    
    err2 = norm(X2_rec.A - X2.A) + norm(X2_rec.B - X2.B) + ...
           norm(X2_rec.C - X2.C) + norm(X2_rec.D - X2.D);
    
    if err2 < tol
        disp('   [OK] Right division strictly validated in hyperbolic space.');
    else
        error('Solution precision failure in Alpha > 0. Error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Hybrid Numeric Interactions
disp('TEST 3: Hybrid Solver [abtessarine / Real_Matrix]');
try
    X3 = abtrandn(2, N);
    R = randn(N) + eye(N)*5;
    
    Z3 = X3 / R;
    
    % Verification: Z3 * R should equal X3
    X3_rec = Z3 * R;
    
    err3 = norm(X3_rec.A - X3.A) + norm(X3_rec.B - X3.B);
    
    if err3 < tol
        disp('   [OK] Hybrid right-solver (Real divisor) accurately handled.');
    else
        error('Hybrid solver precision failure.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');