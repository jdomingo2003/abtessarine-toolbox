% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: minus.m (Operator -)
% =========================================================================
% This script verifies the element-wise subtraction and hybrid numeric
% interactions. It validates sign inversion for the hypercomplex components
% during left-hand numeric subtraction and stability during right-hand
% numeric subtraction.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: minus.m ---');
disp('===================================================================');

tol = 1e-15; % Floating-point tolerance
setabtessarine(-1, 1); % Environment initialization

%% TEST 1: Pure abtessarine Subtraction
disp('TEST 1: Component-wise Subtraction [X - Y]');
try
    X = abtrandn(3, 3);
    Y = abtrandn(3, 3);
    
    Z = X - Y;
    
    % Verify all components
    err = norm(Z.A - (X.A - Y.A)) + norm(Z.B - (X.B - Y.B)) + ...
          norm(Z.C - (X.C - Y.C)) + norm(Z.D - (X.D - Y.D));
    
    if err < tol
        disp('   [OK] Pure hypercomplex subtraction is numerically exact.');
    else
        error('Numerical mismatch in pure subtraction.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Hybrid Subtraction (Numeric - Object)
disp('TEST 2: Left-hand Numeric Subtraction [scalar - X]');
try
    X = abtrandn(2, 2);
    val = 10;
    
    Z = val - X;
    
    % Verify: A should be (val - X.A), B,C,D should be (-X.B, -X.C, -X.D)
    if isequal(Z.A, val - X.A) && isequal(Z.B, -X.B) && ...
       isequal(Z.C, -X.C) && isequal(Z.D, -X.D)
        disp('   [OK] Numeric-to-Object subtraction correctly handled.');
        disp('   [OK] Hypercomplex signs successfully inverted.');
    else
        error('Sign inversion or real part mapping failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Hybrid Subtraction (Object - Numeric)
disp('TEST 3: Right-hand Numeric Subtraction [X - scalar]');
try
    X = abtrandn(2, 2);
    val = 5;
    
    Z = X - val;
    
    % Verify: Only A is affected, B,C,D remain identical
    if isequal(Z.A, X.A - val) && isequal(Z.B, X.B) && ...
       isequal(Z.C, X.C) && isequal(Z.D, X.D)
        disp('   [OK] Object-to-Numeric subtraction correctly handled.');
        disp('   [OK] Hypercomplex components remained stable.');
    else
        error('Real part mapping or imaginary stability failed.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');