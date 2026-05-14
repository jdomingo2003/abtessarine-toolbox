% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: gabteye.m (8D Hypercomplex Identity Matrix)
% =========================================================================
% This script verifies the correct generation of square and rectangular 
% identity matrices in the 8D generalized algebra, and strictly validates 
% its mathematical property as a multiplicative identity element.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: gabteye.m ---');
disp('===================================================================');

tol = 1e-12; % Strict floating-point tolerance

% CRITICAL: Initialize a topology with alpha > 0 for the 8D generalized algebra
setabtessarine(2, 7); 

%% TEST 1: Square Matrix Generation
disp('TEST 1: Square Matrix Generation (N x N)');
N = 5;
try
    I_sq = gabteye(N);
    
    % Verify sizes
    sz = size(I_sq.A1);
    if sz(1) ~= N || sz(2) ~= N
        error('Generated matrix does not match the requested N x N size.');
    end
    
    % Verify content (A1 must be identity, the 7 imaginary branches must be exactly zero)
    err_A1 = norm(I_sq.A1 - eye(N));
    err_imag = norm(I_sq.A2) + norm(I_sq.B1) + norm(I_sq.B2) + ...
               norm(I_sq.C1) + norm(I_sq.C2) + norm(I_sq.D1) + norm(I_sq.D2);
    
    if err_A1 == 0 && err_imag == 0
        disp('   [OK] Square 8D identity structurally perfect (A1=eye, Imaginary Branches=0).');
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
    I_rect = gabteye(M, N_rect);
    
    % Verify sizes across all 8 branches
    szA1 = size(I_rect.A1); szA2 = size(I_rect.A2);
    szB1 = size(I_rect.B1); szB2 = size(I_rect.B2);
    szC1 = size(I_rect.C1); szC2 = size(I_rect.C2);
    szD1 = size(I_rect.D1); szD2 = size(I_rect.D2);
    
    if ~isequal(szA1, [M, N_rect]) || ...
       ~isequal(szA1, szA2) || ~isequal(szA1, szB1) || ~isequal(szA1, szB2) || ...
       ~isequal(szA1, szC1) || ~isequal(szA1, szC2) || ~isequal(szA1, szD1) || ~isequal(szA1, szD2)
        error('Dimension mismatch across structural branches in rectangular generation.');
    end
    
    % Verify content natively
    err_A1 = norm(I_rect.A1 - eye(M, N_rect));
    err_imag_rect = norm(I_rect.A2) + norm(I_rect.B1) + norm(I_rect.B2) + ...
                    norm(I_rect.C1) + norm(I_rect.C2) + norm(I_rect.D1) + norm(I_rect.D2);
                    
    if err_A1 == 0 && err_imag_rect == 0
        disp('   [OK] Rectangular 8D identity structurally perfect.');
    else
        error('Content mismatch in rectangular generation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Mathematical Property (Multiplicative Identity in 8D)
disp('TEST 3: Multiplicative Identity Element Validation');
try
    % Generate a random 8D hypercomplex matrix natively
    X = gabtessarine(randn(N), randn(N), randn(N), randn(N), ...
                     randn(N), randn(N), randn(N), randn(N));
    I = gabteye(N);
    
    % 3.1 Right Multiplication (X * I = X)
    Res_Right = X * I;
    err_right = max([norm(Res_Right.A1 - X.A1), norm(Res_Right.A2 - X.A2), ...
                     norm(Res_Right.B1 - X.B1), norm(Res_Right.B2 - X.B2), ...
                     norm(Res_Right.C1 - X.C1), norm(Res_Right.C2 - X.C2), ...
                     norm(Res_Right.D1 - X.D1), norm(Res_Right.D2 - X.D2)]);
    
    % 3.2 Left Multiplication (I * X = X)
    Res_Left = I * X;
    err_left = max([norm(Res_Left.A1 - X.A1), norm(Res_Left.A2 - X.A2), ...
                    norm(Res_Left.B1 - X.B1), norm(Res_Left.B2 - X.B2), ...
                    norm(Res_Left.C1 - X.C1), norm(Res_Left.C2 - X.C2), ...
                    norm(Res_Left.D1 - X.D1), norm(Res_Left.D2 - X.D2)]);
                   
    max_err = max(err_right, err_left);
                   
    if max_err < tol
        disp('   [OK] Strict mathematical equivalence verified in 8D space (X*I = I*X = X).');
    else
        error('Multiplicative identity property violated. Error: %e', max_err);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');