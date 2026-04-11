function d = det(X)
% DET Computes the determinant of an abtessarine matrix.
%
%   d = det(X) calculates the determinant of the strictly square 
%   abtessarine matrix X.
%
%   ALGORITHMIC METHODOLOGY:
%   Computing the determinant of an abtessarine matrix natively (managing 
%   zero divisors and idempotent branches) inherently requires resolving an 
%   abtessarine permutation matrix during LU factorization. Explicitly 
%   tracking the parity of these permutations across theoretical branches 
%   is computationally prohibitive and scales poorly for large-dimensional arrays.
%
%   To maximize computational throughput, this algorithm leverages the 
%   multiplicative homomorphism of the algebra's isomorphism. It directly 
%   maps the 4D matrix into its 2D or 1D native branches (Complex or Real, 
%   dictated by the global alpha and beta topological parameters). 
%   It then evaluates their scalar determinants utilizing highly optimized, 
%   multi-threaded LAPACK routines (which implicitly and safely resolve all 
%   permutation parities), and finally reconstructs the 4D abtessarine 
%   determinant via inverse mapping. 
%   This fundamentally reduces the algorithmic complexity from O(N^4) to O(N^3).
%
%   INPUT:
%   X - Square abtessarine matrix (p x p).
%
%   OUTPUT:
%   d - A 1x1 abtessarine object (scalar) representing the determinant.
%
%   See also: LU, MLDIVIDE, INV.

    % --- 1. SQUARE DIMENSIONALITY VALIDATION (O(1)) ---
    [m, n] = size(X.A);
    if m ~= n
        error('abtessarine:det:NonSquareMatrix', ...
              'The input abtessarine matrix must be strictly square to compute its determinant.');
    end
    
    % --- 2. GLOBAL PARAMETER RETRIEVAL (O(1)) ---
    % Retrieve operational parameters utilizing the standard getabtessarine interface.
    [alpha, beta] = getabtessarine(); 
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:det:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 3. FORWARD MAPPING: 4D to 2D Branches (Beta Mapping) (O(N^2)) ---
    g = sqrt(beta);
    
    % Memory-efficient precomputation
    gC = g * X.C;
    gD = g * X.D;
    
    AS = X.A + gC;    AD = X.A - gC;
    BS = X.B + gD;    BD = X.B - gD;
    
    % --- 4. SECONDARY REDUCTION & NATIVE LAPACK DETERMINANTS (O(N^3)) ---
    if alpha < 0
        % =========================================================
        % COMPLEX DOMAIN (Alpha < 0) - Elliptic Isomorphism
        % =========================================================
        z = sqrt(-alpha); 
        inv_z = 1 / z;
        
        % Map to native Complex branches
        TS = AS + (BS * z) * 1i;
        TD = AD + (BD * z) * 1i;
        
        % Multi-threaded LAPACK determinant computation
        det_TS = det(TS);
        det_TD = det(TD);
        
        % Extract real and imaginary equivalents utilizing scalar multiplication
        dS1 = real(det_TS);  dS2 = imag(det_TS) * inv_z;
        dD1 = real(det_TD);  dD2 = imag(det_TD) * inv_z;
        
    else
        % =========================================================
        % REAL DOMAIN (Alpha > 0) - Hyperbolic Isomorphism
        % =========================================================
        z = sqrt(alpha);
        inv_z2 = 0.5 / z;
        
        % Map to native Real branches
        zBS = z * BS;     zBD = z * BD;
        
        SS = AS + zBS;    DS = AS - zBS;
        SD = AD + zBD;    DD = AD - zBD;
        
        % Multi-threaded LAPACK determinant computation
        det_SS = det(SS);
        det_DS = det(DS);
        det_SD = det(SD);
        det_DD = det(DD);
        
        % Reconstruct 2D equivalents utilizing scalar multiplication
        dS1 = (det_SS + det_DS) * 0.5;  dS2 = (det_SS - det_DS) * inv_z2;
        dD1 = (det_SD + det_DD) * 0.5;  dD2 = (det_SD - det_DD) * inv_z2;
    end
    
    % --- 5. FINAL 4D INVERSE MAPPING (O(1)) ---
    inv_g2 = 0.5 / g;
    
    % The reconstructed output 'd' is allocated directly as a 1x1 abtessarine scalar
    d = abtessarine((dS1 + dD1) * 0.5, ...
                    (dS2 + dD2) * 0.5, ...
                    (dS1 - dD1) * inv_g2, ...
                    (dS2 - dD2) * inv_g2);
end