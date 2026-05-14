% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: abteye.m (Hypercomplex Identity Matrix)
% =========================================================================
% This script verifies the correct generation of square and rectangular 
% identity matrices, and strictly validates its mathematical property 
% as a multiplicative identity element in the hypercomplex space.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abteye.m ---');
disp('===================================================================');

tol = 1e-12; % Strict floating-point tolerance
setabtessarine(-1, 1); % Standard tessarine topology

%% TEST 1: Square Matrix Generation
disp('TEST 1: Square Matrix Generation (N x N)');
N = 5;
try
    I_sq = abteye(N);
    
    % Verify sizes
    sz = size(I_sq.A);
    if sz(1) ~= N || sz(2) ~= N
        error('Generated matrix does not match the requested N x N size.');
    end
    
    % Verify content (A must be identity, B, C, D must be exactly zero)
    err_A = norm(I_sq.A - eye(N));
    err_B = norm(I_sq.B);
    err_C = norm(I_sq.C);
    err_D = norm(I_sq.D);
    
    if max([err_A, err_B, err_C, err_D]) == 0
        disp('   [OK] Square identity structurally perfect (A=eye, B=C=D=0).');
    else
        error('Content mismatch in square generation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Rectangular Matrix Generation
disp('TEST 2: Rectangular Matrix Generation (M x N)');
M = 4; N_rect = 6;
try
    I_rect = abteye(M, N_rect);
    
    % Verify sizes across all branches
    szA = size(I_rect.A); szB = size(I_rect.B);
    szC = size(I_rect.C); szD = size(I_rect.D);
    
    if ~isequal(szA, [M, N_rect]) || ~isequal(szA, szB) || ~isequal(szA, szC) || ~isequal(szA, szD)
        error('Dimension mismatch across structural branches in rectangular generation.');
    end
    
    % Verify content natively
    err_A = norm(I_rect.A - eye(M, N_rect));
    if err_A == 0 && norm(I_rect.B) == 0 && norm(I_rect.C) == 0 && norm(I_rect.D) == 0
        disp('   [OK] Rectangular identity structurally perfect.');
    else
        error('Content mismatch in rectangular generation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Mathematical Property (Multiplicative Identity)
disp('TEST 3: Multiplicative Identity Element Validation');
try
    % Generate a random hypercomplex matrix
    X = abtrandn(N, N);
    I = abteye(N);
    
    % 3.1 Right Multiplication (X * I = X)
    Res_Right = X * I;
    err_right_A = norm(Res_Right.A - X.A);
    err_right_B = norm(Res_Right.B - X.B);
    err_right_C = norm(Res_Right.C - X.C);
    err_right_D = norm(Res_Right.D - X.D);
    
    % 3.2 Left Multiplication (I * X = X)
    Res_Left = I * X;
    err_left_A = norm(Res_Left.A - X.A);
    err_left_B = norm(Res_Left.B - X.B);
    err_left_C = norm(Res_Left.C - X.C);
    err_left_D = norm(Res_Left.D - X.D);
    
    max_err = max([err_right_A, err_right_B, err_right_C, err_right_D, ...
                   err_left_A, err_left_B, err_left_C, err_left_D]);
                   
    if max_err < tol
        disp('   [OK] Strict mathematical equivalence verified (X*I = I*X = X).');
    else
        error('Multiplicative identity property violated. Error: %e', max_err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');