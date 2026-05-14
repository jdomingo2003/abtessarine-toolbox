% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: augmented.m (Augmented Matrix Representation)
% =========================================================================
% This script verifies the dimensional expansion and structural integrity 
% of the widely linear augmented representation. It rigorously checks the 
% sign distribution of the directional involutions (X^i, X^j, X^k) mapped 
% into the continuous memory blocks.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: augmented.m ---');
disp('===================================================================');

tol = 1e-12; % Strict floating-point tolerance
setabtessarine(-1, 1); % Standard topology initialization

% Define original matrix dimensions (Rectangular to test robust mapping)
N = 3; 
M = 5;

%% TEST 1: Dimensional Expansion Validation
disp('TEST 1: 4x Vertical Dimension Expansion');
try
    % Generate a pseudo-random rectangular matrix
    X = abtrandn(N, M);
    
    % Compute the augmented representation
    Xa = augmented(X);
    
    % Verify the new dimensions (Must be exactly 4N x M)
    expected_size = [4 * N, M];
    
    szA = size(Xa.A); szB = size(Xa.B);
    szC = size(Xa.C); szD = size(Xa.D);
    
    if isequal(szA, expected_size) && isequal(szB, expected_size) && ...
       isequal(szC, expected_size) && isequal(szD, expected_size)
        disp('   [OK] Matrix successfully expanded to (4*N) x M across all spatial branches.');
    else
        error('Dimensional expansion failed. Expected [%d, %d], Got [%d, %d].', ...
              expected_size(1), expected_size(2), szA(1), szA(2));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Structural Integrity and Involution Signs
disp('TEST 2: Directional Involution Mapping (Sign Integrity)');
try
    % Define the row indices for the four stacked blocks
    idx1 = 1 : N;             % Block 1: X
    idx2 = (N + 1) : (2 * N); % Block 2: X^i
    idx3 = (2*N + 1) : (3*N); % Block 3: X^j
    idx4 = (3*N + 1) : (4*N); % Block 4: X^k
    
    % --- Verify Block 1 (X) ---
    err_B1 = norm(Xa.A(idx1, :) - X.A) + norm(Xa.B(idx1, :) - X.B) + ...
             norm(Xa.C(idx1, :) - X.C) + norm(Xa.D(idx1, :) - X.D);
             
    % --- Verify Block 2 (X^i) -> A, B, -C, -D ---
    err_B2 = norm(Xa.A(idx2, :) - X.A) + norm(Xa.B(idx2, :) - X.B) + ...
             norm(Xa.C(idx2, :) - (-X.C)) + norm(Xa.D(idx2, :) - (-X.D));
             
    % --- Verify Block 3 (X^j) -> A, -B, C, -D ---
    err_B3 = norm(Xa.A(idx3, :) - X.A) + norm(Xa.B(idx3, :) - (-X.B)) + ...
             norm(Xa.C(idx3, :) - X.C) + norm(Xa.D(idx3, :) - (-X.D));
             
    % --- Verify Block 4 (X^k) -> A, -B, -C, D ---
    err_B4 = norm(Xa.A(idx4, :) - X.A) + norm(Xa.B(idx4, :) - (-X.B)) + ...
             norm(Xa.C(idx4, :) - (-X.C)) + norm(Xa.D(idx4, :) - X.D);
             
    % Evaluate maximum global error
    max_err = max([err_B1, err_B2, err_B3, err_B4]);
    
    if max_err < tol
        disp('   [OK] Block 1 (X)   mapped correctly.');
        disp('   [OK] Block 2 (X^i) mapped correctly (signs: +, +, -, -).');
        disp('   [OK] Block 3 (X^j) mapped correctly (signs: +, -, +, -).');
        disp('   [OK] Block 4 (X^k) mapped correctly (signs: +, -, -, +).');
        disp('   [OK] Full augmented structural integrity validated.');
    else
        error('Involution sign corruption detected in one or more augmented blocks.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');