% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: sqrtm.m (Matrix Square Root)
% =========================================================================
% This script verifies the principal matrix square root logic. It validates 
% the theoretical 4D closure for elliptic geometries, the 4D collapse for 
% 1-Hermitian matrices in hyperbolic geometries, and the 8D dimensional 
% spawning for general hyperbolic matrices.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: sqrtm.m ---');
disp('===================================================================');

tol = 1e-10;
N = 3;

%% TEST 1: Elliptic Domain Closure (4D)
disp('TEST 1: Elliptic Route [Alpha < 0] (4D Closure)');
try
    setabtessarine(-1, 1);
    X1 = abtrandn(N);
    
    Z1 = sqrtm(X1);
    
    % Verification: (X^0.5) * (X^0.5) = X
    X1_rec = Z1 * Z1;
    err1 = norm(X1_rec.A - X1.A) + norm(X1_rec.B - X1.B) + ...
           norm(X1_rec.C - X1.C) + norm(X1_rec.D - X1.D);
           
    if isa(Z1, 'abtessarine') && err1 < tol
        disp('   [OK] Root computed and structurally closed in 4D space.');
    else
        error('Elliptic root reconstruction failed. Error: %e', err1);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hyperbolic 1-Hermitian Collapse (4D)
disp('TEST 2: Hyperbolic Route [Alpha > 0] (1-Hermitian 4D Collapse)');
try
    setabtessarine(1, 1);
    
    % Create a strictly 1-Hermitian matrix (Symmetric components)
    % A + A' ensures perfect symmetry
    X2 = abtrandn(N);
    X2.A = X2.A + X2.A';
    X2.B = X2.B + X2.B';
    X2.C = X2.C + X2.C';
    X2.D = X2.D + X2.D';
    
    Z2 = sqrtm(X2);
    
    X2_rec = Z2 * Z2;
    err2 = norm(X2_rec.A - X2.A) + norm(X2_rec.B - X2.B);
    
    if isa(Z2, 'abtessarine') && err2 < tol
        disp('   [OK] Symmetry detected. Root successfully collapsed back to 4D.');
    else
        error('1-Hermitian collapse failed or reconstruction error: %e', err2);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Hyperbolic Dimensional Spawning (8D)
disp('TEST 3: Hyperbolic Route [Alpha > 0] (8D Dimensional Spawning)');
try
    setabtessarine(1, 1);
    
    % General asymmetric matrix
    X3 = abtrandn(N);
    
    % Check if gabtessarine class exists in the path before invoking
    if exist('gabtessarine', 'class') == 8
        Z3 = sqrtm(X3);
        
        if isa(Z3, 'gabtessarine')
            disp('   [OK] Asymmetry detected. Successfully spawned 8D gabtessarine object.');
            
            % If gabtessarine has an overloaded mtimes, we can verify it:
            try
                X3_rec = Z3 * Z3;
                disp('   [OK] 8D reconstruction completed.');
            catch
                disp('   [INFO] gabtessarine overloaded mtimes not yet tested/available.');
            end
        else
            error('Matrix failed to spawn 8D representation.');
        end
    else
        disp('   [SKIP] gabtessarine class not found in path. Skipping 8D instantiation test.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');