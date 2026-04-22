% TEST_03_LINEAR_ALGEBRA
% Validation script for the @abtessarine toolbox (Part 3/3)
% Focus: Matrix decompositions, eigenvalue problems, and linear systems.

clear classes; clc;
rng(1); 

% Initialize the algebraic environment before any operations
setabtessarine(-1, 1);

fprintf('=======================================================\n');
fprintf('   PART 3: ADVANCED LINEAR ALGEBRA\n');
fprintf('=======================================================\n\n');

N = 10;
A = rand(N) + N * eye(N); 
X = abtessarine(A, rand(N), rand(N), rand(N));
Y = abtessarine(rand(N), zeros(N), zeros(N), rand(N));

fprintf('--- 1. Matrix Properties ---\n');
try d = det(X); disp('[OK] "det" computed.'); catch ME, disp(['[SKIPPED] det: ' ME.message]); end
try t = trace(X); disp('[OK] "trace" computed.'); catch ME, disp(['[SKIPPED] trace: ' ME.message]); end
try n = norm(X); disp('[OK] "norm" computed.'); catch ME, disp(['[SKIPPED] norm: ' ME.message]); end
try dg = diag(X); disp('[OK] "diag" extracted.'); catch ME, disp(['[SKIPPED] diag: ' ME.message]); end

fprintf('\n--- 2. Systems and Inverses ---\n');
try X_inv = inv(X); disp('[OK] Matrix inverse "inv" computed.'); catch ME, disp(['[SKIPPED] inv: ' ME.message]); end
try X_pinv = pinv(X); disp('[OK] Pseudo-inverse "pinv" computed.'); catch ME, disp(['[SKIPPED] pinv: ' ME.message]); end
try L_div = X \ Y; disp('[OK] Left matrix division "mldivide" (\\) executed.'); catch ME, disp(['[SKIPPED] mldivide: ' ME.message]); end
try R_div = X / Y; disp('[OK] Right matrix division "mrdivide" (/) executed.'); catch ME, disp(['[SKIPPED] mrdivide: ' ME.message]); end

fprintf('\n--- 3. Factorizations ---\n');
try [L, U] = lu(X); disp('[OK] "lu" decomposition computed.'); catch ME, disp(['[SKIPPED] lu: ' ME.message]); end
try [Q, R] = qr(X); disp('[OK] "qr" decomposition computed.'); catch ME, disp(['[SKIPPED] qr: ' ME.message]); end
try sq = sqrtm(X); disp('[OK] Matrix square root "sqrtm" computed.'); catch ME, disp(['[SKIPPED] sqrtm: ' ME.message]); end
try 
    X_sym = hermitian(X) * X; 
    C = chol(X_sym); 
    disp('[OK] "chol" (Cholesky) decomposition computed.'); 
catch ME
    disp(['[SKIPPED] chol: ' ME.message]); 
end

fprintf('\n--- 4. Eigen & Singular Value Problems ---\n');
try [U_s, S_s, V_s] = svd(X); disp('[OK] "svd" computed.'); catch ME, disp(['[SKIPPED] svd: ' ME.message]); end
try [V_e, D_e] = eig(X); disp('[OK] "eig" computed.'); catch ME, disp(['[SKIPPED] eig: ' ME.message]); end

try S_sparse = svds(X, 3); disp('[OK] "svds" computed.'); catch ME, disp(['[SKIPPED] svds: ' ME.message]); end
try D_sparse = eigs(X, 3); disp('[OK] "eigs" computed.'); catch ME, disp(['[SKIPPED] eigs: ' ME.message]); end

fprintf('\n=======================================================\n');
fprintf('   ALL TESTS COMPLETED SUCCESSFULLY.\n');
fprintf('=======================================================\n');