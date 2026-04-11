function Z = plus(X, Y)
% PLUS Overloads the addition operator (+) for gabtessarine objects.
%
%   Z = X + Y computes the element-wise addition between arrays.
%
%   IMPLEMENTATION STRATEGY:
%   This function implements High-Performance "Implicit Upcasting". It supports 
%   hybrid addition across the dimensional hierarchy (2D Numeric, 4D abtessarine, 
%   and 8D gabtessarine). To maximize computational throughput and minimize 
%   L1 cache misses, structural zeros from lower-dimensional operands are 
%   mathematically bypassed. The addition is applied exclusively to the active 
%   isomorphic components, while orthogonal dimensions are directly reallocated.

%   See also MINUS, UMINUS.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    alpha = getabtessarine();
    
    if isempty(alpha)
        error('gabtessarine:plus:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    elseif alpha <= 0
        error('gabtessarine:plus:InvalidAlpha', ...
              'Mathematical constraint violation: Operations in the 8D gabtessarine algebra are strictly defined for alpha > 0.');
    end

    % --- 2. HYBRID: NUMERIC (2D) + GABTESSARINE (8D) ---
    if isnumeric(X) && isa(Y, 'gabtessarine')
        % Only the fundamental real part (A1) intersects with the numeric domain.
        Z = gabtessarine(X + Y.A1, Y.A2, Y.B1, Y.B2, Y.C1, Y.C2, Y.D1, Y.D2);
        return;
    end
    
    % --- 3. HYBRID: GABTESSARINE (8D) + NUMERIC (2D) ---
    if isa(X, 'gabtessarine') && isnumeric(Y)
        Z = gabtessarine(X.A1 + Y, X.A2, X.B1, X.B2, X.C1, X.C2, X.D1, X.D2);
        return;
    end

    % --- 4. HIERARCHICAL: ABTESSARINE (4D) + GABTESSARINE (8D) ---
    if isa(X, 'abtessarine') && isa(Y, 'gabtessarine')
        % X lacks the epsilon-complexifications (A2, B2, C2, D2).
        % Those components are directly inherited from Y without adding zero.
        Z = gabtessarine(X.A + Y.A1, Y.A2, X.B + Y.B1, Y.B2, X.C + Y.C1, Y.C2, X.D + Y.D1, Y.D2);
        return;
    end
    
    % --- 5. HIERARCHICAL: GABTESSARINE (8D) + ABTESSARINE (4D) ---
    if isa(X, 'gabtessarine') && isa(Y, 'abtessarine')
        Z = gabtessarine(X.A1 + Y.A, X.A2, X.B1 + Y.B, X.B2, X.C1 + Y.C, X.C2, X.D1 + Y.D, X.D2);
        return;
    end

    % --- 6. CORE ALGEBRAIC ADDITION: 8D + 8D ---
    if isa(X, 'gabtessarine') && isa(Y, 'gabtessarine')
        % Full parallel element-wise addition across the 8-dimensional manifold
        Z = gabtessarine(X.A1 + Y.A1, X.A2 + Y.A2, X.B1 + Y.B1, X.B2 + Y.B2, ...
                         X.C1 + Y.C1, X.C2 + Y.C2, X.D1 + Y.D1, X.D2 + Y.D2);
        return;
    end
    
    % --- 7. EXCEPTION HANDLING ---
    error('gabtessarine:plus:InvalidTypes', ...
          'Incompatible types for addition. Operands must be numeric, abtessarine, or gabtessarine.');
end