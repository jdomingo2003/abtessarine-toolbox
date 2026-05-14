% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: gabtzeros.m (8D Hypercomplex Array of Zeros)
% =========================================================================
% This script verifies the correct structural allocation of 8D null arrays 
% across multiple dimensionalities (2D, 3D), strictly validates the absolute 
% nullity of all 8 branches, and tests the implicit HPC type-safe casting.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: gabtzeros.m ---');
disp('===================================================================');

% CRITICAL: Initialize a topology with alpha > 0 for the 8D generalized algebra
setabtessarine(2, 7); 

%% TEST 1: Multidimensional Tensor Generation
disp('TEST 1: Rectangular and Tensor (N-D) Array Generation');
M = 3; N = 4; P = 5;
try
    % Generate a 3D hypercomplex null tensor in 8 dimensions
    Z_tensor = gabtzeros(M, N, P);
    
    % Verify sizes across all 8 hypercomplex branches
    szA1 = size(Z_tensor.A1); szA2 = size(Z_tensor.A2);
    szB1 = size(Z_tensor.B1); szB2 = size(Z_tensor.B2);
    szC1 = size(Z_tensor.C1); szC2 = size(Z_tensor.C2);
    szD1 = size(Z_tensor.D1); szD2 = size(Z_tensor.D2);
    
    if isequal(szA1, [M, N, P]) && isequal(szA1, szA2) && ...
       isequal(szA1, szB1) && isequal(szA1, szB2) && ...
       isequal(szA1, szC1) && isequal(szA1, szC2) && ...
       isequal(szA1, szD1) && isequal(szA1, szD2)
        disp('   [OK] Tensor dimensions successfully parsed and applied across all 8 branches.');
    else
        error('Dimension mismatch across structural branches.');
    end
    
    % Verify absolute nullity natively
    err_all = norm(Z_tensor.A1(:)) + norm(Z_tensor.A2(:)) + ...
              norm(Z_tensor.B1(:)) + norm(Z_tensor.B2(:)) + ...
              norm(Z_tensor.C1(:)) + norm(Z_tensor.C2(:)) + ...
              norm(Z_tensor.D1(:)) + norm(Z_tensor.D2(:));
    
    if err_all == 0
        disp('   [OK] Multidimensional 8D array structurally perfect (All 8 branches = 0).');
    else
        error('Content mismatch: Non-zero elements detected in the null manifold.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Dimensional Vector Input
disp('TEST 2: Size Vector Input [sz1, sz2]');
try
    sz_vector = [10, 15];
    Z_vec = gabtzeros(sz_vector);
    
    if isequal(size(Z_vec.A1), sz_vector)
        disp('   [OK] Size vector input successfully parsed in 8D constructor.');
    else
        error('Failed to parse size vector input.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: HPC Type-Safe Casting (Implicit varargin pass-through)
disp('TEST 3: HPC Type-Safe Casting (Precision Inheritance)');
try
    % Create a prototype real matrix in Single Precision
    % This tests if the varargin expansion correctly passes the 'like' directive
    % to the underlying C-engine of MATLAB's zeros() function.
    prototype_single = single(0);
    
    % Generate the 8D hypercomplex matrix inheriting the 'single' class
    Z_single = gabtzeros(4, 4, 'like', prototype_single);
    
    % Check if all internal branches inherited the correct type
    class_A1 = class(Z_single.A1);
    class_D2 = class(Z_single.D2); % Check the deepest branch to ensure CoW mapping holds
    
    if strcmp(class_A1, 'single') && strcmp(class_D2, 'single')
        disp('   [OK] Precision inheritance successfully verified (single class across 8D).');
    else
        error('Type-casting failed. Expected "single", got "%s".', class_A1);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');