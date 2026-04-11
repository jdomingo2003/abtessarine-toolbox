function [U, S, V] = svds(X, s)
% SVDS Find a few singular values and vectors for abtessarine objects.
%
%   S = SVDS(X) returns a vector containing the 6 largest singular values.
%   [U, S, V] = SVDS(X, K) computes the K largest singular values and 
%   their corresponding left and right singular vectors.
%
%   OPTIMIZED HYBRID SOLVER:
%   The function uses a dynamic heuristic router to maximize CPU efficiency:
%     - Sparse Route: If K is small (<= 3% of dimensions), it uses Krylov 
%       subspace methods (native SVDS).
%     - Dense Route: If K is large, it switches to a truncated dense SVD 
%       ('econ') to avoid the overhead of sparse orthogonalization.
%
%   METHODOLOGY:
%   The 4D system is projected into its spectral branches (elliptic or 
%   hyperbolic), solved in parallel via native MATLAB engines, and 
%   reconstructed through an inverse isomorphic mapping.

%   See also SVD, EIGS.

    % --- 1. SENSOR & INPUT PARSING ---
    [m, n] = size(X.A);
    k_max = min(m, n);
    
    if nargin < 2
        s = min(6, k_max); 
    end
    
    % Fallback to full SVD if the number of requested values is too high
    if s >= k_max
        if nargout <= 1
            U = svd(X); 
        else
            [U, S, V] = svd(X);
        end
        return;
    end

    % --- 2. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:svds:MissingEnvironment', 'Undefined environment. Run setabtessarine.');
    end

    % --- 3. FORWARD MAPPING: 4D to Spectral Branches ---
    g = sqrt(beta);
    gC = g * X.C;    gD = g * X.D;
    
    AS = X.A + gC;   AD = X.A - gC;
    BS = X.B + gD;   BD = X.B - gD;
    
    % --- 4. DYNAMIC ROUTER (HPC Heuristic) ---
    % Performance of sparse solvers drops if s > 3% of the total rank
    use_dense_solver = (s > 0.03 * k_max);

    % --- 5. PARALLEL SOLVER BIFURCATION ---
    if alpha < 0
        % =========================================================
        % ELLIPTIC BRANCH (Complex Domain)
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        inv_g2 = 0.5 / g;
        
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        if use_dense_solver
            [US, SS_mat, VS] = svd(TS, 'econ');
            [UD, SD_mat, VD] = svd(TD, 'econ');
        else
            [US, SS_mat, VS] = svds(TS, s);
            [UD, SD_mat, VD] = svds(TD, s);
        end
        
        % Ensure truncation to 's' components
        US = US(:, 1:s); SS_mat = SS_mat(1:s, 1:s); VS = VS(:, 1:s);
        UD = UD(:, 1:s); SD_mat = SD_mat(1:s, 1:s); VD = VD(:, 1:s);
        
        % Inverse Mapping for Vectors (U and V)
        U_A = real(US + UD) * 0.5;    U_B = imag(US + UD) * (0.5 * inv_z);
        U_C = real(US - UD) * inv_g2; U_D = imag(US - UD) * (inv_g2 * inv_z);
        
        V_A = real(VS + VD) * 0.5;    V_B = imag(VS + VD) * (0.5 * inv_z);
        V_C = real(VS - VD) * inv_g2; V_D = imag(VS - VD) * (inv_g2 * inv_z);
        
        % Inverse Mapping for Singular Values (S)
        S_A = real(SS_mat + SD_mat) * 0.5;    S_B = zeros(s, s);
        S_C = real(SS_mat - SD_mat) * inv_g2; S_D = zeros(s, s);
        
    else
        % =========================================================
        % HYPERBOLIC BRANCH (Real Domain)
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        inv_g2 = 0.5 / g;
        
        zBS = z * BS;     zBD = z * BD;
        M_SS = AS + zBS;  M_DS = AS - zBS;
        M_SD = AD + zBD;  M_DD = AD - zBD;
        
        if use_dense_solver
            [U_SS, S_SS, V_SS] = svd(M_SS, 'econ');
            [U_DS, S_DS, V_DS] = svd(M_DS, 'econ');
            [U_SD, S_SD, V_SD] = svd(M_SD, 'econ');
            [U_DD, S_DD, V_DD] = svd(M_DD, 'econ');
        else
            [U_SS, S_SS, V_SS] = svds(M_SS, s);
            [U_DS, S_DS, V_DS] = svds(M_DS, s);
            [U_SD, S_SD, V_SD] = svds(M_SD, s);
            [U_DD, S_DD, V_DD] = svds(M_DD, s);
        end
        
        % Truncate to 's' components
        U_SS = U_SS(:, 1:s); S_SS = S_SS(1:s, 1:s); V_SS = V_SS(:, 1:s);
        U_DS = U_DS(:, 1:s); S_DS = S_DS(1:s, 1:s); V_DS = V_DS(:, 1:s);
        U_SD = U_SD(:, 1:s); S_SD = S_SD(1:s, 1:s); V_SD = V_SD(:, 1:s);
        U_DD = U_DD(:, 1:s); S_DD = S_DD(1:s, 1:s); V_DD = V_DD(:, 1:s);
        
        % Recombine U Matrix
        C_U1 = (U_SS + U_DS) * 0.5;   C_U2 = (U_SS - U_DS) * inv_z2;
        C_U3 = (U_SD + U_DD) * 0.5;   C_U4 = (U_SD - U_DD) * inv_z2;
        U_A = (C_U1 + C_U3) * 0.5;    U_B = (C_U2 + C_U4) * 0.5;
        U_C = (C_U1 - C_U3) * inv_g2; U_D = (C_U2 - C_U4) * inv_g2;
        
        % Recombine V Matrix
        C_V1 = (V_SS + V_DS) * 0.5;   C_V2 = (V_SS - V_DS) * inv_z2;
        C_V3 = (V_SD + V_DD) * 0.5;   C_V4 = (V_SD - V_DD) * inv_z2;
        V_A = (C_V1 + C_V3) * 0.5;    V_B = (C_V2 + C_V4) * 0.5;
        V_C = (C_V1 - C_V3) * inv_g2; V_D = (C_V2 - C_V4) * inv_g2;
        
        % Recombine S Matrix
        C_S1 = (S_SS + S_DS) * 0.5;   C_S2 = (S_SS - S_DS) * inv_z2;
        C_S3 = (S_SD + S_DD) * 0.5;   C_S4 = (S_SD - S_DD) * inv_z2;
        S_A = (C_S1 + C_S3) * 0.5;    S_B = (C_S2 + C_S4) * 0.5;
        S_C = (C_S1 - C_S3) * inv_g2; S_D = (C_S2 - C_S4) * inv_g2;
    end

    % --- 6. OUTPUT RECONSTRUCTION ---
    if nargout <= 1
        % Return singular values in vector format if only one output is requested
        if s == 1
            U = abtessarine(S_A, S_B, S_C, S_D);
        else
            U = abtessarine(diag(S_A), diag(S_B), diag(S_C), diag(S_D));
        end
    else
        % Return full triplet [U, S, V]
        U = abtessarine(U_A, U_B, U_C, U_D);
        S = abtessarine(S_A, S_B, S_C, S_D);
        V = abtessarine(V_A, V_B, V_C, V_D);
    end
end