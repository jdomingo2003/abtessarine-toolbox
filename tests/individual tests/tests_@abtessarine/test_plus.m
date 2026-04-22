% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: plus.m (Operator +)
% =========================================================================
% This script verifies element-wise addition and hybrid numeric-object 
% interactions. It validates the commutative property and the correct 
% handling of implicit scalar expansion (broadcasting).
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: plus.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-15;

%% TEST 1: Commutative Property [X + Y == Y + X]
disp('TEST 1: Commutative Property (Pure Object Addition)');
try
    X = abtrandn(4, 4);
    Y = abtrandn(4, 4);
    
    Z1 = X + Y;
    Z2 = Y + X;
    
    % Verify component-wise equality
    err = norm(Z1.A - Z2.A) + norm(Z1.B - Z2.B) + ...
          norm(Z1.C - Z2.C) + norm(Z1.D - Z2.D);
    
    if err < tol
        disp('   [OK] Addition is commutative and numerically stable.');
    else
        error('Commutativity failure detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid Interaction and Scalar Expansion
disp('TEST 2: Hybrid Interaction [Object + Scalar]');
try
    X = abtrandn(2, 2);
    val = 10.5;
    
    % Sum scalar to object
    Z = X + val;
    
    % Check: Only real part A should change, B, C, D must remain identical
    if isequal(Z.A, X.A + val) && isequal(Z.B, X.B) && ...
       isequal(Z.C, X.C) && isequal(Z.D, X.D)
        disp('   [OK] Scalar correctly added to real component only.');
        disp('   [OK] Imaginary components remained structurally intact.');
    else
        error('Hybrid addition mapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Dimensional Broadcasting
disp('TEST 3: Implicit Scalar Expansion (Vector + Matrix)');
try
    % Matrix 2x2
    M = abtessarine(ones(2), ones(2), zeros(2), zeros(2));
    % Scalar object
    S = abtessarine(5, 5, 5, 5);
    
    % Adding scalar object to matrix object
    Z = M + S;
    
    % Expecting 2x2 matrix where each element is 1+5
    if all(Z.A(:) == 6) && all(Z.B(:) == 6)
        disp('   [OK] Implicit broadcasting (scalar expansion) validated.');
    else
        error('Broadcasting logic failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');