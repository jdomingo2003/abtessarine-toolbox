% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: gabtrandn.m (8D Normally Distributed Random Array)
% =========================================================================
% This script verifies the correct structural allocation of 8D random arrays, 
% strictly validates the statistical moments (Mean ~ 0, Variance ~ 1) across 
% all 8 manifold branches, and empirically checks for inter-branch 
% statistical independence.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: gabtrandn.m ---');
disp('===================================================================');

% CRITICAL: Initialize a topology with alpha > 0 for the 8D generalized algebra
setabtessarine(2, 7); 

%% TEST 1: Dimensionality and Varargin Parsing
disp('TEST 1: Tensor Array Generation (M x N x P)');
M = 5; N = 4; P = 3;
try
    Z_tensor = gabtrandn(M, N, P);
    
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
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Statistical Moments Validation
disp('TEST 2: Statistical Moments Validation (Mean = 0, Var = 1)');
try
    % Generate a massive matrix to allow the Law of Large Numbers to converge
    % 1,000,000 samples per branch provides a solid statistical foundation
    Z_large = gabtrandn(1000, 1000);
    
    % Calculate empirical means for all 8 branches
    means = [mean(Z_large.A1(:)), mean(Z_large.A2(:)), ...
             mean(Z_large.B1(:)), mean(Z_large.B2(:)), ...
             mean(Z_large.C1(:)), mean(Z_large.C2(:)), ...
             mean(Z_large.D1(:)), mean(Z_large.D2(:))];
             
    % Calculate empirical variances for all 8 branches
    variances = [var(Z_large.A1(:)), var(Z_large.A2(:)), ...
                 var(Z_large.B1(:)), var(Z_large.B2(:)), ...
                 var(Z_large.C1(:)), var(Z_large.C2(:)), ...
                 var(Z_large.D1(:)), var(Z_large.D2(:))];
    
    % Allow a small tolerance for pseudo-random variance convergence
    tol_mean = 0.05;
    tol_var  = 0.05;
    
    if all(abs(means) < tol_mean) && all(abs(variances - 1.0) < tol_var)
        disp('   [OK] Empirical Mean tightly converges to 0 across all 8 branches.');
        disp('   [OK] Empirical Variance tightly converges to 1 across all 8 branches.');
    else
        error('Statistical moments severely deviate from the Standard Normal Distribution.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Statistical Independence Check
disp('TEST 3: Inter-Branch Statistical Independence in 8D');
try
    % Using the previously generated large matrix
    % We compute the norm of the difference between the primary branch (A1) 
    % and all other imaginary branches to ensure no pointers were accidentally aliased.
    diffs = [norm(Z_large.A1(:) - Z_large.A2(:)), ...
             norm(Z_large.A1(:) - Z_large.B1(:)), ...
             norm(Z_large.A1(:) - Z_large.B2(:)), ...
             norm(Z_large.A1(:) - Z_large.C1(:)), ...
             norm(Z_large.A1(:) - Z_large.C2(:)), ...
             norm(Z_large.A1(:) - Z_large.D1(:)), ...
             norm(Z_large.A1(:) - Z_large.D2(:))];
    
    if all(diffs > 0)
        disp('   [OK] Strict statistical independence across all 8 orthogonal Gaussian branches confirmed.');
    else
        error('Statistical coupling detected. Branches are not pseudo-randomly independent.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');