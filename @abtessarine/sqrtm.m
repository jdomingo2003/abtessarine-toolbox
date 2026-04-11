function Z_out = sqrtm(X)
% SQRTM Matrix square root for abtessarine objects.
%
%   Z = SQRTM(X) computes the principal matrix square root utilizing 
%   an Idempotent Decomposition strategy.
%
%   ALGORITHMIC ARCHITECTURE:
%   The function maps the 4D hypercomplex matrix into its spectral branches:
%     - If Alpha < 0 (Elliptic): Uses a 4D classical root via native 
%       complex LAPACK engines.
%     - If Alpha > 0 (Hyperbolic): Implements an 8D spawning route. 
%
%   DIMENSIONALITY CONTROL:
%   In the hyperbolic case (alpha > 0), the matrix square root of an 
%   abtessarine can "leak" into a higher-dimensional 8D space (gabtessarine).
%   The function performs a structural pre-check: if the matrix is 
%   1-Hermitian, it forces a theoretical 4D closure; otherwise, it 
%   instantiates a gabtessarine object to preserve algebraic integrity.

%   See also MPOWER, EIG, CHOL.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:sqrtm:MissingEnvironment', ...
              'Global parameters are uninitialized. Execute setabtessarine.');
    end
    
    if alpha == 0
        error('abtessarine:sqrtm:ZeroAlpha', ...
              'Mathematical constraint: Square root is undefined for alpha = 0.');
    end
    
    g = sqrt(beta);

    % --- 2. STRUCTURAL PRE-CHECK (Symmetry Analysis) ---
    is_1_hermitian = false;
    if alpha > 0
        % X is 1-Hermitian if all components are symmetric
        is_1_hermitian = issymmetric(X.A) && issymmetric(X.B) && ...
                         issymmetric(X.C) && issymmetric(X.D);
    end

    % --- 3. IDEMPOTENT DECOMPOSITION (Spectral Projection) ---
    AS = X.A + g * X.C;
    BS = X.B + g * X.D;
    AD = X.A - g * X.C;
    BD = X.B - g * X.D;

    % --- 4. CORE MATHEMATICAL ENGINE & BIFURCATION ---
    if alpha < 0
        % =========================================================
        % ROUTE 1: Elliptic Branch (Alpha < 0) -> 4D Closure
        % =========================================================
        z = sqrt(abs(alpha));
        
        % Direct injection into complex LAPACK sqrtm
        CTS = sqrtm(AS + (z * BS) * 1i);
        CTD = sqrtm(AD + (z * BD) * 1i);
        
        % Deconstruct complex results
        CS_R = real(CTS); CS_I = imag(CTS) / z;
        CD_R = real(CTD); CD_I = imag(CTD) / z;
        
        % Recombination with L1 Cache Recycling
        R_A1 = (CS_R + CD_R) * 0.5;
        R_B1 = (CS_I + CD_I) * 0.5;
        
        % Instantiate 4D Result
        Z_out = abtessarine(R_A1, R_B1, (CS_R - R_A1) / g, (CS_I - R_B1) / g);
        
    else
        % =========================================================
        % ROUTE 2: Hyperbolic Branch (Alpha > 0) -> 8D Spawning
        % =========================================================
        z = sqrt(alpha);
        
        % Spectral projections for the Sum-Branch
        zBS = z * BS;
        CA_S = sqrtm(AS + zBS);
        CB_S = sqrtm(AS - zBS);
        
        U1_S = (CA_S + CB_S) * 0.5;
        U2_S = (CA_S - U1_S) / z;
        CS_R  = real(U1_S); CS_I  = imag(U1_S);
        CS_i  = real(U2_S); CS_Ii = imag(U2_S);
        
        % Spectral projections for the Difference-Branch
        zBD = z * BD;
        CA_D = sqrtm(AD + zBD);
        CB_D = sqrtm(AD - zBD);
        
        U1_D = (CA_D + CB_D) * 0.5;
        U2_D = (CA_D - U1_D) / z;
        CD_R  = real(U1_D); CD_I  = imag(U1_D);
        CD_i  = real(U2_D); CD_Ii = imag(U2_D);
        
        % Recombine components into the 8D Gabtessarine basis
        R_A1 = (CS_R + CD_R) * 0.5;
        R_A2 = (CS_I + CD_I) * 0.5;
        R_B1 = (CS_i + CD_i) * 0.5;
        R_B2 = (CS_Ii + CD_Ii) * 0.5;
        
        % --- 5. THEORETICAL COLLAPSE & INJECTION ---
        if is_1_hermitian
            % For 1-Hermitian matrices, the result collapses back to 4D
            Z_out = abtessarine(R_A1, R_B1, ...
                               (CS_R - R_A1) / g, ...
                               (CS_i - R_B1) / g);
        else
            % General case requires full 8-dimensional representation
            % (Requires 'gabtessarine' class to be in path)
            Z_out = gabtessarine(R_A1, R_A2, R_B1, R_B2, ...
                                 (CS_R - R_A1) / g, ...
                                 (CS_I - R_A2) / g, ...
                                 (CS_i - R_B1) / g, ...
                                 (CS_Ii - R_B2) / g);
        end
    end
end