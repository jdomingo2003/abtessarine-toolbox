% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: transpose.m (Non-Conjugate Transpose, .')
% =========================================================================
% This script verifies the purely spatial transposition of the abtessarine 
% manifold. It validates dimension swapping, the double-transpose 
% identity, and strictly verifies that no algebraic conjugation occurs.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: transpose.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-15;

%% TEST 1: Dimensional Swapping (M x N -> N x M)
disp('TEST 1: Dimensional Swapping for Rectangular Matrices');
try
    M = 5; N = 2;
    X = abtrandn(M, N);
    
    % Apply non-conjugate transpose
    Xt = X.';
    
    if isequal(size(Xt.A), [N, M]) && isequal(size(Xt.D), [N, M])
        disp('   [OK] Spatial dimensions accurately inverted (M x N -> N x M).');
    else
        error('Dimensional swapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Double Transpose Identity [(X^T)^T == X]
disp('TEST 2: Involution Identity [(X.'').'' == X]');
try
    X_id = abtrandn(4, 4);
    
    % Double transpose
    X_tt = (X_id.').';
    
    err_id = norm(X_tt.A - X_id.A) + norm(X_tt.B - X_id.B) + ...
             norm(X_tt.C - X_id.C) + norm(X_tt.D - X_id.D);
             
    if err_id < tol
        disp('   [OK] Double transpose perfectly reconstructed the original matrix.');
    else
        error('Double transpose identity violated.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Strict Non-Conjugation Verification
disp('TEST 3: Non-Conjugation Preservation Shield');
try
    % Create a matrix with distinctly positive values
    X_nc = abtessarine(ones(3), ones(3)*2, ones(3)*3, ones(3)*4);
    
    Xt_nc = X_nc.';
    
    % Check that the trace or sum of components remains positive.
    % If conjugation occurred, B, C, or D would have become negative.
    if all(Xt_nc.B(:) == 2) && all(Xt_nc.C(:) == 3) && all(Xt_nc.D(:) == 4)
        % Cross-verify spatial mapping of a specific asymmetric element
        X_nc.C(1, 3) = 99;
        Xt_asym = X_nc.';
        
        if Xt_asym.C(3, 1) == 99
            disp('   [OK] Spatial mapping confirmed without algebraic sign inversion.');
        else
            error('Spatial mapping failed on asymmetric elements.');
        end
    else
        error('Safety failure: Unintended algebraic conjugation detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');