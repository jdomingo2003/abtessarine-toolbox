function X = generatePositiveDefinite(n, alpha, beta)
% GENERATEPOSITIVEDEFINITE Generates a positive definite abtessarine matrix.
%   X = GENERATEPOSITIVEDEFINITE(N) creates an N-by-N positive definite
%   hypercomplex matrix using the globally defined alpha and beta parameters.
%
%   X = GENERATEPOSITIVEDEFINITE(N, ALPHA, BETA) creates the matrix using
%   the explicitly provided topological parameters ALPHA and BETA.
%
%   The algorithm automatically adapts to generate a 1-Hermitian matrix 
%   for alpha > 0, or a 2-Hermitian matrix for alpha < 0, ensuring stability
%   for advanced spectral operations like Cholesky factorizations.
%
%   Inputs:
%       N     - Size of the generated N-by-N square matrix.
%       ALPHA - (Optional) Real non-zero topological parameter.
%       BETA  - (Optional) Real positive topological parameter.
%
%   Outputs:
%       X     - A mathematically valid, positive definite @abtessarine matrix.
%
%   See also: ABTESSSARINE, SVD, SVDS, EIG.

    % --- 1. HPC ENVIRONMENT SENSOR & INPUT PARSING ---
    % Allow the user to inject alpha and beta directly. 
    % Fallback to global environment if not provided.
    if nargin < 3
        beta = getappdata(0, 'Tessarine_Beta'); 
    end
    if nargin < 2
        alpha = getappdata(0, 'Tessarine_Alpha');
    end
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:generatePD:MissingEnvironment', ...
              'Undefined environment. Provide alpha and beta, or run setabtessarine.');
    end
    if alpha == 0
        error('abtessarine:generatePD:ZeroAlpha', ...
              'Alpha cannot be exactly zero.');
    end
    % --- 2. THEORETICAL PARAMETER MAPPING ---
    G = beta;
    g = sqrt(G); 
    if alpha < 0
        % =================================================================
        % ALPHA < 0: GENERATE 2-HERMITIAN MATRIX (Complex Branches)
        % =================================================================
        z = sqrt(-alpha);
        
        % Generate two Complex Hermitian Positive Definite matrices
        % T = M*M' + eye ensures strictly positive real eigenvalues
        M_S = randn(n) + 1i * randn(n);  T_S = M_S * M_S' + eye(n);
        M_D = randn(n) + 1i * randn(n);  T_D = M_D * M_D' + eye(n);
        
        % The real part is symmetric. The imaginary part is skew-symmetric.
        A_S = real(T_S);  B_Sz = imag(T_S);
        A_D = real(T_D);  B_Dz = imag(T_D);
        
        % Inverse Algebraic Transformation (Generates A, C symmetric; B, D skew)
        A = (A_S + A_D) * 0.5;
        C = (A_S - A_D) / (2 * g);
        B = (B_Sz + B_Dz) / (2 * z);
        D = (B_Sz - B_Dz) / (2 * g * z);
        
    else
        % =================================================================
        % ALPHA > 0: GENERATE 1-HERMITIAN MATRIX (Real Branches)
        % =================================================================
        z = sqrt(alpha);
        gz = g * z;
        
        % Generate four Real Symmetric Positive Definite matrices
        M1 = randn(n); A1 = M1 * M1.' + eye(n);
        M2 = randn(n); A2 = M2 * M2.' + eye(n);
        M3 = randn(n); A3 = M3 * M3.' + eye(n);
        M4 = randn(n); A4 = M4 * M4.' + eye(n);
        
        % Inverse Algebraic Transformation (Generates A, B, C, D all symmetric)
        A = (A1 + A2 + A3 + A4) * 0.25;
        B = (A1 - A2 + A3 - A4) / (4 * z);
        C = (A1 + A2 - A3 - A4) / (4 * g);
        D = (A1 - A2 - A3 + A4) / (4 * gz);
    end
    % --- 3. OBJECT CONSTRUCTION ---
    X = abtessarine(A, B, C, D);
end