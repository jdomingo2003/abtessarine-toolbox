function [V, D] = eig(X)
% EIG Computes eigenvalues and eigenvectors of an abtessarine matrix.
%
%   D = eig(X) returns a column vector D containing the eigenvalues of X.
%   [V, D] = eig(X) returns a diagonal matrix D of eigenvalues and a 
%   full matrix V whose columns represent the corresponding right eigenvectors.
%
%   ALGORITHMIC METHODOLOGY:
%   The spectral decomposition is executed by mapping the hypercomplex 
%   matrix to its native 2D or 1D isomorphic branches, solving the 
%   native eigenvalue problems utilizing optimized routines, and 
%   reconstructing the hypercomplex spectrum via inverse isomorphic mapping.
%   
%   Crucially, within the hyperbolic domain (alpha > 0), the characteristic 
%   polynomials of the native real branches may yield complex conjugate roots. 
%   Consequently, the spectral output inherently "escapes" into the 
%   8-dimensional space (gabtessarines) UNLESS the original matrix exhibits 
%   strictly 1-Hermitian symmetry (X = X.'). The algorithm incorporates a 
%   high-precision pre-evaluation of this symmetry to dynamically confine 
%   the output to the 4-dimensional abtessarines or automatically expand 
%   it to gabtessarines, strictly dictated by the algebraic topology. 
%
%   EIGENVALUE ALIGNMENT AND SORTING:
%   To guarantee consistent eigen-mode alignment across all isomorphic 
%   branches and to ensure optimal mathematical behavior for downstream 
%   High-Performance Computing (HPC) applications—such as Rank-k 
%   approximations (e.g., in Singular Value Decompositions) and Principal 
%   Component Analysis (PCA)—the eigenvalues are strictly sorted in 
%   descending order based on their absolute magnitude. The corresponding 
%   eigenvectors are permuted accordingly prior to the inverse isomorphic mapping.

%   See also EIGS, SVD, PINV, NORM.

    % --- 1. SQUARE DIMENSIONALITY VALIDATION ---
    [m, n] = size(X.A);
    if m ~= n
        error('abtessarine:eig:NonSquareMatrix', ...
              'The input abtessarine matrix must be strictly square to compute its spectral decomposition.');
    end
    
    % --- 2. GLOBAL PARAMETER RETRIEVAL ---
    % Retrieve operational parameters utilizing the standard getabtessarine interface.
    [alpha, beta] = getabtessarine(); 
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:eig:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 3. FORWARD MAPPING: 4D to 2D Branches ---
    g = sqrt(beta);
    gC = g * X.C;    gD = g * X.D;
    
    AS = X.A + gC;   AD = X.A - gC;
    BS = X.B + gD;   BD = X.B - gD;
    
    % --- 4. SPECTRAL SOLVER BIFURCATION ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Elliptic Isomorphism
        % (Always inherently confines to 4D abtessarines)
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Solve and align via absolute magnitude (Descending for PCA/SVD consistency)
        [VS, DS_vec] = eig(TS, 'vector');
        [~, indS] = sort(abs(DS_vec), 'descend');
        VS = VS(:, indS); DS_vec = DS_vec(indS);
        
        [VD, DD_vec] = eig(TD, 'vector');
        [~, indD] = sort(abs(DD_vec), 'descend');
        VD = VD(:, indD); DD_vec = DD_vec(indD);
        
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
        % REAL / SPLIT-COMPLEX DOMAIN (Alpha > 0) - Hyperbolic Isomorphism
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        % HPC 1-Hermitian Pre-Check: Bypassing OOP instantiation overhead
        diff_norm = norm(X.A - X.A.', 'fro') + norm(X.B - X.B.', 'fro') + ...
                    norm(X.C - X.C.', 'fro') + norm(X.D - X.D.', 'fro');
        is_1_hermitian = (diff_norm <= 1e-10);
        
        % Map to native Real branches
        zBS = z * BS;   zBD = z * BD;
        SS = AS + zBS;  DS = AS - zBS;
        SD = AD + zBD;  DD = AD - zBD;
        
        % Solve and align all 4 branches (Descending for PCA/SVD consistency)
        [V_SS, D_SS_vec] = eig(SS, 'vector'); [~, iSS] = sort(abs(D_SS_vec), 'descend'); V_SS = V_SS(:, iSS); D_SS_vec = D_SS_vec(iSS);
        [V_DS, D_DS_vec] = eig(DS, 'vector'); [~, iDS] = sort(abs(D_DS_vec), 'descend'); V_DS = V_DS(:, iDS); D_DS_vec = D_DS_vec(iDS);
        [V_SD, D_SD_vec] = eig(SD, 'vector'); [~, iSD] = sort(abs(D_SD_vec), 'descend'); V_SD = V_SD(:, iSD); D_SD_vec = D_SD_vec(iSD);
        [V_DD, D_DD_vec] = eig(DD, 'vector'); [~, iDD] = sort(abs(D_DD_vec), 'descend'); V_DD = V_DD(:, iDD); D_DD_vec = D_DD_vec(iDD);
        
        % Inverse Mapping Components (Complex Intermediaries Processing)
        inv_g2 = 0.5 / g;
        
        C_V1 = (V_SS + V_DS) * 0.5;   C_V2 = (V_SS - V_DS) * inv_z2;
        C_V3 = (V_SD + V_DD) * 0.5;   C_V4 = (V_SD - V_DD) * inv_z2;
        
        C_D1 = (D_SS_vec + D_DS_vec) * 0.5;   C_D2 = (D_SS_vec - D_DS_vec) * inv_z2;
        C_D3 = (D_SD_vec + D_DD_vec) * 0.5;   C_D4 = (D_SD_vec - D_DD_vec) * inv_z2;
        
        CA_V = (C_V1 + C_V3) * 0.5;    CB_V = (C_V2 + C_V4) * 0.5;
        CC_V = (C_V1 - C_V3) * inv_g2; CD_V = (C_V2 - C_V4) * inv_g2;
        
        CA_D = (C_D1 + C_D3) * 0.5;    CB_D = (C_D2 + C_D4) * 0.5;
        CC_D = (C_D1 - C_D3) * inv_g2; CD_D = (C_D2 - C_D4) * inv_g2;
        
        % Output Formatting strictly matching theoretical topological confinement
        if is_1_hermitian
            % Confinement to 4D -> Output is strictly abtessarine (Force real to eliminate numerical noise)
            if nargout <= 1
                V = abtessarine(real(CA_D), real(CB_D), real(CC_D), real(CD_D));
            else
                V = abtessarine(real(CA_V), real(CB_V), real(CC_V), real(CD_V));
                D = abtessarine(diag(real(CA_D)), diag(real(CB_D)), diag(real(CC_D)), diag(real(CD_D)));
            end
        else
            % Escapes to 8D -> Automatically instantiates gabtessarine
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