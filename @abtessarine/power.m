function Z_out = power(X, p)
% POWER Overloads the element-wise power operator (.^) for abtessarine.
%
%   Z = X .^ p computes the element-wise power of the 4D array X.
%
%   MATHEMATICAL FORMULATION & ALGORITHMIC OPTIMIZATIONS:
%   Leverages a SIMD-optimized Dual-Path computational architecture:
%
%   1. Integer Fast-Path: O(log p) exponentiation via the element-wise 
%      multiplication engine (times, .*). Safe for any topological beta.
%   2. Fractional/Negative/Array Path: Structurally reduces the 4D tensor 
%      into four concurrent 1D arrays processed natively by MATLAB's 
%      VMath/SIMD engine (.^).
%
%   See also: MPOWER, TIMES, ABTONES, SQRTM.

    % --- 0. DIMENSIONAL GUARDRAILS ---
    if ~isa(X, 'abtessarine') || ~isnumeric(p)
        error('abtessarine:power:InvalidInputs', ...
              'Element-wise power requires an abtessarine object base and a numeric exponent.');
    end

    % --- 1. INTEGER FAST-PATH (O(log p) Element-wise Exponentiation) ---
    if isscalar(p) && p == round(p) && p >= 0
        if p == 0
            Z_out = abtones(size(X.A), 'like', X.A);
            return;
        end
        
        Z_out = abtones(size(X.A), 'like', X.A);
        base = X;
        curr_p = p;
        
        while curr_p > 0
            if mod(curr_p, 2) == 1
                Z_out = Z_out .* base; % Delegates to TIMES (.*)
            end
            curr_p = floor(curr_p / 2);
            if curr_p > 0
                base = base .* base;
            end
        end
        return;
    end

    % --- 2. HPC ENVIRONMENT SENSOR (Fractional/Negative/Array Path) ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:power:MissingEnvironment', ...
              'Undefined algebraic topology. Execute setabtessarine before operating.');
    end
    
    if alpha <= 0 || beta <= 0
        error('abtessarine:power:InvalidTopology', ...
              'Fractional or negative element-wise powers via idempotent decomposition are strictly defined for alpha > 0 and beta > 0.');
    end

    % --- 3. CONSTANTS AND PRECOMPUTATION ---
    g = sqrt(beta);
    z = sqrt(alpha);
    
    gC = g * X.C;
    gD = g * X.D;
    
    A_p = X.A + gC;  A_m = X.A - gC;
    B_p = z * (X.B + gD);  B_m = z * (X.B - gD);

    % --- 4. NATIVE SIMD INJECTIONS (.^) ---
    
    % Route 1: Element-wise Power of the Positive g-block
    M_CSP = (A_p + B_p) .^ p;
    M_CSM = (A_p - B_p) .^ p;
    
    RootS_1 = (M_CSP + M_CSM) / 2;
    RootS_3 = (M_CSP - RootS_1) / z;

    % Route 2: Element-wise Power of the Negative g-block
    M_CDP = (A_m + B_m) .^ p;
    M_CDM = (A_m - B_m) .^ p;
    
    RootD_1 = (M_CDP + M_CDM) / 2;
    RootD_3 = (M_CDP - RootD_1) / z;

    % --- 5. FINAL 4D ASSEMBLY ---
    R_A = (RootS_1 + RootD_1) / 2;
    R_B = (RootS_3 + RootD_3) / 2;
    
    Z_out = abtessarine(R_A, R_B, ...
                       (RootS_1 - R_A) / g, ...
                       (RootS_3 - R_B) / g);
end