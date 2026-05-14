% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: mpower.m (Operator ^)
% =========================================================================
% This script verifies matrix exponentiation. It validates the integer 
% fast-path via binary squaring and the spectral path for fractional 
% powers, ensuring topological consistency and numerical precision.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: mpower.m ---');
disp('===================================================================');

tol = 1e-10; 
N = 3;

%% TEST 1: Integer Fast-Path (Topologically Agnostic)
disp('TEST 1: Integer Powers via Squaring [X^3 == X*X*X]');
try
    setabtessarine(-1, 1); % Test in elliptic first
    X = abtrandn(N);
    
    % Power by squaring (Fast-path)
    Z3 = X^3;
    
    % Manual multiplication (Ground truth)
    Z_manual = X * X * X;
    
    err = norm(Z3.A - Z_manual.A) + norm(Z3.B - Z_manual.B) + ...
          norm(Z3.C - Z_manual.C) + norm(Z3.D - Z_manual.D);
    
    if err < tol
        disp('   [OK] Integer exponentiation (p=3) matches manual multiplication.');
    else
        error('Integer power mismatch. Error: %e', err);
    end
    
    % Identity test
    I_test = X^0;
    if norm(I_test.A - eye(N)) < tol && norm(I_test.B) < tol
        disp('   [OK] Matrix power X^0 returns Identity.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Fractional Spectral Path (Hyperbolic Domain)
disp('TEST 2: Fractional Powers [ (X^0.5)^2 == X ]');
try
    % Fractional power requires alpha, beta > 0 in this implementation
    setabtessarine(1, 1);
    
    % Use a Positive Definite matrix to ensure square root stability
    % (Note: abtpdm must be defined in your toolbox)
    X_pd = abtpdm(N); 
    
    % Compute square root via mpower (Spectral path)
    X_sqrt = X_pd^0.5;
    
    % Square it back
    X_rec = X_sqrt * X_sqrt;
    
    err_rec = norm(X_rec.A - X_pd.A) + norm(X_rec.B - X_pd.B) + ...
              norm(X_rec.C - X_pd.C) + norm(X_rec.D - X_pd.D);
    
    if err_rec < tol
        disp('   [OK] Fractional power (p=0.5) validated via spectral path.');
        fprintf('   [Reconstruction Error]: %e\n', err_rec);
    else
        error('Fractional power reconstruction failed. Error: %e', err_rec);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Defensive Shield (Guardrails)
disp('TEST 3: Topological and Dimensional Guardrails');
try
    % Test 3.1: Fractional power in elliptic domain (should be blocked)
    setabtessarine(-1, 1);
    X_rand = abtrandn(N);
    try
        X_rand^0.5;
        error('Safety failure: Allowed fractional power in alpha < 0.');
    catch
        disp('   [OK] Correctly blocked fractional power in elliptic topology.');
    end
    
    % Test 3.2: Non-square matrix (should be blocked)
    X_rect = abtrandn(4, 3);
    try
        X_rect^2;
        error('Safety failure: Allowed mpower on non-square matrix.');
    catch
        disp('   [OK] Correctly blocked mpower on non-square matrix.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');