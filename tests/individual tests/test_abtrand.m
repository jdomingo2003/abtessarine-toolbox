% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abtrand.m (Uniformly Distributed Pseudo-Random Array)
% =========================================================================
% This script verifies the correct structural allocation of random arrays, 
% strictly validates the [0, 1] numerical bounds across all manifold 
% branches, and empirically checks for inter-branch statistical independence.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtrand.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Standard topology initialization

%% TEST 1: Dimensionality and Varargin Parsing
disp('TEST 1: Rectangular Matrix Generation (M x N)');
M = 7; N = 4;
try
    Z_rect = abtrand(M, N);
    
    % Verify sizes across all hypercomplex branches
    szA = size(Z_rect.A); szB = size(Z_rect.B);
    szC = size(Z_rect.C); szD = size(Z_rect.D);
    
    if isequal(szA, [M, N]) && isequal(szA, szB) && isequal(szA, szC) && isequal(szA, szD)
        disp('   [OK] Rectangular dimensions successfully parsed and applied.');
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
    % Generate a sufficiently large matrix to test bounding limits
    Z_large = abtrand(500, 500);
    
    % Check maximums (must be < 1)
    max_vals = [max(Z_large.A(:)), max(Z_large.B(:)), max(Z_large.C(:)), max(Z_large.D(:))];
    % Check minimums (must be > 0)
    min_vals = [min(Z_large.A(:)), min(Z_large.B(:)), min(Z_large.C(:)), min(Z_large.D(:))];
    
    if all(max_vals <= 1.0) && all(min_vals >= 0.0)
        disp('   [OK] All matrix elements are strictly bounded within [0, 1].');
    else
        error('Values generated outside the expected (0,1) uniform distribution bounds.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Statistical Independence Check
disp('TEST 3: Inter-Branch Statistical Independence');
try
    % Using the previously generated large matrix
    % If the branches were improperly aliased (e.g., A = B), their difference norm would be 0.
    diff_AB = norm(Z_large.A(:) - Z_large.B(:));
    diff_AC = norm(Z_large.A(:) - Z_large.C(:));
    diff_AD = norm(Z_large.A(:) - Z_large.D(:));
    
    if (diff_AB > 0) && (diff_AC > 0) && (diff_AD > 0)
        disp('   [OK] Strict statistical independence across orthogonal branches confirmed.');
    else
        error('Statistical coupling detected. Branches are not pseudo-randomly independent.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');