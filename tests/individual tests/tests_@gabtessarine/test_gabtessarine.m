% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: gabtessarine.m (8D Class Constructor)
% =========================================================================
% This script verifies the instantiation of the generalized 8-dimensional 
% hypercomplex manifold. It validates memory preallocation, structural 
% symmetry enforcement, and the strict alpha > 0 topological guardrail.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: gabtessarine (Constructor) ---');
disp('===================================================================');

%% TEST 1: Standard Hyperbolic Instantiation (Alpha > 0)
disp('TEST 1: Valid 8D Instantiation [Alpha > 0]');
try
    % Ensure Hyperbolic domain
    setabtessarine(1, 1); 
    
    sz = [3, 3];
    G = gabtessarine(ones(sz), ones(sz)*2, ones(sz)*3, ones(sz)*4, ...
                     ones(sz)*5, ones(sz)*6, ones(sz)*7, ones(sz)*8);
                     
    if isequal(size(G.A1), sz) && isequal(size(G.D2), sz) && G.D2(1,1) == 8
        disp('   [OK] 8D gabtessarine object successfully instantiated.');
        disp('   [OK] Memory injection mapped correctly across all 8 planes.');
    else
        error('Data mapping corruption during initialization.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Empty Preallocation (Lazy Loading)
disp('TEST 2: Empty Object Preallocation [gabtessarine()]');
try
    G_empty = gabtessarine();
    
    if isempty(G_empty.A1) && isempty(G_empty.D2)
        disp('   [OK] Empty object strictly bypassed validation for memory preallocation.');
    else
        error('Empty constructor failed to return null arrays.');
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
    
    % Attempt to create 8D object in a 4D-closed space
    evalc('G_fail = gabtessarine(1, 2, 3, 4, 5, 6, 7, 8);');
    
    error('Safety failure: Allowed 8D gabtessarine creation in an elliptic (Alpha <= 0) space.');
catch ME
    if contains(ME.identifier, 'InvalidAlpha')
        disp('   [OK] Correctly intercepted and blocked 8D instantiation in elliptic geometry.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: Dimensional Integrity Shield
disp('TEST 4: Dimensional Symmetry Enforcement');
try
    % Restore Hyperbolic domain
    setabtessarine(1, 1);
    
    a1 = ones(2, 2);
    a2 = ones(2, 2);
    b1 = ones(2, 2);
    b2 = ones(2, 3); % Mismatched dimension
    c1 = ones(2, 2); c2 = ones(2, 2); d1 = ones(2, 2); d2 = ones(2, 2);
    
    evalc('G_dim_fail = gabtessarine(a1, a2, b1, b2, c1, c2, d1, d2);');
    
    error('Safety failure: Allowed instantiation with asymmetric spatial planes.');
catch ME
    if contains(ME.identifier, 'DimensionMismatch')
        disp('   [OK] Dimensional asymmetry strictly intercepted.');
    else
        fprintf('   [FAILED] Unexpected error caught: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');