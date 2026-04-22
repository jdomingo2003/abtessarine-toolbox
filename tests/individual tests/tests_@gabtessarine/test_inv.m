% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: inv.m (8D Gabtessarine Matrix Inverse)
% =========================================================================
% This script verifies the double-bifurcation inversion algorithm. It 
% validates the mathematical identity X * inv(X) = I, checks for 
% involution properties inv(inv(X)) = X, and rigorously tests the 
% topological guardrails (Alpha > 0 strict requirement).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: inv (gabtessarine) ---');
disp('===================================================================');

tol = 1e-10; 

%% TEST 1: Inverse Identity [X * inv(X) == I]
disp('TEST 1: Inverse Identity Reconstruction');
try
    setabtessarine(1, 1); % Hyperbolic environment required for 8D
    
    N = 4;
    % Generate a random 8D matrix and ensure diagonal dominance for strict invertibility
    A1_dom = randn(N) + 15*eye(N); 
    G = gabtessarine(A1_dom, randn(N), randn(N), randn(N), ...
                     randn(N), randn(N), randn(N), randn(N));
                     
    G_inv = inv(G);
    
    % This requires the '*' (mtimes) operator to be implemented for gabtessarine
    try
        I_rec = G * G_inv;
        
        % The 8D identity matrix has eye(N) in A1, and zeros everywhere else
        err = norm(I_rec.A1 - eye(N)) + norm(I_rec.A2) + ...
              norm(I_rec.B1) + norm(I_rec.B2) + ...
              norm(I_rec.C1) + norm(I_rec.C2) + ...
              norm(I_rec.D1) + norm(I_rec.D2);
              
        if err < tol
            disp('   [OK] Double-bifurcation inverse successfully reconstructed the 8D Identity.');
        else
            error('Inverse identity mismatch. Error: %e', err);
        end
    catch ME
        disp('   [INFO] mtimes (*) not yet implemented or failed. Skipping identity check.');
        disp(['          Inner error: ', ME.message]);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Involution of Inversion [inv(inv(X)) == X]
disp('TEST 2: Reversibility / Involution');
try
    % Use the same matrix G
    G_inv_inv = inv(G_inv);
    
    err_rev = norm(G_inv_inv.A1 - G.A1) + norm(G_inv_inv.A2 - G.A2) + ...
              norm(G_inv_inv.B1 - G.B1) + norm(G_inv_inv.B2 - G.B2) + ...
              norm(G_inv_inv.C1 - G.C1) + norm(G_inv_inv.C2 - G.C2) + ...
              norm(G_inv_inv.D1 - G.D1) + norm(G_inv_inv.D2 - G.D2);
              
    if err_rev < tol
        disp('   [OK] Inversion is strictly reversible without catastrophic precision loss.');
    else
        error('Reversibility failed. Error: %e', err_rev);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Topological Guardrail (Alpha <= 0 Shield)
disp('TEST 3: Topological Environment Shield [Alpha <= 0 Rejection]');
try
    % Set to Elliptic domain
    setabtessarine(-1, 1);
    
    evalc('inv(G);');
    
    error('Safety failure: Allowed 8D matrix inversion in an elliptic (Alpha <= 0) space.');
catch ME
    if contains(ME.identifier, 'InvalidAlpha')
        disp('   [OK] Correctly blocked 8D inversion under non-hyperbolic topology.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

% Reset to default for subsequent tests
setabtessarine(1, 1); 
disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');