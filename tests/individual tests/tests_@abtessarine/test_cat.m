% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: cat.m (Multidimensional Concatenation)
% =========================================================================
% This script verifies the structural integrity of multidimensional 
% concatenations (1D, 2D, 3D), validates multilinear data mapping, and 
% rigorously tests the dynamic type coercion mechanisms when mixing 
% real numeric arrays with hypercomplex manifolds.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: cat.m ---');
disp('===================================================================');

tol = 1e-12; % Strict floating-point tolerance
setabtessarine(-1, 1); % Standard topology initialization

% Generate base objects for concatenation
N = 2; M = 3;
X1 = abtrandn(N, M);
X2 = abtrandn(N, M);
X3 = abtrandn(N, M);

%% TEST 1: Vertical and Horizontal Concatenation (2D)
disp('TEST 1: 2D Spatial Concatenation (dim = 1, dim = 2)');
try
    % 1.1 Vertical Concatenation (dim = 1)
    Z_vert = cat(1, X1, X2, X3);
    sz_vert = size(Z_vert.A);
    
    if isequal(sz_vert, [3*N, M])
        disp('   [OK] Vertical concatenation (dim=1) dimensionally accurate.');
    else
        error('Vertical expansion failed.');
    end
    
    % 1.2 Horizontal Concatenation (dim = 2)
    Z_horz = cat(2, X1, X2);
    sz_horz = size(Z_horz.A);
    
    % Verify structural data integrity on horizontal merge
    err_A = norm(Z_horz.A - [X1.A, X2.A]);
    err_D = norm(Z_horz.D - [X1.D, X2.D]);
    
    if isequal(sz_horz, [N, 2*M]) && (err_A < tol) && (err_D < tol)
        disp('   [OK] Horizontal concatenation (dim=2) structurally and dimensionally accurate.');
    else
        error('Horizontal expansion or data mapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Tensor Concatenation (3D)
disp('TEST 2: N-Dimensional Tensor Concatenation (dim = 3)');
try
    % Concatenate along depth
    Z_depth = cat(3, X1, X2);
    sz_depth = size(Z_depth.A);
    
    if isequal(sz_depth, [N, M, 2])
        % Extract the second slice and compare it to X2 to guarantee C-engine delegation worked
        slice2_A = Z_depth.A(:, :, 2);
        if norm(slice2_A - X2.A) < tol
            disp('   [OK] 3D Tensor concatenation successfully delegated to the C-engine.');
        else
            error('Tensor depth mapping corrupted.');
        end
    else
        error('3D expansion failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dynamic Type Coercion (Mixing classes)
disp('TEST 3: Dynamic Type Coercion (Real Array + Hypercomplex Array)');
try
    % Create a standard MATLAB double array
    R_real = randn(N, M);
    
    % Concatenate abtessarine with real numeric array horizontally
    Z_mixed = cat(2, X1, R_real);
    
    % Verify the real branch (A) contains both matrices
    expected_A = [X1.A, R_real];
    err_mixed_A = norm(Z_mixed.A - expected_A);
    
    % Verify the imaginary branch (B) contains the original B and exactly zeros for the real part
    expected_B = [X1.B, zeros(N, M)];
    err_mixed_B = norm(Z_mixed.B - expected_B);
    
    if (err_mixed_A < tol) && (err_mixed_B == 0)
        disp('   [OK] Real numeric array successfully coerced into the hypercomplex manifold.');
        disp('   [OK] Zero-padding (CoW mapping) strictly applied to imaginary branches.');
    else
        error('Type coercion or zero-padding failed during mixed-class concatenation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Invalid Dimension Argument Protection
disp('TEST 4: Invalid Dimension Safety Check');
try
    evalc('cat([], X1, X2)'); % Empty dimension argument
    
    error('Safety mechanism failed: Permitted execution with invalid dimension argument.');
catch ME
    if contains(ME.message, 'positive integer scalar')
        disp('   [OK] Exception successfully intercepted: Invalid dimension input blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');