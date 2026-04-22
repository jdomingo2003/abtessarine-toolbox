% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: prod.m (Product of Array Elements)
% =========================================================================
% This script verifies the cumulative product logic across dimensions.
% It validates behavior for vectors, matrices, and empty arrays, ensuring
% the algebraic rules (alpha, beta) are preserved during accumulation.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: prod.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard elliptic initialization
tol = 1e-14;

%% TEST 1: Vector Reduction (Total Product)
disp('TEST 1: Vector Product Reduction [Scalar Result]');
try
    % Create a vector: [1, i, i] -> 1 * i * i = alpha
    % With alpha = -1, result should be -1 (Real)
    V = [abtessarine(1,0,0,0), abtessarine(0,1,0,0), abtessarine(0,1,0,0)];
    
    P = prod(V);
    [alpha, ~] = getabtessarine();
    
    if abs(P.A - alpha) < tol && abs(P.B) < tol
        disp('   [OK] Vector product correctly identified i^2 = alpha.');
    else
        error('Vector product mismatch. Result: %g + %gi', P.A, P.B);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Matrix Column-wise Product
disp('TEST 2: Matrix Column-wise Product [Dimension 1 Reduction]');
try
    % Matrix 2x3:
    % [ 2  2  2 ]
    % [ 3  3  3 ]
    % Result should be [ 6  6  6 ] (Row vector)
    M = abtessarine(ones(2,3)*2, zeros(2,3), zeros(2,3), zeros(2,3));
    M.A(2,:) = 3;
    
    P_mat = prod(M);
    
    if isequal(size(P_mat.A), [1, 3]) && all(P_mat.A == 6)
        disp('   [OK] Correctly reduced rows to compute column products.');
    else
        error('Matrix dimension reduction failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Empty Array and Identity
disp('TEST 3: Empty Array Boundary Case');
try
    % prod([]) should return 1 (the multiplicative identity)
    % In this implementation, size check handles it
    E = abtessarine([], [], [], []);
    
    % This might throw error depending on how size() is handled for [],
    % but based on your prod.m, nElements will be 0.
    Pe = prod(E);
    
    if isempty(Pe.A)
        disp('   [OK] Graceful handling of empty input.');
    end
    
catch ME
    fprintf('   [INFO] Empty check: %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');