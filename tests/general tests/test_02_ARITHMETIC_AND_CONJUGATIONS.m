% TEST_02_ARITHMETIC_AND_CONJUGATIONS
% Validation script for the @abtessarine toolbox (Part 2/3)
% Focus: Basic arithmetic, element-wise math, and specific conjugations.

clear classes; clc;

% Initialize the algebraic environment before any operations
setabtessarine(-1, 1);

fprintf('=======================================================\n');
fprintf('   PART 2: ARITHMETIC AND CONJUGATIONS\n');
fprintf('=======================================================\n\n');

A = magic(3); 
X = abtessarine(A, A*2, A*3, A*4);
Y = abtessarine(eye(3), zeros(3), zeros(3), eye(3));

fprintf('--- 1. Unary Operations ---\n');
Z1 = +X; % uplus
Z2 = -X; % uminus
disp('[OK] "uplus" (+) and "uminus" (-) executed.');

fprintf('\n--- 2. Binary Operations ---\n');
Z3 = X + Y; % plus
disp('[OK] "plus" (+) executed.');
Z4 = X - Y; % minus
disp('[OK] "minus" (-) executed.');
Z5 = X .* Y; % times
disp('[OK] "times" (.*) executed.');
Z6 = X * Y; % mtimes
disp('[OK] "mtimes" (*) executed.');
Z7 = kron(X, Y); % kron
disp('[OK] Kronecker tensor product "kron" executed.');

fprintf('\n--- 3. Powers ---\n');
Z8 = X .^ 2; % power
disp('[OK] Element-wise "power" (.^) executed.');
Z9 = X ^ 2; % mpower
disp('[OK] Matrix "mpower" (^) executed.');

fprintf('\n--- 4. Array Reductions ---\n');
S = sum(X);
disp('[OK] "sum" executed.');
P = prod(X);
disp('[OK] "prod" executed.');
D = diff(X);
disp('[OK] "diff" executed.');

fprintf('\n--- 5. Conjugations & Transpositions ---\n');
C_i = conj_i(X);
disp('[OK] "conj_i" executed.');
C_J = conj_j(X);
disp('[OK] "conj_J" executed.');
C_k = conj_k(X);
disp('[OK] "conj_k" executed.');

X_t = X.'; % transpose
disp('[OK] "transpose" (.'') executed.');
X_ct = X'; % ctranspose
disp('[OK] "ctranspose" ('') executed.');
X_h = hermitian(X,-4,1); % hermitian
disp('[OK] "hermitian" executed.');

fprintf('\n--- END OF PART 2 ---\n');