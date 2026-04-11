function [L_out, U_out, P_out] = lu(X)
% LU LU factorization with partial pivoting for abtessarine matrices.
%
%   [L, U, P] = lu(X) computes the generalized LU decomposition such that
%   P*X = L*U, where P is the permutation matrix, L is lower triangular, 
%   and U is upper triangular in the abtessarine domain.
%
%   ALGORITHMIC METHODOLOGY:
%   The algorithm utilizes a cascaded idempotent projection technique to 
%   maximize computational throughput. By leveraging the algebra's 
%   isomorphism, the 4D matrix is decoupled into independent native 
%   branches:
%
%     1. First Reduction (Beta/G Mapping): Decouples the 4D matrix into 
%        two 2D blocks using the beta environment parameter.
%     2. Second Reduction (Alpha/Z Mapping): Branches the 2D blocks into 
%        either Complex space (alpha < 0) or Real/Split-Complex space 
%        (alpha > 0).
%     3. Native Solver: Executes optimized LAPACK LU routines on the 
%        resulting native matrices and reconstructs the hypercomplex 
%        components via the inverse isomorphic mapping.
%
%   STRUCTURAL NOTE: 
%   Due to the existence of zero divisors in certain abtessarine domains, 
%   the permutation matrix 'P' may contain hypercomplex components if the 
%   pivoting paths differ across the idempotent branches.

%   See also CHOL, QR, SVD, INV.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:lu:MissingEnvironment', ...
              'Global algebraic environment is uninitialized. Execute setabtessarine.');
    end

    % --- 2. FIRST REDUCTION: 4D to 2D (Beta/G Branching) ---
    g = sqrt(beta);
    
    % Memory-efficient precomputation of branch intermediaries
    gC = g * X.C;
    gD = g * X.D;
    
    AS = X.A + gC;    AD = X.A - gC;
    BS = X.B + gD;    BD = X.B - gD;

    % --- 3. SECOND REDUCTION & LAPACK SOLVER (Alpha/Z Branching) ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Native Complex Engine
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        % Mapping to native Complex Double format
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Invoke optimized native LU (O(N^3) complexity)
        [LS_c, US_c, PS_c] = lu(TS);
        [LD_c, UD_c, PD_c] = lu(TD);
        
        % Isomorphic Component Extraction
        LS1 = real(LS_c);  LS2 = imag(LS_c) * inv_z;
        US1 = real(US_c);  US2 = imag(US_c) * inv_z;
        PS1 = PS_c;        PS2 = zeros(size(PS1)); % Native P is identity-real
        
        LD1 = real(LD_c);  LD2 = imag(LD_c) * inv_z;
        UD1 = real(UD_c);  UD2 = imag(UD_c) * inv_z;
        PD1 = PD_c;        PD2 = zeros(size(PD1));
        
    else
        % =========================================================
        % REAL / SPLIT-COMPLEX DOMAIN (Alpha > 0) - Real Engine
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        % Fully decoupled idempotent split
        zBS = z * BS;     zBD = z * BD;
        
        SS = AS + zBS;    DS = AS - zBS;
        SD = AD + zBD;    DD = AD - zBD;
        
        % Native optimized LU factorization on real branches
        [L_SS, U_SS, P_SS] = lu(SS);
        [L_DS, U_DS, P_DS] = lu(DS);
        [L_SD, U_SD, P_SD] = lu(SD);
        [L_DD, U_DD, P_DD] = lu(DD);
        
        % Reconstruct 2D component intermediaries
        LS1 = (L_SS + L_DS) * 0.5;  LS2 = (L_SS - L_DS) * inv_z2;
        US1 = (U_SS + U_DS) * 0.5;  US2 = (U_SS - U_DS) * inv_z2;
        PS1 = (P_SS + P_DS) * 0.5;  PS2 = (P_SS - P_DS) * inv_z2;
        
        LD1 = (L_SD + L_DD) * 0.5;  LD2 = (L_SD - L_DD) * inv_z2;
        UD1 = (U_SD + U_DD) * 0.5;  UD2 = (U_SD - U_DD) * inv_z2;
        PD1 = (P_SD + P_DD) * 0.5;  PD2 = (P_SD - P_DD) * inv_z2;
    end

    % --- 4. FINAL RECONSTRUCTION: 2D to 4D Mapping ---
    inv_g2 = 0.5 / g;
    
    % Reconstruct hypercomplex resultants via direct instantiation
    L_out = abtessarine((LS1 + LD1) * 0.5, ...
                        (LS2 + LD2) * 0.5, ...
                        (LS1 - LD1) * inv_g2, ...
                        (LS2 - LD2) * inv_g2);
                    
    U_out = abtessarine((US1 + UD1) * 0.5, ...
                        (US2 + UD2) * 0.5, ...
                        (US1 - UD1) * inv_g2, ...
                        (US2 - UD2) * inv_g2);
                    
    P_out = abtessarine((PS1 + PD1) * 0.5, ...
                        (PS2 + PD2) * 0.5, ...
                        (PS1 - PD1) * inv_g2, ...
                        (PS2 - PD2) * inv_g2);
end