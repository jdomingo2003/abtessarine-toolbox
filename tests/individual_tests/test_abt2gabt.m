% =========================================================================
% abtessarine_Toolbox - Test Script
% Application: Assembly from 4D to 8D via Cayley-Dickson Construction
% =========================================================================
% This script verifies the correct mapping and mathematical operator 
% overloading between the 4D (@abtessarine) and 8D (@gabtessarine) classes.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING 8D ASSEMBLY TEST ---');
disp('===================================================================');

% 1. Initialize the topological environment
% CRITICAL FIX: The 8D generalized algebra requires alpha > 0.
setabtessarine(2, 7); 

% 2. Create two 4D matrices (abtessarine) of size 3x3
disp('1. Generating 4D objects (X1 and X2)...');
X1 = abtrandn(3, 3);
X2 = abteye(3); % Hypercomplex identity matrix

% Display that X1 is of the correct class
fprintf('   -> Class of X1: %s\n', class(X1));

% 3. Use the function to assemble the 8D object
disp('2. Assembling into 8D using abt2gabt...');
X_8D = abt2gabt(X1, X2);

% Display that X_8D is of the new class
fprintf('   -> Class of X_8D: %s\n', class(X_8D));

% 4. Mathematical stress test in 8D
disp('3. Performing native mathematical operation in 8D (X_8D * X_8D)...');
try
    % If the gabtessarine class is correctly programmed, the overloaded
    % multiplication operator (*) will seamlessly execute in 8 dimensions.
    Result_8D = X_8D * X_8D;
    
    disp('   [SUCCESS] The 8D multiplication completed without errors.');
    
    % Print the size of one of the branches to confirm structural integrity
    sz = size(Result_8D.A1);
    fprintf('   -> Size of the resulting matrix: %d x %d\n', sz(1), sz(2));
    
catch ME
    disp('   [ERROR] A failure occurred during the 8D mathematical operation:');
    disp(ME.message);
end

disp('===================================================================');
disp('--- TEST COMPLETED ---');
disp('===================================================================');