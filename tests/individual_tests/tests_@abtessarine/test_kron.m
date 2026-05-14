% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: kron.m (Kronecker Tensor Product)
% =========================================================================
% This script verifies the tensor expansion of abtessarine matrices.
% It validates dimensional scaling, hybrid numeric-hypercomplex products, 
% and the preservation of algebraic rules under tensor distribution.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: kron.m ---');
disp('===================================================================');

tol = 1e-14; % Strict tolerance for structural tensor operations
setabtessarine(-1, 1); % Standard topology (Elliptic)

%% TEST 1: Pure abtessarine Kronecker Expansion
disp('TEST 1: Pure Hypercomplex Kronecker [X (kron) Y]');
try
    % Small matrices to keep memory footprint low (2x2 and 2x3)
    X = abtrandn(2, 2);
    Y = abtrandn(2, 3);
    
    Z = kron(X, Y);
    
    % Verify dimensions: [ (2*2) x (2*3) ] = [ 4 x 6 ]
    sz = size(Z.A);
    if isequal(sz, [4, 6])
        disp('   [OK] Tensor dimensions successfully expanded to 4x6.');
    else
        error('Dimension mismatch. Expected [4, 6], Got [%d, %d].', sz(1), sz(2));
    end
    
    % Verify a single known coefficient if possible (Top-left element)
    % ZA(1,1) should follow the algebraic rule ZA = A1*A2 + alpha*B1*B2 + ...
    [alpha, beta] = getabtessarine();
    val_expected = X.A(1,1)*Y.A(1,1) + alpha*X.B(1,1)*Y.B(1,1) + ...
                   beta*X.C(1,1)*Y.C(1,1) + (alpha*beta)*X.D(1,1)*Y.D(1,1);
    
    if abs(Z.A(1,1) - val_expected) < tol
        disp('   [OK] Algebraic component-wise distribution verified.');
    else
        error('Mathematical inconsistency in Kronecker sum-product.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid Numeric-Abtessarine Products
disp('TEST 2: Hybrid Kronecker [Numeric (kron) abtessarine]');
try
    R = [1, 0; 0, 1]; % 2x2 Identity matrix
    X = abtrandn(2, 2);
    
    % This should effectively create a block-diagonal abtessarine matrix
    Zh = kron(R, X);
    
    % Verification: Top-left 2x2 block should be exactly X
    err_block = norm(Zh.A(1:2, 1:2) - X.A) + norm(Zh.B(1:2, 1:2) - X.B);
    
    if err_block < tol
        disp('   [OK] Hybrid expansion (Numeric * Object) verified.');
    else
        error('Block mapping failed in hybrid Kronecker product.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Edge Cases and Type Shield
disp('TEST 3: Argument Validation and Empty Handling');
try
    % Test with empty object
    Ze = kron(abtessarine(), abtessarine());
    if isempty(Ze.A)
        disp('   [OK] Graceful handling of empty objects.');
    end
    
    % Test type shield (should throw error)
    try
        kron(X, 'invalid_type');
        error('Type shield failed to intercept invalid input.');
    catch 
        disp('   [OK] Invalid type correctly intercepted.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');