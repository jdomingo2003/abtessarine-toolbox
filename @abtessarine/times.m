function Z = times(X, Y)
% TIMES Overloads the element-wise multiplication operator (.*) for abtessarine.
%
%   Z = X .* Y computes the Hadamard product. Each element of the 
%   resulting matrix is the abtessarine product of the corresponding 
%   elements of X and Y.
%
%   ALGEBRAIC RULES:
%   The multiplication follows the basis rules: i^2 = alpha, j^2 = beta, 
%   k^2 = alpha*beta, ensuring the product remains within the 4D domain.
%
%   FEATURES:
%   - Full support for MATLAB's implicit expansion (broadcasting).
%   - Hybrid multiplication (numeric .* abtessarine).
%   - FLOP-optimized expansion of the Cayley table.

%   See also MTIMES, POWER, KRON.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:times:MissingEnvironment', ...
              'Algebraic environment undefined. Execute setabtessarine first.');
    end
    
    % --- 2. HYBRID OPERATION: Numeric .* abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Scalar/numeric scaling applied via native broadcasting
        Z = abtessarine(X .* Y.A, X .* Y.B, X .* Y.C, X .* Y.D);
        return;
    end
    
    % --- 3. HYBRID OPERATION: abtessarine .* Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % Linear scaling of all components
        Z = abtessarine(X.A .* Y, X.B .* Y, X.C .* Y, X.D .* Y);
        return;
    end
    
    % --- 4. CORE ALGEBRAIC PRODUCT: abtessarine .* abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        
        % Extraction for high-speed local access
        A1 = X.A; B1 = X.B; C1 = X.C; D1 = X.D;
        A2 = Y.A; B2 = Y.B; C2 = Y.C; D2 = Y.D;
        
        % Precomputation of the derived structural constant (k^2)
        ab = alpha * beta;
        
        % FLOP-optimized expansion of the hypercomplex product.
        % Each line corresponds to the projection onto the basis components.
        ZA = A1.*A2 + alpha*(B1.*B2) + beta*(C1.*C2) + ab*(D1.*D2);
        ZB = A1.*B2 + B1.*A2 + beta*(C1.*D2) + beta*(D1.*C2);
        ZC = A1.*C2 + alpha*(B1.*D2) + C1.*A2 + alpha*(D1.*B2);
        ZD = A1.*D2 + B1.*C2 + C1.*B2 + D1.*A2;
        
        % Resultant object synthesis
        Z = abtessarine(ZA, ZB, ZC, ZD);
        return;
    end
    
    % --- 5. EXCEPTION HANDLING ---
    error('abtessarine:times:InvalidInputTypes', ...
          'Element-wise multiplication requires abtessarine or numeric types.');
end