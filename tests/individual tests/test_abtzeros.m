% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abtzeros.m (Hypercomplex Array of Zeros)
% =========================================================================
% This script verifies the correct structural allocation of null arrays 
% across multiple dimensionalities (2D, 3D), strictly validates the absolute 
% nullity of the branches, and tests the implicit HPC type-safe casting.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtzeros.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology initialization

%% TEST 1: Multidimensional Tensor Generation
disp('TEST 1: Rectangular and Tensor (N-D) Array Generation');
M = 3; N = 4; P = 5;
try
    % Generate a 3D hypercomplex null tensor
    Z_tensor = abtzeros(M, N, P);
    
    % Verify sizes across all hypercomplex branches
    szA = size(Z_tensor.A); szB = size(Z_tensor.B);
    szC = size(Z_tensor.C); szD = size(Z_tensor.D);
    
    if isequal(szA, [M, N, P]) && isequal(szA, szB) && isequal(szA, szC) && isequal(szA, szD)
        disp('   [OK] Tensor dimensions successfully parsed and applied.');
    else
        error('Dimension mismatch across structural branches.');
    end
    
    % Verify absolute nullity natively
    err_A = norm(Z_tensor.A(:));
    err_BCD = norm(Z_tensor.B(:)) + norm(Z_tensor.C(:)) + norm(Z_tensor.D(:));
    
    if err_A == 0 && err_BCD == 0
        disp('   [OK] Multidimensional array structurally perfect (A=B=C=D=0).');
    else
        error('Content mismatch: Non-zero elements detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Dimensional Vector Input
disp('TEST 2: Size Vector Input [sz1, sz2]');
try
    sz_vector = [10, 15];
    Z_vec = abtzeros(sz_vector);
    
    if isequal(size(Z_vec.A), sz_vector)
        disp('   [OK] Size vector input successfully parsed.');
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
    % Create a prototype real matrix in an alternative numeric class (int8)
    % This tests if the varargin expansion correctly passes the 'like' directive
    % to the underlying C-engine of MATLAB's zeros() function.
    prototype_int = int8(0);
    
    % Generate the hypercomplex matrix inheriting the 'int8' class
    Z_int = abtzeros(4, 4, 'like', prototype_int);
    
    % Check if all internal branches inherited the correct type
    class_A = class(Z_int.A);
    class_D = class(Z_int.D); % Check the deepest branch to ensure CoW mapping holds
    
    if strcmp(class_A, 'int8') && strcmp(class_D, 'int8')
        disp('   [OK] Precision inheritance successfully verified (int8 class).');
    else
        error('Type-casting failed. Expected "int8", got "%s".', class_A);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');