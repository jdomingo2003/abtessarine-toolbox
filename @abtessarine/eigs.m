function [V, D] = eigs(X, s)
% EIGS Computes a subset of dominant eigenvalues and eigenvectors of an abtessarine matrix.
%
%   D = eigs(X) returns the single most dominant eigenvalue of X.
%   [V, D] = eigs(X, s) returns a diagonal matrix D containing the 's' 
%   dominant eigenvalues and a matrix V whose columns represent the 
%   corresponding right eigenvectors.
%
%   ALGORITHMIC METHODOLOGY (Optimized Hybrid Isomorphic Solver):
%   The hypercomplex spectral decomposition decouples via the algebra's 
%   isomorphism. To maximize computational throughput and minimize memory 
%   footprint, this function implements a dynamic algorithmic router:
%
%     - Sparse Regime (s <= 3% of N): Leverages ARPACK (Implicitly Restarted 
%       Symmetric Lanczos method) for blazing-fast extraction of sparse 
%       dominant modes, avoiding full matrix diagonalization.
%     - Dense Regime (s > 3% of N): Silently pivots to LAPACK (Dense spectral 
%       solver). This avoids the massive orthogonalization overhead inherent 
%       to Krylov subspace methods for large 's', computing the full spectrum 
%       rapidly and subsequently truncating the output.
%
%   CONVERGENCE SHIELD: 
%   Convergence of the underlying iterative solvers is strictly guaranteed 
%   only for matrices exhibiting 1-Hermitian or 2-Hermitian symmetry. The 
%   algorithm performs a lightweight pre-evaluation to enforce this condition.

%   See also EIG, SVDS.

    % --- 1. SENSOR & INPUT PARSING ---
    [m, n] = size(X.A);
    if m ~= n
        error('abtessarine:eigs:NonSquareMatrix', ...
              'The input abtessarine matrix must be strictly square.');
    end
    
    if nargin < 2
        s = 1; 
    end
    
    % If the requested subset equals or exceeds matrix dimensions, route to full EIG
    if s >= m
        if nargout <= 1
            V = eig(X);
        else
            [V, D] = eig(X);
        end
        return;
    end
    
    % --- 2. GLOBAL PARAMETER RETRIEVAL ---
    % Retrieve operational parameters utilizing the standard getabtessarine interface.
    [alpha, beta] = getabtessarine(); 
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:eigs:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 3. FAST SYMMETRY SHIELD ---
    A_t = X.A.'; B_t = X.B.'; C_t = X.C.'; D_t = X.D.';
    diff_1H = max(abs(X.A(:) - A_t(:))) + max(abs(X.B(:) - B_t(:))) + ...
              max(abs(X.C(:) - C_t(:))) + max(abs(X.D(:) - D_t(:)));
              
    A_c = X.A'; B_c = -X.B'; C_c = X.C'; D_c = -X.D';
    diff_2H = max(abs(X.A(:) - A_c(:))) + max(abs(X.B(:) - B_c(:))) + ...
              max(abs(X.C(:) - C_c(:))) + max(abs(X.D(:) - D_c(:)));
              
    if (diff_1H > 1e-10) && (diff_2H > 1e-10)
        error('abtessarine:eigs:NonHermitian', ...
              'Matrix must exhibit 1-Hermitian or 2-Hermitian symmetry.');
    end
    
    % --- 4. FORWARD MAPPING: 4D to 2D Branches ---
    g = sqrt(beta);
    gC = g * X.C;    gD = g * X.D;
    
    AS = X.A + gC;   AD = X.A - gC;
    BS = X.B + gD;   BD = X.B - gD;
    
    % --- 5. DYNAMIC ROUTER CONFIGURATION ---
    % Heuristic threshold: Switch to dense solver if requested modes exceed 3% of dimension
    use_dense_solver = (s > 0.03 * m);
    
    % Universal ARPACK options: Silences diagnostic output across all MATLAB versions.
    % We strictly avoid 'opts.issym' to prevent modern deprecation warnings.
    opts.disp = 0;
    
    % --- 6. PARALLEL SOLVER & BIFURCATION ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0)
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        if use_dense_solver
            [VS, DS_vec] = eig(TS, 'vector');
            [VD, DD_vec] = eig(TD, 'vector');
        else
            % Force exact numerical symmetry for ARPACK stability
            TS = (TS + TS') * 0.5;
            TD = (TD + TD') * 0.5;
            [VS, DS_mat] = eigs(TS, s, 'LM', opts); DS_vec = diag(DS_mat);
            [VD, DD_mat] = eigs(TD, s, 'LM', opts); DD_vec = diag(DD_mat);
        end
        
        % Sort and strictly truncate to 's' modes
        [~, indS] = sort(abs(DS_vec), 'descend'); VS = VS(:, indS(1:s)); DS_vec = DS_vec(indS(1:s));
        [~, indD] = sort(abs(DD_vec), 'descend'); VD = VD(:, indD(1:s)); DD_vec = DD_vec(indD(1:s));
        
        % Inverse Mapping Components (4D Reconstruction)
        inv_g2 = 0.5 / g;
        
        E_A = real(VS + VD) * 0.5;    E_B = imag(VS + VD) * (0.5 * inv_z);
        E_C = real(VS - VD) * inv_g2; E_D = imag(VS - VD) * (inv_g2 * inv_z);
        
        L_A = real(DS_vec + DD_vec) * 0.5;    L_B = imag(DS_vec + DD_vec) * (0.5 * inv_z);
        L_C = real(DS_vec - DD_vec) * inv_g2; L_D = imag(DS_vec - DD_vec) * (inv_g2 * inv_z);
        
        % Output Formatting
        if nargout <= 1
            V = abtessarine(L_A, L_B, L_C, L_D);
        else
            V = abtessarine(E_A, E_B, E_C, E_D);
            D = abtessarine(diag(L_A), diag(L_B), diag(L_C), diag(L_D));
        end
        
    else
        % =========================================================
        % REAL / SPLIT-COMPLEX DOMAIN (Alpha > 0)
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        zBS = z * BS;   zBD = z * BD;
        SS = AS + zBS;  DS = AS - zBS;
        SD = AD + zBD;  DD = AD - zBD;
        
        if use_dense_solver
            [V_SS, D_SS_vec] = eig(SS, 'vector');
            [V_DS, D_DS_vec] = eig(DS, 'vector');
            [V_SD, D_SD_vec] = eig(SD, 'vector');
            [V_DD, D_DD_vec] = eig(DD, 'vector');
        else
            % Force exact numerical symmetry for ARPACK stability
            SS = (SS + SS.') * 0.5;
            DS = (DS + DS.') * 0.5;
            SD = (SD + SD.') * 0.5;
            DD = (DD + DD.') * 0.5;
            [V_SS, D_SS_mat] = eigs(SS, s, 'LM', opts); D_SS_vec = diag(D_SS_mat);
            [V_DS, D_DS_mat] = eigs(DS, s, 'LM', opts); D_DS_vec = diag(D_DS_mat);
            [V_SD, D_SD_mat] = eigs(SD, s, 'LM', opts); D_SD_vec = diag(D_SD_mat);
            [V_DD, D_DD_mat] = eigs(DD, s, 'LM', opts); D_DD_vec = diag(D_DD_mat);
        end
        
        % Sort and strictly truncate to 's' modes
        [~, iSS] = sort(abs(D_SS_vec), 'descend'); V_SS = V_SS(:, iSS(1:s)); D_SS_vec = D_SS_vec(iSS(1:s));
        [~, iDS] = sort(abs(D_DS_vec), 'descend'); V_DS = V_DS(:, iDS(1:s)); D_DS_vec = D_DS_vec(iDS(1:s));
        [~, iSD] = sort(abs(D_SD_vec), 'descend'); V_SD = V_SD(:, iSD(1:s)); D_SD_vec = D_SD_vec(iSD(1:s));
        [~, iDD] = sort(abs(D_DD_vec), 'descend'); V_DD = V_DD(:, iDD(1:s)); D_DD_vec = D_DD_vec(iDD(1:s));
        
        % Inverse Mapping Components (Complex Intermediaries)
        inv_g2 = 0.5 / g;
        
        C_V1 = (V_SS + V_DS) * 0.5;   C_V2 = (V_SS - V_DS) * inv_z2;
        C_V3 = (V_SD + V_DD) * 0.5;   C_V4 = (V_SD - V_DD) * inv_z2;
        
        C_D1 = (D_SS_vec + D_DS_vec) * 0.5;   C_D2 = (D_SS_vec - D_DS_vec) * inv_z2;
        C_D3 = (D_SD_vec + D_DD_vec) * 0.5;   C_D4 = (D_SD_vec - D_DD_vec) * inv_z2;
        
        CA_V = (C_V1 + C_V3) * 0.5;    CB_V = (C_V2 + C_V4) * 0.5;
        CC_V = (C_V1 - C_V3) * inv_g2; CD_V = (C_V2 - C_V4) * inv_g2;
        
        CA_D = (C_D1 + C_D3) * 0.5;    CB_D = (C_D2 + C_D4) * 0.5;
        CC_D = (C_D1 - C_D3) * inv_g2; CD_D = (C_D2 - C_D4) * inv_g2;
        
        % Output Formatting and Topological Confinement Check
        % Uses the diff_1H pre-calculated in the Fast Symmetry Shield
        if diff_1H <= 1e-10
            % Confined to 4D (Force real to eliminate numerical noise)
            if nargout <= 1
                V = abtessarine(real(CA_D), real(CB_D), real(CC_D), real(CD_D));
            else
                V = abtessarine(real(CA_V), real(CB_V), real(CC_V), real(CD_V));
                D = abtessarine(diag(real(CA_D)), diag(real(CB_D)), diag(real(CC_D)), diag(real(CD_D)));
            end
        else
            % Escapes to 8D automatically
            if nargout <= 1
                V = gabtessarine(real(CA_D), imag(CA_D), real(CB_D), imag(CB_D), ...
                                 real(CC_D), imag(CC_D), real(CD_D), imag(CD_D));
            else
                V = gabtessarine(real(CA_V), imag(CA_V), real(CB_V), imag(CB_V), ...
                                 real(CC_V), imag(CC_V), real(CD_V), imag(CD_V));
                D = gabtessarine(diag(real(CA_D)), diag(imag(CA_D)), diag(real(CB_D)), diag(imag(CB_D)), ...
                                 diag(real(CC_D)), diag(imag(CC_D)), diag(real(CD_D)), diag(imag(CD_D)));
            end
        end
    end
end