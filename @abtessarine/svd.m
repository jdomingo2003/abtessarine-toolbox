function varargout = svd(X, varargin)
% SVD Singular value decomposition for abtessarine objects.
%
%   S = SVD(X) returns a vector containing the singular values in the 
%   abtessarine domain.
%
%   [U, S, V] = SVD(X) produces a diagonal matrix S and unitary/orthogonal 
%   matrices U and V such that X = U*S*V' (elliptic) or X = U*S*V.' (hyperbolic).
%
%   [U, S, V] = SVD(X, 'econ') performs the economy-size decomposition, 
%   providing massive memory savings for non-square matrices.
%
%   ALGORITHMIC METHODOLOGY (Isomorphic Projection):
%   The algorithm decouples the 4D abtessarine matrix into independent 
%   mathematical branches based on the sign of alpha:
%     - Alpha < 0 (Elliptic): Mapped to 2 parallel complex SVDs.
%     - Alpha > 0 (Hyperbolic): Mapped to 4 parallel real SVDs.
%   This ensures numerical stability and leverages MATLAB's internal 
%   LAPACK-optimized routines.

%   See also SVDS, EIG, PINV, NORM.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:svd:MissingEnvironment', ...
              'Global parameters are uninitialized. Execute setabtessarine.');
    end
    
    if alpha == 0
        error('abtessarine:svd:ZeroAlpha', ...
              'Mathematical constraint: SVD is undefined for the parabolic case (alpha = 0).');
    end

    % --- 2. FORWARD MAPPING: 4D to Spectral Branches ---
    g = sqrt(beta);
    gC = g * X.C;    gD = g * X.D;
    
    AS = X.A + gC;   AD = X.A - gC;
    BS = X.B + gD;   BD = X.B - gD;
    
    % Constants for inverse mapping
    inv_g2 = 0.5 / g;

    % --- 3. PARALLEL SOLVER CORE ---
    if alpha < 0
        % =========================================================
        % ELLIPTIC BRANCH (Complex Isomorphism)
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        % Build complex branch matrices
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        if nargout <= 1
            % Fast path: Singular values only
            SS_c = svd(TS, varargin{:});
            SD_c = svd(TD, varargin{:});
            
            % Reconstruct S vector/matrix
            S_A = real(SS_c + SD_c) * 0.5;
            S_B = imag(SS_c + SD_c) * (0.5 * inv_z);
            S_C = real(SS_c - SD_c) * inv_g2;
            S_D = imag(SS_c - SD_c) * (inv_g2 * inv_z);
            varargout{1} = abtessarine(S_A, S_B, S_C, S_D);
        else
            % Full path: [U, S, V]
            [US_c, SS_c, VS_c] = svd(TS, varargin{:});
            [UD_c, SD_c, VD_c] = svd(TD, varargin{:});
            
            % Map components back to 4D (U, S, and V)
            for i = 1:3
                switch i
                    case 1, M_S = US_c; M_D = UD_c; % U matrix
                    case 2, M_S = SS_c; M_D = SD_c; % S matrix
                    case 3, M_S = VS_c; M_D = VD_c; % V matrix
                end
                
                RA = real(M_S + M_D) * 0.5;
                RB = imag(M_S + M_D) * (0.5 * inv_z);
                RC = real(M_S - M_D) * inv_g2;
                RD = imag(M_S - M_D) * (inv_g2 * inv_z);
                varargout{i} = abtessarine(RA, RB, RC, RD);
            end
        end
    else
        % =========================================================
        % HYPERBOLIC BRANCH (Real Isomorphism)
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        zBS = z * BS;     zBD = z * BD;
        
        % Unroll into 4 strictly real matrices (Idempotent Split)
        E_s1 = AS + zBS;  E_s2 = AS - zBS;
        E_d1 = AD + zBD;  E_d2 = AD - zBD;
        
        if nargout <= 1
            % Fast path: Singular values only
            Ss1 = svd(E_s1, varargin{:});
            Ss2 = svd(E_s2, varargin{:});
            Sd1 = svd(E_d1, varargin{:});
            Sd2 = svd(E_d2, varargin{:});
            
            Ss_real = (Ss1 + Ss2) * 0.5;   Ss_imag = (Ss1 - Ss2) * inv_z2;
            Sd_real = (Sd1 + Sd2) * 0.5;   Sd_imag = (Sd1 - Sd2) * inv_z2;
            
            S_A = (Ss_real + Sd_real) * 0.5;
            S_B = (Ss_imag + Sd_imag) * 0.5;
            S_C = (Ss_real - Sd_real) * inv_g2;
            S_D = (Ss_imag - Sd_imag) * inv_g2;
            varargout{1} = abtessarine(S_A, S_B, S_C, S_D);
        else
            % Full path: [U, S, V]
            [Us1, Ss1, Vs1] = svd(E_s1, varargin{:});
            [Us2, Ss2, Vs2] = svd(E_s2, varargin{:});
            [Ud1, Sd1, Vd1] = svd(E_d1, varargin{:});
            [Ud2, Sd2, Vd2] = svd(E_d2, varargin{:});
            
            % Reconstruct U, S, and V matrices
            for i = 1:3
                switch i
                    case 1, M1=Us1; M2=Us2; M3=Ud1; M4=Ud2;
                    case 2, M1=Ss1; M2=Ss2; M3=Sd1; M4=Sd2;
                    case 3, M1=Vs1; M2=Vs2; M3=Vd1; M4=Vd2;
                end
                
                Ms_real = (M1 + M2) * 0.5;   Ms_imag = (M1 - M2) * inv_z2;
                Md_real = (M3 + M4) * 0.5;   Md_imag = (M3 - M4) * inv_z2;
                
                RA = (Ms_real + Md_real) * 0.5;
                RB = (Ms_imag + Md_imag) * 0.5;
                RC = (Ms_real - Md_real) * inv_g2;
                RD = (Ms_imag - Md_imag) * inv_g2;
                varargout{i} = abtessarine(RA, RB, RC, RD);
            end
        end
    end
end