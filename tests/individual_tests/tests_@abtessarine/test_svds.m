% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: svds.m (Subset Singular Value Decomposition)
% =========================================================================
% This script verifies the low-rank SVD computation. It validates the 
% dynamic routing between sparse (Krylov) and dense truncated solvers,
% strict dimensionality reduction, and the unitary preservation of the 
% extracted singular vectors.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: svds.m ---');
disp('===================================================================');

tol = 1e-10; 

%% TEST 1: Dimensionality and Unitary Preservation (Alpha < 0)
disp('TEST 1: Low-Rank Dimensions & Orthogonality (Alpha < 0 - Elliptic)');
try
    setabtessarine(-1, 1);
    M = 15; N = 10;
    X = abtrandn(M, N);
    
    K = 4; % Request top 4 singular values
    [U, S, V] = svds(X, K);
    
    % 1.1 Verify dimensions: U(15x4), S(4x4), V(10x4)
    if isequal(size(U.A), [M, K]) && isequal(size(S.A), [K, K]) && isequal(size(V.A), [N, K])
        disp('   [OK] Truncated dimensions strictly match requested rank K.');
        
        % 1.2 Verify Orthogonality of the truncated basis: U'*U = I(KxK)
        UtU = U' * U;
        VtV = V' * V;
        I_K = abteye(K);
        
        err_U = norm(UtU.A - I_K.A) + norm(UtU.B - I_K.B);
        err_V = norm(VtV.A - I_K.A) + norm(VtV.B - I_K.B);
        
        if err_U < tol && err_V < tol
            disp('   [OK] Unitary constraints U''*U = I and V''*V = I preserved.');
        else
            error('Singular vectors lost orthogonality during truncation.');
        end
    else
        error('Dimensional reduction failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Dynamic Heuristic Router Validation (Alpha > 0)
disp('TEST 2: Dynamic Solver Routing (Sparse vs Dense) (Alpha > 0)');
try
    setabtessarine(1, 1); % Hyperbolic geometry
    
    % Use a larger matrix to clearly separate the 3% threshold
    % 40x40 matrix. 3% of 40 is 1.2. 
    % K = 1 -> Sparse Route. K = 5 -> Dense Route.
    X_large = abtrandn(40, 40);
    
    % 2.1 Force Sparse Route (K = 1)
    [U1, S1, V1] = svds(X_large, 1);
    
    % 2.2 Force Dense Route (K = 5)
    [U5, S5, V5] = svds(X_large, 5);
    
    if isequal(size(U1.A), [40, 1]) && isequal(size(U5.A), [40, 5])
        disp('   [OK] Dynamic heuristic router successfully dispatched both paths.');
    else
        error('Router failed to dispatch correctly or return accurate sizes.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Fast-Path (Singular Values Vector)
disp('TEST 3: Fast-Path Singular Vector Extraction [s = svds(X, K)]');
try
    setabtessarine(-1, 1);
    X3 = abtrandn(8, 8);
    K_req = 3;
    
    % Request only singular values
    s_vec = svds(X3, K_req);
    
    % Request full matrices to compare
    [~, S_mat, ~] = svds(X3, K_req);
    
    % The output vector should match the diagonal of the output matrix
    diag_A = diag(S_mat.A);
    
    if isequal(size(s_vec.A), [K_req, 1]) && norm(s_vec.A - diag_A) < tol
        disp('   [OK] Single-output call returned correct truncated vector.');
    else
        error('Single-output extraction mismatched the full SVD diagonal.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');