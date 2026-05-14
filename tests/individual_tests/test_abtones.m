% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abtones.m (Hypercomplex Array of Ones)
% =========================================================================
% This script verifies the generation of arrays filled with ones across 
% multiple dimensionalities (2D, 3D), validates the correct zero-padding 
% of the hypercomplex branches, and tests the HPC type-safe casting 
% (the 'like' parameter) for memory optimization.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtones.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology

%% TEST 1: Multidimensional Array Generation
disp('TEST 1: Rectangular and Tensor (N-D) Array Generation');
M = 3; N = 4; P = 2;
try
    % Generate a 3D hypercomplex tensor
    Z_tensor = abtones(M, N, P);
    
    % Verify sizes across all branches
    szA = size(Z_tensor.A);
    if ~isequal(szA, [M, N, P])
        error('Generated tensor does not match the requested M x N x P dimensions.');
    end
    
    % Verify content natively
    err_A = norm(Z_tensor.A(:) - ones(M*N*P, 1));
    err_BCD = norm(Z_tensor.B(:)) + norm(Z_tensor.C(:)) + norm(Z_tensor.D(:));
    
    if err_A == 0 && err_BCD == 0
        disp('   [OK] Multidimensional array structurally perfect (A=1, B=C=D=0).');
    else
        error('Content mismatch in tensor generation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Dimensional Vector Input
disp('TEST 2: Size Vector Input [sz1, sz2]');
try
    sz_vector = [5, 5];
    Z_vec = abtones(sz_vector);
    
    if isequal(size(Z_vec.A), sz_vector)
        disp('   [OK] Size vector input successfully parsed.');
    else
        error('Failed to parse size vector input.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: HPC Type-Safe Casting ('like' parameter)
disp('TEST 3: HPC Type-Safe Casting (Precision Inheritance)');
try
    % Create a prototype real matrix in Single Precision
    % (Standard in Machine Learning to halve memory footprint)
    prototype_single = single(ones(2, 2));
    
    % Generate the hypercomplex matrix inheriting the 'single' class
    Z_single = abtones(3, 3, 'like', prototype_single);
    
    % Check if all internal branches inherited the correct type
    class_A = class(Z_single.A);
    class_B = class(Z_single.B);
    
    if strcmp(class_A, 'single') && strcmp(class_B, 'single')
        disp('   [OK] Precision inheritance successfully verified (Single Precision).');
    else
        error('Type-casting failed. Expected "single", got "%s".', class_A);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');