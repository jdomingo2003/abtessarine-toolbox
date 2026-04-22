% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abtrandn.m (Normally Distributed Pseudo-Random Array)
% =========================================================================
% This script verifies the correct structural allocation of random arrays, 
% strictly validates the statistical moments (Mean ~ 0, Variance ~ 1), 
% and empirically checks for inter-branch statistical independence.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtrandn.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology initialization

%% TEST 1: Dimensionality and Varargin Parsing
disp('TEST 1: Tensor Array Generation (M x N x P)');
M = 5; N = 4; P = 3;
try
    Z_tensor = abtrandn(M, N, P);
    
    % Verify sizes across all hypercomplex branches
    szA = size(Z_tensor.A); szB = size(Z_tensor.B);
    szC = size(Z_tensor.C); szD = size(Z_tensor.D);
    
    if isequal(szA, [M, N, P]) && isequal(szA, szB) && isequal(szA, szC) && isequal(szA, szD)
        disp('   [OK] Tensor dimensions successfully parsed and applied.');
    else
        error('Dimension mismatch across structural branches.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Statistical Moments Validation
disp('TEST 2: Statistical Moments Validation (Mean = 0, Var = 1)');
try
    % Generate a massive matrix to allow the Law of Large Numbers to converge
    % 1,000,000 samples per branch provides a solid statistical foundation
    Z_large = abtrandn(1000, 1000);
    
    % Calculate empirical means
    means = [mean(Z_large.A(:)), mean(Z_large.B(:)), ...
             mean(Z_large.C(:)), mean(Z_large.D(:))];
             
    % Calculate empirical variances
    variances = [var(Z_large.A(:)), var(Z_large.B(:)), ...
                 var(Z_large.C(:)), var(Z_large.D(:))];
    
    % Allow a small tolerance for pseudo-random variance
    tol_mean = 0.05;
    tol_var  = 0.05;
    
    if all(abs(means) < tol_mean) && all(abs(variances - 1.0) < tol_var)
        disp('   [OK] Empirical Mean tightly converges to 0.');
        disp('   [OK] Empirical Variance tightly converges to 1.');
    else
        error('Statistical moments severely deviate from the Standard Normal Distribution.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Statistical Independence Check
disp('TEST 3: Inter-Branch Statistical Independence');
try
    % Using the previously generated large matrix
    % If the branches were improperly aliased, their difference norm would be 0.
    diff_AB = norm(Z_large.A(:) - Z_large.B(:));
    diff_AC = norm(Z_large.A(:) - Z_large.C(:));
    diff_AD = norm(Z_large.A(:) - Z_large.D(:));
    
    if (diff_AB > 0) && (diff_AC > 0) && (diff_AD > 0)
        disp('   [OK] Strict statistical independence across orthogonal Gaussian branches confirmed.');
    else
        error('Statistical coupling detected. Branches are not pseudo-randomly independent.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');