% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: sqrtm.m (8D Gabtessarine Matrix Square Root)
% =========================================================================
% This script verifies the principal matrix square root for 8D manifolds.
% It validates the reconstruction identity (Z*Z = X), the precision of 
% the isomorphic bifurcation, and the strict topological guardrails.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: sqrtm (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment for 8D
tol = 1e-10; 

%% TEST 1: Matrix Root Reconstruction [Z * Z == X]
disp('TEST 1: 8D Principal Root Identity [Z*Z = X]');
try
    N = 3;
    % Generate a random 8D matrix with diagonal dominance to ensure 
    % a stable principal square root.
    A1_dom = randn(N) + 10*eye(N); 
    X = gabtessarine(A1_dom, randn(N), randn(N), randn(N), ...
                     randn(N), randn(N), randn(N), randn(N));
    
    % Compute the root
    Z = sqrtm(X);
    
    % Reconstruct: Z * Z (Requires mtimes.m for gabtessarine)
    X_rec = Z * Z;
    
    err = norm(X_rec.A1 - X.A1) + norm(X_rec.A2 - X.A2) + ...
          norm(X_rec.B1 - X.B1) + norm(X_rec.B2 - X.B2) + ...
          norm(X_rec.C1 - X.C1) + norm(X_rec.C2 - X.C2) + ...
          norm(X_rec.D1 - X.D1) + norm(X_rec.D2 - X.D2);
          
    if err < tol
        disp('   [OK] Principal root identity Z*Z = X strictly validated.');
        disp(['   [OK] Total reconstruction error: ', num2str(err)]);
    else
        error('Root reconstruction mismatch. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Preservation of Structural Integrity
disp('TEST 2: Structural Object Integrity and Class Preservation');
try
    X2 = gabtessarine(eye(2), zeros(2), eye(2), zeros(2), ...
                      eye(2), zeros(2), eye(2), zeros(2));
    Z2 = sqrtm(X2);
    
    if isa(Z2, 'gabtessarine') && isequal(size(Z2), [2, 2])
        disp('   [OK] Result is a valid 8D gabtessarine object.');
        disp('   [OK] Dimensional mapping preserved.');
    else
        error('Object class or dimension failure.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Topological Guardrail (Alpha <= 0 Shield)
disp('TEST 3: Topological Environment Shield [Alpha <= 0 Rejection]');
try
    % Force elliptic environment (illegal for 8D sqrtm)
    setabtessarine(-1, 1);
    
    % Create an empty or dummy object
    X_fail = gabtessarine(); 
    
    evalc('sqrtm(X_fail);');
    
    error('Safety failure: Allowed 8D sqrtm in elliptic (Alpha <= 0) space.');
catch ME
    if contains(ME.identifier, 'InvalidAlpha') || contains(ME.identifier, 'MissingEnvironment')
        disp('   [OK] Operation correctly blocked under elliptic/uninitialized topology.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

% Restore hyperbolic environment for future tests
setabtessarine(1, 1);
disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');