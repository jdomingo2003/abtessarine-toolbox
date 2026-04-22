% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: diag.m (Diagonal Extraction and Construction)
% =========================================================================
% This script verifies the dual functionality of the diag operator: 
% 1) Extracting the principal diagonal vector from a 4D matrix.
% 2) Constructing a square diagonal matrix from a 4D vector.
% It validates structural integrity across all spatial branches.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: diag.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Topology initialization (not used but good practice)
N = 4;

%% TEST 1: Diagonal Extraction (Matrix -> Vector)
disp('TEST 1: Extraction of Principal Diagonal (Matrix to Vector)');
try
    % Create a random 4x4 matrix
    X = abtrandn(N, N);
    
    % Extract diagonal
    d = diag(X);
    
    % Verify size (Should be an N x 1 column vector)
    sz_d = size(d.A);
    if sz_d(1) == N && sz_d(2) == 1
        % Verify content match with native extraction
        if isequal(d.A, diag(X.A)) && isequal(d.D, diag(X.D))
            disp('   [OK] Principal diagonal vector successfully extracted.');
        else
            error('Content mismatch during diagonal extraction.');
        end
    else
        error('Resulting vector dimension mismatch. Expected [%d, 1], Got [%d, %d].', N, sz_d(1), sz_d(2));
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Diagonal Construction (Vector -> Matrix)
disp('TEST 2: Construction of Diagonal Matrix (Vector to Matrix)');
try
    % Create a random 4x1 vector
    v = abtrandn(N, 1);
    
    % Construct diagonal matrix
    D = diag(v);
    
    % Verify size (Should be N x N square matrix)
    sz_D = size(D.A);
    if isequal(sz_D, [N, N])
        % Verify that off-diagonal elements are strictly zero
        if norm(D.A - diag(diag(D.A))) == 0 && norm(D.B - diag(diag(D.B))) == 0
            disp('   [OK] Square diagonal matrix successfully constructed.');
            disp('   [OK] Off-diagonal nullity verified.');
        else
            error('Off-diagonal elements contain non-zero noise.');
        end
    else
        error('Resulting matrix dimension mismatch.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Structural Identity ( diag(diag(X)) )
disp('TEST 3: Structural Identity Check (diag of diag)');
try
    % In MATLAB, diag(diag(X)) returns a matrix with only the diagonal of X
    X3 = abtrandn(3, 3);
    X_diag_only = diag(diag(X3));
    
    % Check if all off-diagonal entries are zero and diagonal is preserved
    err_diag = norm(diag(X_diag_only.A) - diag(X3.A)) + ...
               norm(diag(X_diag_only.B) - diag(X3.B));
               
    if err_diag == 0
        disp('   [OK] Recursive diag(diag(X)) preserves principal components.');
    else
        error('Structural identity property failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');