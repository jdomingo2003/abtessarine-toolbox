function Z_out = pinv(X, tol)
% PINV Moore-Penrose pseudoinverse of an abtessarine object.
%
%   Z = pinv(X) computes the Moore-Penrose pseudoinverse using an 
%   isomorphic HPC mapping based on the algebra's internal structure.
%
%   Z = pinv(X, TOL) uses the specified tolerance TOL to handle 
%   singular values during the inversion process.
%
%   METHODOLOGY:
%   This algorithm leverages the isometric *-isomorphism of the algebra 
%   to avoid computationally expensive manual SVD reconstruction. 
%   The object is projected into its respective LAPACK-compatible 
%   continuous branches, where pseudoinverses are computed natively 
%   in C/C++. The results are then recombined via inverse mapping, 
%   minimizing memory overhead and bypassing large-scale matrix operations.

%   See also INV, MLDIVIDE, MRDIVIDE, SVD.

    % --- 1. INPUT ARGUMENT PARSING ---
    use_tol = (nargin > 1);

    % --- 2. HPC ENVIRONMENT SENSING (Internal Retrieval) ---
    % Accessing the structural constants from the application data root
    alpha = getappdata(0, 'Tessarine_Alpha');
    beta  = getappdata(0, 'Tessarine_Beta');
    
    % Environment validation for algebraic consistency
    if isempty(alpha) || isempty(beta)
        error('abtessarine:pinv:MissingEnvironment', ...
            'Execution environment is undefined. Execute setabtessarine initialization.');
    end
    
    % Mathematical constraint: Alpha must be non-zero to maintain isomorphism
    if alpha == 0
        error('abtessarine:pinv:ZeroAlpha', ...
            'Structural constraint violation: Alpha cannot be exactly zero.');
    end

    % --- 3. FORWARD MAPPING: 4D to LAPACK Decomposition Branches ---
    g = sqrt(beta);
    gC = g * X.C;    gD = g * X.D;
    
    AS = X.A + gC;   AD = X.A - gC;
    BS = X.B + gD;   BD = X.B - gD;

    % --- 4. PARALLEL BRANCH SOLVER ---
    if alpha < 0
        % =========================================================
        % COMPLEX BRANCH (Alpha < 0)
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Delegation to optimized LAPACK-linked routine
        if use_tol
            inv_TS = pinv(TS, tol);
            inv_TD = pinv(TD, tol);
        else
            inv_TS = pinv(TS);
            inv_TD = pinv(TD);
        end
        
        % Inverse Mapping and Algebraic Recombination
        inv_g2 = 0.5 / g;
        
        R_A1 = real(inv_TS + inv_TD) * 0.5;
        R_B1 = imag(inv_TS + inv_TD) * (0.5 * inv_z);
        R_C1 = real(inv_TS - inv_TD) * inv_g2;
        R_D1 = imag(inv_TS - inv_TD) * (inv_g2 * inv_z);
        
        Z_out = abtessarine(R_A1, R_B1, R_C1, R_D1);
    else
        % =========================================================
        % REAL / SPLIT-COMPLEX BRANCH (Alpha > 0)
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        zBS = z * BS;     zBD = z * BD;
        M_SS = AS + zBS;  M_DS = AS - zBS;
        M_SD = AD + zBD;  M_DD = AD - zBD;
        
        % Delegation to optimized LAPACK-linked routine
        if use_tol
            inv_SS = pinv(M_SS, tol); inv_DS = pinv(M_DS, tol);
            inv_SD = pinv(M_SD, tol); inv_DD = pinv(M_DD, tol);
        else
            inv_SS = pinv(M_SS); inv_DS = pinv(M_DS);
            inv_SD = pinv(M_SD); inv_DD = pinv(M_DD);
        end
        
        % Inverse Mapping and Algebraic Recombination
        inv_g2 = 0.5 / g;
        
        C_S1 = (inv_SS + inv_DS) * 0.5;   C_S2 = (inv_SS - inv_DS) * inv_z2;
        C_D1 = (inv_SD + inv_DD) * 0.5;   C_D2 = (inv_SD - inv_DD) * inv_z2;
        
        R_A1 = (C_S1 + C_D1) * 0.5;
        R_B1 = (C_S2 + C_D2) * 0.5;
        R_C1 = (C_S1 - C_D1) * inv_g2;
        R_D1 = (C_S2 - C_D2) * inv_g2;
        
        Z_out = abtessarine(R_A1, R_B1, R_C1, R_D1);
    end
end