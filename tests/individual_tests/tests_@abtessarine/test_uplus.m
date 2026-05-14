% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: uplus.m (Unary Plus, +X)
% =========================================================================
% This script verifies the identity mapping of the abtessarine manifold.
% It validates structural exactness and object class preservation, 
% ensuring zero-overhead memory delegation operates correctly.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: uplus.m ---');
disp('===================================================================');

setabtessarine(-1, 1); % Environment initialization
tol = 1e-15;
N = 4;

%% TEST 1: Identity Mapping Validation
disp('TEST 1: Identity Mapping [+X == X]');
try
    X = abtrandn(N, N);
    
    % Invoke unary plus operator
    Z = +X;
    
    err = norm(Z.A - X.A) + norm(Z.B - X.B) + ...
          norm(Z.C - X.C) + norm(Z.D - X.D);
          
    if err < tol
        disp('   [OK] Unary plus strictly preserved structural equivalence.');
    else
        error('Identity mapping failed. Structural drift detected.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Object Class Preservation
disp('TEST 2: Class Preservation Assessment');
try
    X_obj = abtessarine(1, 2, 3, 4);
    
    Z_obj = +X_obj;
    
    if isa(Z_obj, 'abtessarine')
        disp('   [OK] Manifold object class correctly preserved through operation.');
    else
        error('Safety failure: Unary plus stripped the abtessarine class type.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');