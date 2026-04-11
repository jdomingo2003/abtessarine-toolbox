function Z = kron(X, Y)
% KRON Kronecker tensor product for gabtessarine matrices.
%
%   Z = KRON(X, Y) computes the block Kronecker expansion of two 
%   8D hypercomplex arrays. It strictly preserves the topological 
%   parameters and the complexified dual rules (epsilon^2 = -1).
%
%   IMPLEMENTATION STRATEGY:
%   - Hybrid Support: Handles numeric-hypercomplex operations natively.
%   - Automatic Domain Promotion: 'abtessarine' (4D) objects are dynamically 
%     upcast to 'gabtessarine' (8D) to avoid structural crashing.
%   - FLOP-Optimized Core: Algebraically unrolls the 64 sub-block tensor 
%     products to maximize throughput and bypass object-creation overhead.

%   See also TIMES, MTIMES.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('gabtessarine:kron:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    end

    % --- 2. HYBRID: NUMERIC ARRAY (X) * GABTESSARINE (Y) ---
    if isnumeric(X) && isa(Y, 'gabtessarine')
        Z = gabtessarine(kron(X, Y.A1), kron(X, Y.A2), ...
                         kron(X, Y.B1), kron(X, Y.B2), ...
                         kron(X, Y.C1), kron(X, Y.C2), ...
                         kron(X, Y.D1), kron(X, Y.D2));
        return;
    end
    
    % --- 3. HYBRID: GABTESSARINE (X) * NUMERIC ARRAY (Y) ---
    if isa(X, 'gabtessarine') && isnumeric(Y)
        Z = gabtessarine(kron(X.A1, Y), kron(X.A2, Y), ...
                         kron(X.B1, Y), kron(X.B2, Y), ...
                         kron(X.C1, Y), kron(X.C2, Y), ...
                         kron(X.D1, Y), kron(X.D2, Y));
        return;
    end

    % --- 4. DYNAMIC UPCASTING (4D to 8D) ---
    if isa(X, 'abtessarine')
        zX = zeros(size(X.A));
        X = gabtessarine(X.A, zX, X.B, zX, X.C, zX, X.D, zX);
    end
    if isa(Y, 'abtessarine')
        zY = zeros(size(Y.A));
        Y = gabtessarine(Y.A, zY, Y.B, zY, Y.C, zY, Y.D, zY);
    end

    % --- 5. CORE KRONECKER: 8D * 8D ---
    if isa(X, 'gabtessarine') && isa(Y, 'gabtessarine')
        
        % Memory extraction to L1 for rapid block processing
        % Index 1 = Real/Primary component, Index 2 = Epsilon component
        XA1 = X.A1; XA2 = X.A2; XB1 = X.B1; XB2 = X.B2;
        XC1 = X.C1; XC2 = X.C2; XD1 = X.D1; XD2 = X.D2;
        
        YA1 = Y.A1; YA2 = Y.A2; YB1 = Y.B1; YB2 = Y.B2;
        YC1 = Y.C1; YC2 = Y.C2; YD1 = Y.D1; YD2 = Y.D2;
        
        % Precompute structural cross-coupling constant
        ab = alpha * beta;
        
        % --- PRIMARY COMPONENTS (Real structural parts) ---
        % Governed by standard Cayley rules and the epsilon^2 = -1 identity.
        ZA1 = kron(XA1, YA1) - kron(XA2, YA2) + alpha * kron(XB1, YB1) - alpha * kron(XB2, YB2) + ...
              beta * kron(XC1, YC1) - beta * kron(XC2, YC2) + ab * kron(XD1, YD1) - ab * kron(XD2, YD2);
              
        ZB1 = kron(XA1, YB1) - kron(XA2, YB2) + kron(XB1, YA1) - kron(XB2, YA2) + ...
              beta * kron(XC1, YD1) - beta * kron(XC2, YD2) + beta * kron(XD1, YC1) - beta * kron(XD2, YC2);
              
        ZC1 = kron(XA1, YC1) - kron(XA2, YC2) + alpha * kron(XB1, YD1) - alpha * kron(XB2, YD2) + ...
              kron(XC1, YA1) - kron(XC2, YA2) + alpha * kron(XD1, YB1) - alpha * kron(XD2, YB2);
              
        ZD1 = kron(XA1, YD1) - kron(XA2, YD2) + kron(XB1, YC1) - kron(XB2, YC2) + ...
              kron(XC1, YB1) - kron(XC2, YB2) + kron(XD1, YA1) - kron(XD2, YA2);
              
        % --- DUAL/EPSILON COMPONENTS (Complexified parts) ---
        % Cross-terms originating from the linear combination with epsilon.
        ZA2 = kron(XA1, YA2) + kron(XA2, YA1) + alpha * kron(XB1, YB2) + alpha * kron(XB2, YB1) + ...
              beta * kron(XC1, YC2) + beta * kron(XC2, YC1) + ab * kron(XD1, YD2) + ab * kron(XD2, YD1);
              
        ZB2 = kron(XA1, YB2) + kron(XA2, YB1) + kron(XB1, YA2) + kron(XB2, YA1) + ...
              beta * kron(XC1, YD2) + beta * kron(XC2, YD1) + beta * kron(XD1, YC2) + beta * kron(XD2, YC1);
              
        ZC2 = kron(XA1, YC2) + kron(XA2, YC1) + alpha * kron(XB1, YD2) + alpha * kron(XB2, YD1) + ...
              kron(XC1, YA2) + kron(XC2, YA1) + alpha * kron(XD1, YB2) + alpha * kron(XD2, YB1);
              
        ZD2 = kron(XA1, YD2) + kron(XA2, YD1) + kron(XB1, YC2) + kron(XB2, YC1) + ...
              kron(XC1, YB2) + kron(XC2, YB1) + kron(XD1, YA2) + kron(XD2, YA1);
        
        % Result object synthesis
        Z = gabtessarine(ZA1, ZA2, ZB1, ZB2, ZC1, ZC2, ZD1, ZD2);
        return;
    end
    
    % --- 6. EXCEPTION HANDLING ---
    error('gabtessarine:kron:InvalidTypes', ...
          'Kronecker product requires numeric, abtessarine, or gabtessarine objects.');
end