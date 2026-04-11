function Z_inv = inv(X)
% INV Computes the inverse matrix of a gabtessarine object (8D).
%
%   Z_inv = INV(X) applies a double-layered isomorphic bifurcation algorithm.
%   The 8D inversion is mathematically decoupled into four independent 
%   standard complex matrix inversions. This approach leverages native 
%   LAPACK-optimized routines and ensures numerical stability.
%
%   MATHEMATICAL STRATEGY:
%   1. Project the 8D manifold into two 4D sub-algebras based on sqrt(beta).
%   2. Further decouple each 4D block into complex pairs based on sqrt(alpha).
%   3. Invert in the complex domain and apply an inverse mapping to 
%      reconstruct the 8D result.

%   See also MTIMES, SQRTM.

%     % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('gabtessarine:inv:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    end
    
    % The 8D generalized algebra (gabtessarine) is specifically 
    % designed for the hyperbolic case where alpha > 0.
    if alpha <= 0
        error('gabtessarine:inv:InvalidAlpha', ...
              'Inversion in 8D is mathematically defined only for alpha > 0.');
    end

    % --- 2. CONSTANTS AND PRECOMPUTATION ---
    g = sqrt(beta);
    z = sqrt(alpha);
    
    % Local extraction to minimize property access overhead
    A1 = X.A1; A2 = X.A2; B1 = X.B1; B2 = X.B2;
    C1 = X.C1; C2 = X.C2; D1 = X.D1; D2 = X.D2;

    % --- 3. FIRST BIFURCATION (Sub-algebra projection) ---
    gC1 = g * C1; gC2 = g * C2;
    gD1 = g * D1; gD2 = g * D2;
    
    A1_p = A1 + gC1;  A1_m = A1 - gC1;
    A2_p = A2 + gC2;  A2_m = A2 - gC2;
    B1_p = z * (B1 + gD1);  B1_m = z * (B1 - gD1);
    B2_p = z * (B2 + gD2);  B2_m = z * (B2 - gD2);

    % --- 4. SECOND BIFURCATION & LAPACK INVERSION ---
    % Route 1: Inversion of the 'plus' (S) block
    Inv_S_P = inv((A1_p + B1_p) + (A2_p + B2_p) * 1i);
    Inv_S_M = inv((A1_p - B1_p) + (A2_p - B2_p) * 1i);
    
    ES1 = real(Inv_S_P); ES2 = imag(Inv_S_P);
    FS1 = real(Inv_S_M); FS2 = imag(Inv_S_M);
    
    % Recombine 'plus' block inverses
    InvS_1 = (ES1 + FS1) * 0.5;
    InvS_2 = (ES2 + FS2) * 0.5;
    InvS_3 = (ES1 - InvS_1) / z; 
    InvS_4 = (ES2 - InvS_2) / z;

    % Route 2: Inversion of the 'minus' (D) block
    Inv_D_P = inv((A1_m + B1_m) + (A2_m + B2_m) * 1i);
    Inv_D_M = inv((A1_m - B1_m) + (A2_m - B2_m) * 1i);
    
    ED1 = real(Inv_D_P); ED2 = imag(Inv_D_P);
    FD1 = real(Inv_D_M); FD2 = imag(Inv_D_M);
    
    % Recombine 'minus' block inverses
    InvD_1 = (ED1 + FD1) * 0.5;
    InvD_2 = (ED2 + FD2) * 0.5;
    InvD_3 = (ED1 - InvD_1) / z;
    InvD_4 = (ED2 - InvD_2) / z;

    % --- 5. FINAL 8D RECONSTRUCTION (Inverse Mapping) ---
    % Component-wise assembly using algebraic recycling to minimize flops
    R_A1 = (InvS_1 + InvD_1) * 0.5;
    R_A2 = (InvS_2 + InvD_2) * 0.5;
    R_B1 = (InvS_3 + InvD_3) * 0.5;
    R_B2 = (InvS_4 + InvD_4) * 0.5;
    
    % Scaling by beta (g) constant
    R_C1 = (InvS_1 - R_A1) / g;
    R_C2 = (InvS_2 - R_A2) / g;
    R_D1 = (InvS_3 - R_B1) / g;
    R_D2 = (InvS_4 - R_B2) / g;

    % Object synthesis
    Z_inv = gabtessarine(R_A1, R_A2, R_B1, R_B2, R_C1, R_C2, R_D1, R_D2);
end