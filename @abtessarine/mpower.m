function Z_out = mpower(X, p)
% MPOWER Overloads the matrix power operator (^) for abtessarine arrays.
%
%   Z = X ^ p computes the matrix power of the square 4D array X.
%
%   MATHEMATICAL FORMULATION & ALGORITHMIC OPTIMIZATIONS:
%   Leverages a highly optimized Dual-Path architecture designed for HPC:
%
%   1. Integer Fast-Path: O(log p) matrix exponentiation via the native 
%      matrix multiplication engine (mtimes, *). Safely avoids spectral 
%      decompositions for integer powers and is unconditionally stable 
%      across all topological parameters.
%   2. Fractional/Spectral Path: Structurally maps the 4D hypercomplex 
%      tensor into four independent 2D complex planes via idempotent 
%      decomposition. This allows delegating the computation of matrix 
%      fractional powers directly to MATLAB's highly optimized, LAPACK-
%      backed Schur decomposition engine (^).
%
%   See also: POWER, MTIMES, SQRTM, INV.

    % --- 0. GUARDRAILS & DIMENSIONAL CHECKS ---
    if ~isa(X, 'abtessarine') || ~isscalar(p) || ~isnumeric(p)
        error('abtessarine:mpower:InvalidInputs', ...
              'Matrix power requires an abtessarine object base and a scalar numeric exponent.');
    end
    
    [rows, cols] = size(X.A);
    if rows ~= cols
        error('abtessarine:mpower:NonSquareMatrix', ...
              'Matrix must be square to compute matrix power.');
    end

    % --- 1. INTEGER FAST-PATH (O(log p) Exponentiation by Squaring) ---
    if p == round(p) && p >= 0
        % Matrix multiplicative identity (Identity matrix in A, zeros in B,C,D)
        I_A = eye(rows, 'like', X.A);
        O_A = zeros(rows, 'like', X.A);
        
        if p == 0
            Z_out = abtessarine(I_A, O_A, O_A, O_A);
            return;
        end
        
        Z_out = abtessarine(I_A, O_A, O_A, O_A);
        base = X;
        curr_p = p;
        
        while curr_p > 0
            if mod(curr_p, 2) == 1
                Z_out = Z_out * base; % Delegates to MTIMES (*)
            end
            curr_p = floor(curr_p / 2);
            if curr_p > 0
                base = base * base;
            end
        end
        return;
    end

    % --- 2. HPC ENVIRONMENT SENSOR (Fractional/Negative Path) ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:mpower:MissingEnvironment', ...
              'Undefined algebraic topology. Execute setabtessarine before operating.');
    end
    
    if alpha <= 0 || beta <= 0
        error('abtessarine:mpower:InvalidTopology', ...
              'Fractional or negative matrix powers via idempotent decomposition are strictly defined for alpha > 0 and beta > 0.');
    end

    % --- 3. CONSTANTS AND PRECOMPUTATION ---
    g = sqrt(beta);
    z = sqrt(alpha);
    
    gC = g * X.C;
    gD = g * X.D;
    
    A_p = X.A + gC;  A_m = X.A - gC;
    B_p = z * (X.B + gD);  B_m = z * (X.B - gD);

    % --- 4. NATIVE LAPACK INJECTIONS (^) ---
    % Route 1: Matrix Power of the Positive g-block
    M_CSP = (A_p + B_p) ^ p;
    M_CSM = (A_p - B_p) ^ p;
    
    RootS_1 = (M_CSP + M_CSM) / 2;
    RootS_3 = (M_CSP - RootS_1) / z;

    % Route 2: Matrix Power of the Negative g-block
    M_CDP = (A_m + B_m) ^ p;
    M_CDM = (A_m - B_m) ^ p;
    
    RootD_1 = (M_CDP + M_CDM) / 2;
    RootD_3 = (M_CDP - RootD_1) / z;

    % --- 5. FINAL 4D ASSEMBLY ---
    R_A = (RootS_1 + RootD_1) / 2;
    R_B = (RootS_3 + RootD_3) / 2;
    
    Z_out = abtessarine(R_A, R_B, ...
                       (RootS_1 - R_A) / g, ...
                       (RootS_3 - R_B) / g);
end