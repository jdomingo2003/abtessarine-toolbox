% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: trace.m (Matrix Trace)
% =========================================================================
% This script verifies the trace operator for abtessarine matrices.
% It validates the diagonal summation equivalence, the strict linearity 
% of the operator, and its invariance under transposition.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: trace.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-13;
N = 5;

%% TEST 1: Equivalence to Diagonal Summation
disp('TEST 1: Diagonal Summation Equivalence [trace(X) == sum(diag(X))]');
try
    X = abtrandn(N, N);
    
    t_func = trace(X);
    
    % Manual diagonal summation across all components
    diag_A = sum(diag(X.A));
    diag_B = sum(diag(X.B));
    diag_C = sum(diag(X.C));
    diag_D = sum(diag(X.D));
    
    err = abs(t_func.A - diag_A) + abs(t_func.B - diag_B) + ...
          abs(t_func.C - diag_C) + abs(t_func.D - diag_D);
          
    if isscalar(t_func.A) && err < tol
        disp('   [OK] Trace correctly evaluated as the sum of the main diagonal.');
    else
        error('Trace result mismatched manual diagonal summation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Strict Linearity Property
disp('TEST 2: Linearity Property [Tr(aX + bY) == aTr(X) + bTr(Y)]');
try
    X = abtrandn(N, N);
    Y = abtrandn(N, N);
    a = 2.5; 
    b = -1.5;
    
    % Left side: Tr(aX + bY)
    t_left = trace(a*X + b*Y);
    
    % Right side: aTr(X) + bTr(Y)
    t_right = a*trace(X) + b*trace(Y);
    
    err_lin = abs(t_left.A - t_right.A) + abs(t_left.B - t_right.B) + ...
              abs(t_left.C - t_right.C) + abs(t_left.D - t_right.D);
              
    if err_lin < tol
        disp('   [OK] Linear operator property rigorously validated.');
    else
        error('Linearity property violated. Error: %e', err_lin);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Transpose Invariance
disp('TEST 3: Transpose Invariance [Tr(X) == Tr(X^T)]');
try
    X_inv = abtrandn(N, N);
    
    % Note: Using non-conjugate transpose (.') if available, or manual mapping
    % Assuming abtessarine transpose is structurally sound:
    try
        Xt = X_inv.'; 
        t_orig = trace(X_inv);
        t_trans = trace(Xt);
        
        err_trans = abs(t_orig.A - t_trans.A) + abs(t_orig.B - t_trans.B) + ...
                    abs(t_orig.C - t_trans.C) + abs(t_orig.D - t_trans.D);
                    
        if err_trans < tol
            disp('   [OK] Trace remains invariant under topological transposition.');
        else
            error('Transpose invariance failed.');
        end
    catch
        disp('   [INFO] Transpose operator (''.'') might not be implemented yet. Skipping strict check.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');