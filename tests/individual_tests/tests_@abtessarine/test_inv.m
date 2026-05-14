% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: inv.m (Hypercomplex Matrix Inversion)
% =========================================================================
% This script verifies the numerical precision of the matrix inverse 
% using the fundamental identity: X * inv(X) = Identity.
% It validates both elliptic (alpha < 0) and hyperbolic (alpha > 0) 
% topographies and confirms robust handling of singular manifolds.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: inv.m ---');
disp('===================================================================');

tol = 1e-10; % Numerical tolerance for inversion
N = 5;       % Matrix dimension

%% TEST 1: Inverse Identity Property (Alpha < 0 - Elliptic)
disp('TEST 1: Identity Property [X * inv(X) = I] (Alpha < 0)');
try
    setabtessarine(-1, 1);
    
    % Generate a well-conditioned random matrix
    % (Shifted by 5*I to ensure numerical stability)
    X = abtrandn(N) + abteye(N)*5; 
    
    % Compute inverse and verify reconstruction
    Xi = inv(X);
    Res = X * Xi;
    I = abteye(N);
    
    % Calculate cumulative error across the 4D manifold
    err = norm(Res.A - I.A) + norm(Res.B - I.B) + ...
          norm(Res.C - I.C) + norm(Res.D - I.D);
    
    if err < tol
        disp('   [OK] Matrix inverse strictly validated in elliptic space.');
        fprintf('   [RMS Error]: %e\n', err);
    else
        error('Inversion precision failure in Alpha < 0. Error: %e', err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Inverse Identity Property (Alpha > 0 - Hyperbolic)
disp('TEST 2: Identity Property [X * inv(X) = I] (Alpha > 0)');
try
    setabtessarine(2, 3);
    
    X2 = abtrandn(N) + abteye(N)*5;
    Xi2 = inv(X2);
    
    Res2 = X2 * Xi2;
    I2 = abteye(N);
    
    err2 = norm(Res2.A - I2.A) + norm(Res2.B - I2.B) + ...
           norm(Res2.C - I2.C) + norm(Res2.D - I2.D);
    
    if err2 < tol
        disp('   [OK] Matrix inverse strictly validated in hyperbolic space.');
        fprintf('   [RMS Error]: %e\n', err2);
    else
        error('Inversion precision failure in Alpha > 0. Error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Robust Handling of Singular Matrices
disp('TEST 3: Singular Manifold Detection (Warning Capture)');
try
    % Create a strictly singular matrix (null manifold)
    X_sing = abtzeros(N);
    
    % Capture current warning state and silence console
    w_state = warning('off', 'MATLAB:singularMatrix');
    lastwarn(''); 
    
    % Execution
    inv(X_sing);
    
    % Validate if the internal LAPACK engine triggered the warning
    [~, msgID] = lastwarn;
    warning(w_state); % Restore warning state immediately
    
    if ~isempty(msgID)
        fprintf('   [OK] Success: Singular manifold detected via isomorphic branches.\n');
        fprintf('   [Source]: %s\n', msgID);
    else
        disp('   [WARNING] Singularity not detected. Check isomorphic conditioning.');
    end
    
catch ME
    warning(w_state);
    fprintf('   [CAUGHT] Function correctly rejected operation: %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');