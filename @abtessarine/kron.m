function Z = kron(X, Y)
% KRON Kronecker tensor product for abtessarine matrices.
%
%   Z = kron(X, Y) computes the Kronecker product of two abtessarine 
%   arrays, resulting in a large block matrix that preserves the 
%   topological properties of the algebraic space.
%
%   MATHEMATICAL OVERVIEW:
%   The function expands the 4D hypercomplex product through the tensor 
%   space. Given the basis {1, i, j, k}, the product Z = X ⊗ Y is 
%   partitioned into four fundamental components (A, B, C, D) by 
%   distributing the Kronecker operator over the algebraic multiplication 
%   rules defined by alpha and beta.
%
%   COMPUTATIONAL EFFICIENCY:
%   To minimize overhead, this implementation uses direct component 
%   extraction and pre-calculated algebraic constants, avoiding 
%   repetitive property lookups and maximizing cache locality for 
%   large-scale tensor expansions.

%   See also TIMES, MTIMES, REPMAT.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:kron:MissingEnvironment', ...
              'Global environment parameters are undefined. Run setabtessarine.');
    end

    % --- 2. HYBRID KRONECKER: Numeric * abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Scalar/Matrix expansion across all hypercomplex components
        Z = abtessarine(kron(X, Y.A), kron(X, Y.B), kron(X, Y.C), kron(X, Y.D));
        return;
    end
    
    % --- 3. HYBRID KRONECKER: abtessarine * Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % abtessarine expansion across a numeric tensor space
        Z = abtessarine(kron(X.A, Y), kron(X.B, Y), kron(X.C, Y), kron(X.D, Y));
        return;
    end

    % --- 4. CORE KRONECKER: abtessarine * abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        
        % Direct component extraction to prevent indexing overhead
        A1 = X.A; B1 = X.B; C1 = X.C; D1 = X.D;
        A2 = Y.A; B2 = Y.B; C2 = Y.C; D2 = Y.D;
        
        % Algebraic constant pre-calculation (k^2 = alpha * beta)
        ab = alpha * beta;
        
        % FLOP-optimized Kronecker expansion based on hypercomplex rules:
        % ZA: (1*1), (i*i), (j*j), (k*k)
        ZA = kron(A1, A2) + alpha .* kron(B1, B2) + beta .* kron(C1, C2) + ab .* kron(D1, D2);
        
        % ZB: (1*i), (i*1), (j*k), (k*j)
        ZB = kron(A1, B2) + kron(B1, A2) + beta .* kron(C1, D2) + beta .* kron(D1, C2);
        
        % ZC: (1*j), (i*k), (j*1), (k*i)
        ZC = kron(A1, C2) + alpha .* kron(B1, D2) + kron(C1, A2) + alpha .* kron(D1, B2);
        
        % ZD: (1*k), (i*j), (j*i), (k*1)
        ZD = kron(A1, D2) + kron(B1, C2) + kron(C1, B2) + kron(D1, A2);
        
        % Resultant object construction via direct injection
        Z = abtessarine(ZA, ZB, ZC, ZD);
        return;
    end
    
    % --- 5. TYPE VALIDATION SHIELD ---
    error('abtessarine:kron:InvalidTypes', ...
          'Kronecker product is only defined between abtessarine objects or compatible numeric types.');
end