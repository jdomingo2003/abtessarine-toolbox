function [Q, R] = qr(X, varargin)
% QR Orthogonal-triangular decomposition for abtessarine objects.
%
%   [Q, R] = qr(X) produces a full-size orthogonal/unitary hypercomplex 
%   matrix Q and an upper triangular hypercomplex matrix R such that X = Q*R.
%
%   [Q, R] = qr(X, 0) or qr(X, 'econ') produces the economy-size 
%   decomposition by delegating to the underlying LAPACK routines.
%
%   METHODOLOGY:
%   This algorithm leverages the isometric *-isomorphism of the algebra 
%   to project the 4D manifold into its continuous LAPACK-compatible 
%   branches. This ensures numerical stability and bypasses high-dimensional 
%   reconstruction errors. The final decomposition is synthesized via 
%   algebraic recombination based on the specific geometry (Elliptic/Hyperbolic).

%   See also LU, CHOL, SVD.

    % --- 1. HPC ENVIRONMENT SENSING ---
    % Retrieve structural constants using the centralized environment getter
    [alpha, beta] = getabtessarine();
    
    % Mathematical constraint: Alpha must be non-zero to maintain isomorphism
    if alpha == 0
        error('abtessarine:qr:ZeroAlpha', ...
            'Structural constraint violation: Alpha cannot be exactly zero.');
    end
    
    % --- 2. FORWARD MAPPING: 4D to LAPACK Branches ---
    g = sqrt(beta);
    
    gC = g * X.C;    
    gD = g * X.D;
    
    AS = X.A + gC;   
    AD = X.A - gC;
    
    BS = X.B + gD;   
    BD = X.B - gD;
    
    % Precompute inverse scaling for algebraic recombination
    inv_g2 = 0.5 / g;
    
    % --- 3. PARALLEL SOLVER CORE ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Elliptic Geometry
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        % Build isomorphic complex branches
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Native LAPACK delegation
        [QS_c, RS_c] = qr(TS, varargin{:});
        [QD_c, RD_c] = qr(TD, varargin{:});
        
        % --- ALGEBRAIC RECOMBINATION FOR Q ---
        Q_A1 = real(QS_c + QD_c) * 0.5;
        Q_B1 = imag(QS_c + QD_c) * (0.5 * inv_z);
        Q_C1 = real(QS_c - QD_c) * inv_g2;
        Q_D1 = imag(QS_c - QD_c) * (inv_g2 * inv_z);
        Q = abtessarine(Q_A1, Q_B1, Q_C1, Q_D1);
        
        % --- ALGEBRAIC RECOMBINATION FOR R ---
        R_A1 = real(RS_c + RD_c) * 0.5;
        R_B1 = imag(RS_c + RD_c) * (0.5 * inv_z);
        R_C1 = real(RS_c - RD_c) * inv_g2;
        R_D1 = imag(RS_c - RD_c) * (inv_g2 * inv_z);
        R = abtessarine(R_A1, R_B1, R_C1, R_D1);
    else
        % =========================================================
        % REAL / SPLIT-COMPLEX DOMAIN (Alpha > 0) - Hyperbolic Geometry
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        zBS = z * BS;     
        zBD = z * BD;
        
        % Unroll into four strictly real branches to preserve geometry
        E_s1 = AS + zBS;  
        E_s2 = AS - zBS;
        E_d1 = AD + zBD;  
        E_d2 = AD - zBD;
        
        % Native LAPACK delegation (Real QR)
        [Qs1, Rs1] = qr(E_s1, varargin{:});
        [Qs2, Rs2] = qr(E_s2, varargin{:});
        [Qd1, Rd1] = qr(E_d1, varargin{:});
        [Qd2, Rd2] = qr(E_d2, varargin{:});
        
        % --- ALGEBRAIC RECOMBINATION FOR Q ---
        Qs_real = (Qs1 + Qs2) * 0.5;   Qs_imag = (Qs1 - Qs2) * inv_z2;
        Qd_real = (Qd1 + Qd2) * 0.5;   Qd_imag = (Qd1 - Qd2) * inv_z2;
        
        Q_A = (Qs_real + Qd_real) * 0.5;
        Q_B = (Qs_imag + Qd_imag) * 0.5;
        Q_C = (Qs_real - Qd_real) * inv_g2;
        Q_D = (Qs_imag - Qd_imag) * inv_g2;
        Q = abtessarine(Q_A, Q_B, Q_C, Q_D);
        
        % --- ALGEBRAIC RECOMBINATION FOR R ---
        Rs_real = (Rs1 + Rs2) * 0.5;   Rs_imag = (Rs1 - Rs2) * inv_z2;
        Rd_real = (Rd1 + Rd2) * 0.5;   Rd_imag = (Rd1 - Rd2) * inv_z2;
        
        R_A = (Rs_real + Rd_real) * 0.5;
        R_B = (Rs_imag + Rd_imag) * 0.5;
        R_C = (Rs_real - Rd_real) * inv_g2;
        R_D = (Rs_imag - Rd_imag) * inv_g2;
        R = abtessarine(R_A, R_B, R_C, R_D);
    end
end