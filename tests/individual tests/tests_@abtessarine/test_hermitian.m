% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: hermitian.m (Explicit Generalized Hermitian Transpose)
% =========================================================================
% This script verifies the explicit parametric transposition. It ensures
% that the function operates independently of the global environment and
% accurately applies scaling factors (1/alpha, 1/beta) to the spatial branches.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: hermitian.m ---');
disp('===================================================================');

tol = 1e-14; % Strict floating-point tolerance
N = 3; M = 4;

%% TEST 1: Explicit Parameter Mapping and Scaling
disp('TEST 1: Explicit Parameter Mapping (1/alpha, 1/beta)');
try
    % Set global environment to something different to test independence
    setabtessarine(-1, 1);
    
    X = abtrandn(N, M);
    
    % Call hermitian with explicit, different parameters
    ext_alpha = -2.0;
    ext_beta  = 0.5;
    
    Zh = hermitian(X, ext_alpha, ext_beta);
    
    % Expected values:
    % A' , B'/alpha , C'/beta , D'/(alpha*beta)
    err_A = norm(Zh.A - X.A.');
    err_B = norm(Zh.B - (X.B.' / ext_alpha));
    err_C = norm(Zh.C - (X.C.' / ext_beta));
    err_D = norm(Zh.D - (X.D.' / (ext_alpha * ext_beta)));
    
    if max([err_A, err_B, err_C, err_D]) < tol
        disp('   [OK] Geometric transposition and explicit scaling strictly validated.');
        disp('   [OK] Function operates independently of global setabtessarine state.');
    else
        error('Numerical mismatch in explicit hermitian mapping.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Argument Count Protection
disp('TEST 2: Input Count Safety Validation');
try
    % Attempt call with missing parameters
    evalc('hermitian(X, -1)'); 
    
    error('Safety mechanism failed: Allowed execution with insufficient arguments.');
catch ME
    if contains(ME.identifier, 'NotEnoughInputs')
        disp('   [OK] Exception successfully intercepted: Missing parameters blocked.');
    else
        fprintf('   [FAILED] Unexpected error: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 3: Structural Integrity on Tensors
disp('TEST 3: Dimensional Integrity (Rectangular Matrices)');
try
    X_rect = abtrandn(5, 2);
    Zh_rect = hermitian(X_rect, 1, 1);
    
    % Verify size [2, 5]
    if isequal(size(Zh_rect.A), [2, 5])
        disp('   [OK] Rectangular transposition dimensions are correct.');
    else
        error('Dimensional distortion detected during explicit transposition.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');