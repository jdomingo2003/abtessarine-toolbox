function Z_inv = inv(X)
% INV Computes the matrix inverse of an abtessarine object.
%
%   Z_inv = inv(X) calculates the inverse utilizing a partitioned inversion 
%   algorithm based on the algebraic isomorphism of the abtessarine space.
%
%   ALGORITHMIC STRATEGY:
%   The function implements an isomorphic decoupling that maps the 4D 
%   hypercomplex matrix into two independent 2D (complex) or 1D (real) 
%   branches. This allows the use of optimized native LAPACK engines for 
%   dense matrix inversion.
%
%   NUMERICAL OPTIMIZATION:
%   - Branching: Bifurcated according to the sign of the global parameter alpha.
%   - FLOP Reduction: Implements algebraic recycling in the real domain 
%     to minimize matrix-level subtractions and divisions.
%   - Cache Efficiency: Direct component extraction and minimal temporal 
%     allocations to optimize L1/L2 cache performance.

%   See also PINV, MLDIVIDE, MRDIVIDE, DET.

    % --- 1. GLOBAL PARAMETER RETRIEVAL ---
    [alpha, beta] = getabtessarine(); 
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:inv:ParametersNotSet', ...
              'Global parameters (alpha, beta) are uninitialized. Run setabtessarine.');
    end

    % --- 2. PRECOMPUTATION & COMPONENT EXTRACTION ---
    g = sqrt(beta);
    z = sqrt(abs(alpha));
    
    % Direct extraction to minimize overhead from property accessors
    A1 = X.A; A2 = X.B; A3 = X.C; A4 = X.D;
    
    gA3 = g * A3;
    gA4 = g * A4;
    
    AAS = A1 + gA3;
    AAD = A1 - gA3;
    
    tempB = A2 + gA4;
    tempD = A2 - gA4;
    
    BBS = z * tempB;
    BBD = z * tempD;

    % --- 3. BIFURCATED SPECTRAL COMPUTATION ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Elliptic Isomorphism
        % =========================================================
        % Mapping to native LAPACK complex engines
        TTS = inv(AAS + BBS * 1i);
        TTD = inv(AAD + BBD * 1i);
        
        E1 = real(TTS);
        E2 = imag(TTS) / z;
        
        F1 = real(TTD);
        F2 = imag(TTD) / z;
        
    elseif alpha > 0
        % =========================================================
        % REAL DOMAIN (Alpha > 0) - Hyperbolic Isomorphism
        % =========================================================
        ES = inv(AAS + BBS);
        FS = inv(AAS - BBS);
        
        % Algebraic Recycling: Extracting components via mean-difference
        E1 = (ES + FS) * 0.5;
        E2 = (ES - E1) / z; 
        
        ED = inv(AAD + BBD);
        FD = inv(AAD - BBD);
        
        F1 = (ED + FD) * 0.5;
        F2 = (ED - F1) / z;
        
    else
        % Alpha = 0 represents a parabolic singularity in this isomorphism
        error('abtessarine:inv:ParabolicSingularity', ...
              'Matrix inversion is undefined for alpha = 0 (Parabolic domain).');
    end

    % --- 4. FINAL RECOMBINATION & DIRECT INJECTION ---
    % Compute shared recombination terms to further reduce FLOPs
    MMR = (E1 + F1) * 0.5;
    MMI = (E2 + F2) * 0.5;

    % Reconstruct the hypercomplex object via direct memory injection
    Z_inv = abtessarine(...
        MMR, ...
        MMI, ...
        (E1 - MMR) / g, ...
        (E2 - MMI) / g  ...
    );
end