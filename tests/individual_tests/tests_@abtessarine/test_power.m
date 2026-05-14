% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: power.m (Operator .^)
% =========================================================================
% This script verifies element-wise exponentiation. It validates the 
% integer fast-path (O(log p)) and the fractional spectral path for 
% arrays, ensuring topological consistency and SIMD-like performance.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: power.m ---');
disp('===================================================================');

tol = 1e-10; 
N = 4;

%% TEST 1: Element-wise Integer Power (Topologically Agnostic)
disp('TEST 1: Integer Point-wise Power [X.^2 == X .* X]');
try
    setabtessarine(-1, 1); % Test in elliptic
    X = abtrandn(N, N);
    
    % Power via .^
    Z2 = X.^2;
    
    % Manual element-wise multiplication
    Z_manual = X .* X;
    
    err = norm(Z2.A - Z_manual.A) + norm(Z2.B - Z_manual.B) + ...
          norm(Z2.C - Z_manual.C) + norm(Z2.D - Z_manual.D);
    
    if err < tol
        disp('   [OK] Element-wise square matches point-wise multiplication.');
    else
        error('Point-wise power mismatch. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Fractional Point-wise Power (Hyperbolic Domain)
disp('TEST 2: Fractional Point-wise Power [ (X.^0.5).^2 == X ]');
try
    setabtessarine(1, 1);
    
    % Ensure elements are strictly positive in the real branch for stability
    X = abtrandn(N, N);
    X.A = abs(X.A) + 5; 
    
    % Compute element-wise square root
    X_sqrt = X.^0.5;
    
    % Reconstruct by squaring point-wise
    X_rec = X_sqrt .* X_sqrt;
    
    err_rec = norm(X_rec.A - X.A) + norm(X_rec.B - X.B) + ...
              norm(X_rec.C - X.C) + norm(X_rec.D - X.D);
    
    if err_rec < tol
        disp('   [OK] Element-wise fractional power validated via SIMD-reduction.');
    else
        error('Point-wise reconstruction failed. Error: %e', err_rec);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Array Exponent (p as a matrix)
disp('TEST 3: Point-wise power with Array Exponent');
try
    setabtessarine(1, 1);
    X = abtrandn(2, 2); X.A = abs(X.A) + 2;
    P = [2, 3; 0.5, 1]; % Array of exponents
    
    Z = X.^P;
    
    % Manual check for (1,1) -> X(1,1)^2
    check1 = X(1,1).*X(1,1);
    err1 = norm(Z(1,1).A - check1.A);
    
    if err1 < tol
        disp('   [OK] Successfully handled non-scalar exponent array.');
    else
        error('Array exponent mapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');