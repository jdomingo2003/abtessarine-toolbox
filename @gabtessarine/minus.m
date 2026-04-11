function Z = minus(X, Y)
% MINUS Overloads the subtraction operator (-) for gabtessarine objects.
%
%   Z = X - Y computes the element-wise difference between arrays.
%
%   IMPLEMENTATION STRATEGY:
%   This function supports hybrid operations across the dimensional hierarchy
%   (2D Numeric, 4D abtessarine, and 8D gabtessarine). Lower-dimensional 
%   operands are implicitly promoted to 8D. To maximize computational 
%   throughput, structural zeros from lower-dimensional objects are bypassed, 
%   and negations are injected directly into the memory allocator.

%   See also UMINUS, PLUS.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    alpha = getabtessarine();
    
    if isempty(alpha)
        error('gabtessarine:minus:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    elseif alpha <= 0
        error('gabtessarine:minus:InvalidAlpha', ...
              'Mathematical constraint violation: Operations in the 8D gabtessarine algebra are strictly defined for alpha > 0.');
    end

    % --- 2. HYBRID: NUMERIC (2D) - GABTESSARINE (8D) ---
    if isnumeric(X) && isa(Y, 'gabtessarine')
        % Implicit promotion of X. Direct negation for Y's epsilon and hypercomplex parts.
        Z = gabtessarine(X - Y.A1, -Y.A2, -Y.B1, -Y.B2, -Y.C1, -Y.C2, -Y.D1, -Y.D2);
        return;
    end
    
    % --- 3. HYBRID: GABTESSARINE (8D) - NUMERIC (2D) ---
    if isa(X, 'gabtessarine') && isnumeric(Y)
        % Implicit promotion of Y.
        Z = gabtessarine(X.A1 - Y, X.A2, X.B1, X.B2, X.C1, X.C2, X.D1, X.D2);
        return;
    end

    % --- 4. HIERARCHICAL: ABTESSARINE (4D) - GABTESSARINE (8D) ---
    if isa(X, 'abtessarine') && isa(Y, 'gabtessarine')
        % X lacks epsilon parts (A2, B2, C2, D2), so 0 - Y.x2 directly yields -Y.x2
        Z = gabtessarine(X.A - Y.A1, -Y.A2, X.B - Y.B1, -Y.B2, X.C - Y.C1, -Y.C2, X.D - Y.D1, -Y.D2);
        return;
    end
    
    % --- 5. HIERARCHICAL: GABTESSARINE (8D) - ABTESSARINE (4D) ---
    if isa(X, 'gabtessarine') && isa(Y, 'abtessarine')
        % Y lacks epsilon parts, so X.x2 - 0 directly yields X.x2
        Z = gabtessarine(X.A1 - Y.A, X.A2, X.B1 - Y.B, X.B2, X.C1 - Y.C, X.C2, X.D1 - Y.D, X.D2);
        return;
    end

    % --- 6. CORE ALGEBRAIC DIFFERENCE: 8D - 8D ---
    if isa(X, 'gabtessarine') && isa(Y, 'gabtessarine')
        % Direct element-wise subtraction of all 8 components
        Z = gabtessarine(X.A1 - Y.A1, X.A2 - Y.A2, X.B1 - Y.B1, X.B2 - Y.B2, ...
                         X.C1 - Y.C1, X.C2 - Y.C2, X.D1 - Y.D1, X.D2 - Y.D2);
        return;
    end
    
    % --- 7. EXCEPTION HANDLING ---
    error('gabtessarine:minus:InvalidTypes', ...
          'Incompatible types for subtraction. Operands must be numeric, abtessarine, or gabtessarine.');
end