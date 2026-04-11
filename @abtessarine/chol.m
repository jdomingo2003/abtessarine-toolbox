function L = chol(X, varargin)
% CHOL Computes the Cholesky factorization for abtessarine objects.
%
%   R = chol(X) computes the upper triangular Cholesky factor R
%   such that X = R'*R (for alpha < 0) or X = R.'*R (for alpha > 0).
%
%   L = chol(X, 'lower') computes the lower triangular Cholesky factor L
%   such that X = L*L' (for alpha < 0) or X = L*L.' (for alpha > 0).
%
%   L = chol(X, ..., varargin) passes additional optional arguments 
%   directly to the native MATLAB/LAPACK chol function.
%
%   IMPLEMENTED ALGORITHMIC VALIDATIONS:
%   1) Square dimensionality verification.
%   2) Topological Hermitian symmetry constraint enforcement (1-Hermitian 
%      for alpha > 0, or 2-Hermitian for alpha < 0).
%   3) Positive definiteness validation across continuous isomorphic branches.

%   See also LU, QR, SVD, EIG. 

    % --- 1. GLOBAL PARAMETER RETRIEVAL ---
    % Retrieve operational parameters using the standard getabtessarine interface.
    [alpha, beta] = getabtessarine(); 
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:chol:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 2. SQUARE DIMENSIONALITY VALIDATION ---
    [n, m] = size(X.A);
    if n ~= m
        error('abtessarine:chol:NotSquare', ...
              'The input abtessarine matrix must be strictly square.');
    end
    
    % --- 3. HERMITIAN SYMMETRY VALIDATION ---
    tol = 1e-11; 
    
    if alpha > 0
        % 1-Hermitian symmetry constraint: A, B, C, and D must be symmetric matrices (M = M.')
        if norm(X.A - X.A.', 'inf') > tol || norm(X.B - X.B.', 'inf') > tol || ...
           norm(X.C - X.C.', 'inf') > tol || norm(X.D - X.D.', 'inf') > tol
            error('abtessarine:chol:NotHermitian', ...
                  'For alpha > 0, the input matrix must satisfy 1-Hermitian symmetry conditions (components A, B, C, and D must be strictly symmetric).');
        end
    else
        % 2-Hermitian symmetry constraint: A and C symmetric (M = M.'); B and D skew-symmetric (M = -M.')
        if norm(X.A - X.A.', 'inf') > tol || norm(X.B + X.B.', 'inf') > tol || ...
           norm(X.C - X.C.', 'inf') > tol || norm(X.D + X.D.', 'inf') > tol
            error('abtessarine:chol:NotHermitian', ...
                  'For alpha < 0, the input matrix must satisfy 2-Hermitian symmetry conditions (components A and C symmetric; B and D skew-symmetric).');
        end
    end
    
    % --- 4. FORWARD ISOMORPHIC MAPPING ---
    g = sqrt(beta);
    
    gC = g * X.C;    
    gD = g * X.D;
    
    AS = X.A + gC;   
    AD = X.A - gC;
    
    BS = X.B + gD;   
    BD = X.B - gD;
    inv_g2 = 0.5 / g;
    
    % --- 5. POSITIVE DEFINITENESS VALIDATION & CHOLESKY DECOMPOSITION ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Elliptic Geometry
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Execute native Cholesky decomposition and evaluate positive definiteness
        % varargin dynamically passes optional parameters (e.g., 'lower')
        [L_TS, p1] = chol(TS, varargin{:});
        [L_TD, p2] = chol(TD, varargin{:});
        
        if p1 > 0 || p2 > 0
            error('abtessarine:chol:NotPositiveDefinite', ...
                  'The matrix is not positive definite within its complex isomorphic branches.');
        end
        
        % --- 6. INVERSE ISOMORPHIC MAPPING ---
        L_A = real(L_TS + L_TD) * 0.5;
        L_B = imag(L_TS + L_TD) * (0.5 * inv_z);
        L_C = real(L_TS - L_TD) * inv_g2;
        L_D = imag(L_TS - L_TD) * (inv_g2 * inv_z);
        
        L = abtessarine(L_A, L_B, L_C, L_D);
        
    else
        % =========================================================
        % REAL / SPLIT-COMPLEX DOMAIN (Alpha > 0) - Hyperbolic Geometry
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        zBS = z * BS;     
        zBD = z * BD;
        
        E_s1 = AS + zBS;  
        E_s2 = AS - zBS;
        E_d1 = AD + zBD;  
        E_d2 = AD - zBD;
        
        % Execute native Cholesky decomposition and evaluate positive definiteness
        [L_s1, p1] = chol(E_s1, varargin{:});
        [L_s2, p2] = chol(E_s2, varargin{:});
        [L_d1, p3] = chol(E_d1, varargin{:});
        [L_d2, p4] = chol(E_d2, varargin{:});
        
        if p1 > 0 || p2 > 0 || p3 > 0 || p4 > 0
            error('abtessarine:chol:NotPositiveDefinite', ...
                  'The matrix is not positive definite within its real isomorphic branches.');
        end
        
        % --- 6. INVERSE ISOMORPHIC MAPPING ---
        Us_real = (L_s1 + L_s2) * 0.5;   Us_imag = (L_s1 - L_s2) * inv_z2;
        Ud_real = (L_d1 + L_d2) * 0.5;   Ud_imag = (L_d1 - L_d2) * inv_z2;
        
        L_A = (Us_real + Ud_real) * 0.5;
        L_B = (Us_imag + Ud_imag) * 0.5;
        L_C = (Us_real - Ud_real) * inv_g2;
        L_D = (Us_imag - Ud_imag) * inv_g2;
        
        L = abtessarine(L_A, L_B, L_C, L_D);
    end
end