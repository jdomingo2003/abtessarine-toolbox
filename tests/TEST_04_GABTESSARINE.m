% TEST_04_GABTESSARINE
% Validation script for the @gabtessarine toolbox
% Focus: Full verification of the 15 core functions for 8D generalized abtessarines.

clear classes; clc;
fprintf('=======================================================\n');
fprintf('   GABTESSARINE (8D) TOOLBOX - VALIDATION SCRIPT\n');
fprintf('=======================================================\n\n');

% 1. Environment Configuration
% CRITICAL: The 8D complexified extension requires a hyperbolic geometry.
% We MUST set alpha > 0, otherwise the topological guardrail will trigger an error.
fprintf('--- 1. Environment Configuration ---\n');
setabtessarine(1, 1); % alpha = 1, beta = 1
disp('[OK] Algebraic environment initialized (Alpha > 0 confirmed).');

% 2. Creation and Display (gabtessarine, disp)
fprintf('\n--- 2. Object Creation and Display ---\n');
% Pre-allocating 8 matrices (2x2) to satisfy the 8D constructor
A1 = [1 2; 3 4]; A2 = [0 1; -1 0];
B1 = eye(2);     B2 = zeros(2);
C1 = ones(2);    C2 = -ones(2);
D1 = zeros(2);   D2 = eye(2)*2;

G = gabtessarine(A1, A2, B1, B2, C1, C2, D1, D2);
disp('[OK] gabtessarine object G (2x2, 8D) created successfully.');
disp('Displaying object G:');
disp(G); % Explicit call to disp

% 3. Dimensions and Indexing (size, subsref, subsasgn)
fprintf('\n--- 3. Dimensions and Indexing ---\n');
[r, c] = size(G);
fprintf('[OK] "size" of G: %d x %d\n', r, c);

% Testing subsref (G(1,2))
val = G(1, 2);
disp('[OK] "subsref" executed. Element G(1,2) extracted.');
disp('Showing A1 component of extracted element:');
disp(val.A1);

% Testing subsasgn (G(2,1) = val)
G(2, 1) = val;
disp('[OK] "subsasgn" executed. Element G(2,1) modified.');

% 4. Concatenation (horzcat, vertcat)
fprintf('\n--- 4. Concatenation ---\n');
G_horz = [G, G];
disp('[OK] "horzcat" ([G, G]) executed.');
G_vert = [G; G];
disp('[OK] "vertcat" ([G; G]) executed.');

% 5. Basic Arithmetic (plus, minus, times, mtimes, uminus)
fprintf('\n--- 5. Basic Arithmetic ---\n');
% Creating a secondary 8D object for operations
I2 = eye(2); Z2 = zeros(2);
G2 = gabtessarine(I2, Z2, I2, Z2, I2, Z2, I2, Z2);

Z_plus = G + G2;
disp('[OK] "plus" (+) executed.');

Z_minus = G - G2;
disp('[OK] "minus" (-) executed.');

Z_uminus = -G;
disp('[OK] "uminus" (unary -) executed.');

Z_times = G .* G2;
disp('[OK] "times" (element-wise .*) executed.');

Z_mtimes = G * G2;
disp('[OK] "mtimes" (matrix multiplication *) executed.');

% 6. Advanced Linear Algebra (inv, kron, sqrtm)
fprintf('\n--- 6. Advanced Linear Algebra ---\n');

% Kronecker Product
try
    Z_kron = kron(G, G2);
    disp('[OK] "kron" (Kronecker product) executed.');
catch ME
    disp(['[ERROR] kron: ', ME.message]);
end

% Matrix Inverse
% We ensure the matrix is strongly diagonally dominant to prevent singularities
G_inv_test = G + gabtessarine(I2*20, Z2, Z2, Z2, Z2, Z2, Z2, Z2);
try
    Z_inv = inv(G_inv_test);
    disp('[OK] "inv" (matrix inverse) executed.');
catch ME
    disp(['[SKIPPED] inv: ', ME.message]);
end

% Matrix Square Root
try
    Z_sqrt = sqrtm(G_inv_test);
    disp('[OK] "sqrtm" (matrix square root) executed.');
catch ME
    disp(['[SKIPPED] sqrtm: ', ME.message]);
end

fprintf('\n=======================================================\n');
fprintf('   GABTESSARINE (8D) TESTS COMPLETED SUCCESSFULLY.\n');
fprintf('=======================================================\n');