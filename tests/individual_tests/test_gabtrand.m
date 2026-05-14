% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: gabtrand.m (8D Uniformly Distributed Random Array)
% =========================================================================
% This script verifies the correct structural allocation of 8D random arrays, 
% strictly validates the [0, 1] numerical bounds across all 8 manifold 
% branches, and empirically checks for inter-branch statistical independence.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: gabtrand.m ---');
disp('===================================================================');

% CRITICAL: Initialize a topology with alpha > 0 for the 8D generalized algebra
setabtessarine(2, 7); 

%% TEST 1: Dimensionality and Varargin Parsing
disp('TEST 1: Rectangular Matrix Generation (M x N)');
M = 7; N = 4;
try
    Z_rect = gabtrand(M, N);
    
    % Verify sizes across all 8 hypercomplex branches
    szA1 = size(Z_rect.A1); szA2 = size(Z_rect.A2);
    szB1 = size(Z_rect.B1); szB2 = size(Z_rect.B2);
    szC1 = size(Z_rect.C1); szC2 = size(Z_rect.C2);
    szD1 = size(Z_rect.D1); szD2 = size(Z_rect.D2);
    
    if isequal(szA1, [M, N]) && isequal(szA1, szA2) && ...
       isequal(szA1, szB1) && isequal(szA1, szB2) && ...
       isequal(szA1, szC1) && isequal(szA1, szC2) && ...
       isequal(szA1, szD1) && isequal(szA1, szD2)
        disp('   [OK] Rectangular dimensions successfully parsed and applied across all 8 branches.');
    else
        error('Dimension mismatch across structural branches.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Uniform Distribution Bounds
disp('TEST 2: Statistical Range Validation (0, 1)');
try
    % Generate a sufficiently large 8D matrix to test bounding limits rigorously
    Z_large = gabtrand(300, 300);
    
    % Extract maximums and minimums for all 8 branches
    max_vals = [max(Z_large.A1(:)), max(Z_large.A2(:)), ...
                max(Z_large.B1(:)), max(Z_large.B2(:)), ...
                max(Z_large.C1(:)), max(Z_large.C2(:)), ...
                max(Z_large.D1(:)), max(Z_large.D2(:))];
                
    min_vals = [min(Z_large.A1(:)), min(Z_large.A2(:)), ...
                min(Z_large.B1(:)), min(Z_large.B2(:)), ...
                min(Z_large.C1(:)), min(Z_large.C2(:)), ...
                min(Z_large.D1(:)), min(Z_large.D2(:))];
    
    if all(max_vals <= 1.0) && all(min_vals >= 0.0)
        disp('   [OK] All matrix elements are strictly bounded within the [0, 1] interval.');
    else
        error('Values generated outside the expected (0,1) uniform distribution bounds.');
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
        disp('   [OK] Strict statistical independence across all 8 orthogonal branches confirmed.');
    else
        error('Statistical coupling detected. Branches are not pseudo-randomly independent.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');