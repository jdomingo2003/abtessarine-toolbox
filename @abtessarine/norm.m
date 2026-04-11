function n_val = norm(X, type)
% NORM Computes the norm of an abtessarine matrix or vector.
%
%   n = norm(X) computes the NON-HOMOGENEOUS TOPOLOGICAL NORM.
%   This is the default metric used for distance measurements and 
%   solving Least Squares Problems natively within the algebra.
%
%   THEORETICAL OVERVIEW:
%   Unlike strict Euclidean norms, this metric is "non-homogeneous". It 
%   rigorously preserves the alpha and beta geometry of the Cayley table 
%   via the parametric Hermitian transpose. Due to the algebra's 
%   topological curvature (and potential zero divisors in hyperbolic 
%   cases), it guarantees the greatest computational efficiency for 
%   exact topological distances.
%
%   n = norm(X, type) specifies classical STRICT matrix norms:
%     - 'topological': Weighted energy norm (alpha/beta dependent).
%     - 'fro' : Frobenius norm (Standard Euclidean magnitude).
%     - 2     : Spectral norm (Maximum singular value via bifurcation).
%     - 1     : Maximum absolute column sum.
%     - inf   : Maximum absolute row sum.

%   See also DET, SVD, EIG.

% Default to topological norm if no type is specified
    if nargin < 2
        type = 'topological';
    end

    % Direct component extraction for maximum throughput
    A = X.A; B = X.B; C = X.C; D = X.D;
    
    % --- 1. GLOBAL TOPOLOGICAL PARAMETERS ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:norm:Uninitialized', ...
              'Algebraic environment not initialized. Run setabtessarine first.');
    end

    % --- 2. STRING-BASED NORM SELECTION ---
    if ischar(type) || isstring(type)
        if strcmpi(type, 'topological')
            % NON-HOMOGENEOUS TOPOLOGICAL NORM
            % Mathematically: sqrt(trace(Re(X^H * X)))
            % Optimized analytically to avoid O(N^3) multiplications
            topological_energy = norm(A, 'fro')^2 + ...
                                 alpha * norm(B, 'fro')^2 + ...
                                 beta * norm(C, 'fro')^2 + ...
                                 (alpha * beta) * norm(D, 'fro')^2;
            
            % Note: In hyperbolic spaces (alpha/beta > 0), energy can be negative.
            % We use abs() to ensure a real-valued metric if necessary, 
            % though typically the sqrt of the absolute energy is used.
            n_val = sqrt(abs(topological_energy));
            return;
            
        elseif strcmpi(type, 'fro')
            % STANDARD FROBENIUS NORM
            % Treats the matrix as a flattened 4N^2 real vector.
            n_val = sqrt(norm(A, 'fro')^2 + norm(B, 'fro')^2 + ...
                         norm(C, 'fro')^2 + norm(D, 'fro')^2);
            return;
            
        elseif strcmpi(type, 'inf')
            % INFINITY NORM (Maximum absolute row sum)
            M = sqrt(A.^2 + B.^2 + C.^2 + D.^2);
            n_val = max(sum(M, 2));
            return;
        end
    end

    % --- 3. NUMERIC-BASED NORM SELECTION ---
    if isnumeric(type)
        if type == 1
            % 1-NORM (Maximum absolute column sum)
            M = sqrt(A.^2 + B.^2 + C.^2 + D.^2);
            n_val = max(sum(M, 1));
            return;
            
        elseif type == 2
            % 2-NORM (Spectral Norm via Isomorphic Bifurcation)
            g = sqrt(abs(beta)); 
            
            % Spatial decoupling (Beta/G Projection)
            AS = A + g * C;   AD = A - g * C;
            BS = B + g * D;   BD = B - g * D;
            
            if alpha < 0
                % Elliptic/Complex Bifurcation
                z = sqrt(-alpha);
                TS = AS + (BS * z) * 1i;
                TD = AD + (BD * z) * 1i;
                n_val = max(norm(TS, 2), norm(TD, 2));
            else
                % Hyperbolic/Real Bifurcation
                z = sqrt(alpha);
                E_s1 = AS + z * BS;   E_s2 = AS - z * BS;
                E_d1 = AD + z * BD;   E_d2 = AD - z * BD;
                n_val = max([norm(E_s1, 2), norm(E_s2, 2), norm(E_d1, 2), norm(E_d2, 2)]);
            end
            return;
            
        elseif isinf(type)
            % INFINITY NORM
            M = sqrt(A.^2 + B.^2 + C.^2 + D.^2);
            n_val = max(sum(M, 2));
            return;
        end
    end

    error('abtessarine:norm:InvalidType', ...
          'Unknown norm type. Supported: ''topological'', ''fro'', 1, 2, inf.');
end