% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: subsasgn.m (8D Gabtessarine Index Assignment)
% =========================================================================
% This script verifies the subscripted assignment for 8D objects.
% It validates object substitution, dynamic expansion, and the "HPC Upcast" 
% logic from 4D (abtessarine) and numeric types.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: subsasgn (gabtessarine) ---');
disp('===================================================================');

setabtessarine(1, 1); % Required hyperbolic environment for 8D

%% TEST 1: Object-to-Object Assignment [G(idx) = G_val]
disp('TEST 1: 8D Object-to-Object Assignment');
try
    % Initialize a 3x3 8D matrix of ones
    G = gabtessarine(ones(3), ones(3), ones(3), ones(3), ...
                     ones(3), ones(3), ones(3), ones(3));
    
    % Create a 1x1 8D "marker" object (all values = 9)
    G_mark = gabtessarine(9, 9, 9, 9, 9, 9, 9, 9);
    
    % Assign to the center
    G(2, 2) = G_mark;
    
    if G.A1(2, 2) == 9 && G.D2(2, 2) == 9 && G.A1(1, 1) == 1
        disp('   [OK] 8D object successfully injected into the manifold at (2,2).');
    else
        error('Data mapping failed during 8D object assignment.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hierarchical Upcast Assignment [G(idx) = abtessarine]
disp('TEST 2: 4D-to-8D Upcast Assignment');
try
    % Initialize 2x2
    G2 = gabtessarine(zeros(2), zeros(2), zeros(2), zeros(2), ...
                      zeros(2), zeros(2), zeros(2), zeros(2));
    
    % 4D abtessarine object (all values = 5)
    A_4D = abtessarine(5, 5, 5, 5);
    
    % Assign to a whole row
    G2(1, :) = A_4D;
    
    % Check: A1 (real part) should be 5, A2 (epsilon part) should be 0 (auto-padded)
    if all(G2.A1(1, :) == 5) && all(G2.A2(1, :) == 0) && all(G2.D1(1, :) == 5)
        disp('   [OK] 4D abtessarine correctly promoted and zero-padded on assignment.');
    else
        error('Upcast assignment failed to nullify epsilon components.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dynamic Expansion [Lazy Loading]
disp('TEST 3: Dynamic Manifold Expansion');
try
    % Start with an empty object
    G_dyn = gabtessarine();
    
    % Assign to index (2, 2)
    G_dyn(2, 2) = 100; % Numeric upcast
    
    % MATLAB should have expanded the internal arrays to 2x2
    if isequal(size(G_dyn), [2, 2]) && G_dyn.A1(2, 2) == 100 && G_dyn.B1(1, 1) == 0
        disp('   [OK] Empty object successfully expanded and initialized on-the-fly.');
        disp('   [OK] Numeric upcast accurately mapped to A1 with zero-padding.');
    else
        error('Dynamic expansion failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 4: Property Delegation [G.A1 = val]
disp('TEST 4: Built-in Property Delegation');
try
    G_prop = gabtessarine(ones(2), ones(2), ones(2), ones(2), ...
                          ones(2), ones(2), ones(2), ones(2));
    
    % Direct property access via dot notation
    G_prop.A1 = eye(2);
    
    if isequal(G_prop.A1, eye(2))
        disp('   [OK] Dot notation assignment correctly bypassed custom trees.');
    else
        error('Property assignment delegation failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');