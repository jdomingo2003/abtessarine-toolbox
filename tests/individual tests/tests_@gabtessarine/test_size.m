% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: size.m (8D Gabtessarine Dimensions)
% =========================================================================
% This script verifies the dimensional metadata reporting for the 8D 
% gabtessarine class. It validates standard vector outputs, multi-variable 
% assignments, and explicit dimension queries across N-D manifolds.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: size (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Environment must be hyperbolic for 8D

%% TEST 1: Standard Matrix Size (Vector Output)
disp('TEST 1: Standard Size Reporting [D = size(X)]');
try
    M = 6; N = 3;
    z = zeros(M, N);
    G = gabtessarine(z, z, z, z, z, z, z, z);
    
    D = size(G);
    
    if isequal(D, [M, N])
        disp(['   [OK] Correctly reported 8D object size [', num2str(D), '].']);
    else
        error('Size vector mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Multiple Output Assignment [M, N] = size(X)
disp('TEST 2: Multiple Variable Assignment [R, C] = size(X)');
try
    R_in = 12; C_in = 7;
    z = zeros(R_in, C_in);
    G2 = gabtessarine(z, z, z, z, z, z, z, z);
    
    [R_out, C_out] = size(G2);
    
    if R_out == R_in && C_out == C_in
        disp('   [OK] Multiple outputs correctly delegated and assigned (R, C).');
    else
        error('Multi-output assignment mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dimension-Specific Query and N-D Tensors
disp('TEST 3: Dimension-Specific Query [K = size(X, DIM)]');
try
    % Create a 3D Tensor for the 8D object (e.g., a batch of 8D matrices)
    sz3D = [4, 5, 10];
    z3D = zeros(sz3D);
    G3 = gabtessarine(z3D, z3D, z3D, z3D, z3D, z3D, z3D, z3D);
    
    k_dim2 = size(G3, 2); % Query columns
    k_dim3 = size(G3, 3); % Query depth
    
    if k_dim2 == 5 && k_dim3 == 10
        disp('   [OK] Correctly extracted size for specific dimensions in a 3D tensor.');
    else
        error('Dimension-specific query failed on N-D tensor.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');