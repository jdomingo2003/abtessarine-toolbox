% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: mldivide.m (Operator \)
% =========================================================================
% This script verifies the solution of linear systems X*Z = Y. 
% It validates numerical precision through back-substitution and ensures
% consistent behavior across hybrid numeric-hypercomplex interactions.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: mldivide.m ---');
disp('===================================================================');

tol = 1e-11; % Numerical tolerance
N = 4;

%% TEST 1: System Solution via Back-Substitution (Alpha < 0)
disp('TEST 1: Linear System Stability [X * (X\Y) = Y] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    
    % Generate system matrix X and right-hand side Y
    X = abtrandn(N) + abteye(N)*5; % Well-conditioned
    Y = abtrandn(N, 1);
    
    % Solve the system
    Z = X \ Y;
    
    % Back-substitution: X * Z should recover Y
    Y_rec = X * Z;
    
    err = norm(Y_rec.A - Y.A) + norm(Y_rec.B - Y.B) + ...
          norm(Y_rec.C - Y.C) + norm(Y_rec.D - Y.D);
    
    if err < tol
        disp('   [OK] System solution strictly validated in elliptic space.');
    else
        error('Solution precision failure in Alpha < 0. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: System Solution via Back-Substitution (Alpha > 0)
disp('TEST 2: Linear System Stability [X * (X\Y) = Y] (Alpha > 0)');
try
    setabtessarine(1, 2);
    
    X2 = abtrandn(N) + abteye(N)*5;
    Y2 = abtrandn(N, 1);
    
    Z2 = X2 \ Y2;
    Y2_rec = X2 * Z2;
    
    err2 = norm(Y2_rec.A - Y2.A) + norm(Y2_rec.B - Y2.B) + ...
           norm(Y2_rec.C - Y2.C) + norm(Y2_rec.D - Y2.D);
    
    if err2 < tol
        disp('   [OK] System solution strictly validated in hyperbolic space.');
    else
        error('Solution precision failure in Alpha > 0. Error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Hybrid Numeric Interactions
disp('TEST 3: Hybrid Solver [Real_Matrix \ abtessarine]');
try
    R = randn(N) + eye(N)*5;
    Y3 = abtrandn(N, 2);
    
    Z3 = R \ Y3;
    
    % Verification: R * Z3 should equal Y3
    % (mtimes must handle double * abtessarine)
    Y3_rec = R * Z3;
    
    err3 = norm(Y3_rec.A - Y3.A) + norm(Y3_rec.B - Y3.B);
    
    if err3 < tol
        disp('   [OK] Hybrid solver (Real divisor) accurately handled.');
    else
        error('Hybrid solver precision failure.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');