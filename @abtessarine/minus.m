function Z = minus(X, Y)
% MINUS Overloads the subtraction operator (-) for abtessarine objects.
%
%   Z = X - Y performs element-wise subtraction. This implementation 
%   minimizes computational overhead by delegating vectorization and 
%   scalar expansion to MATLAB's native optimized engine.
%
%   ALGORITHMIC STRATEGY:
%   The function handles hybrid subtraction through domain promotion. 
%   When subtracting a numeric type from an abtessarine (or vice versa), 
%   the operation only affects the principal real component (A), while 
%   the hypercomplex components (B, C, D) are either preserved or 
%   inverted using native unary operators to ensure maximum RAM efficiency.

%   See also PLUS, UMINUS, DIFF.

    % --- 1. HYBRID SUBTRACTION: Numeric - abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Subtract the real part. The imaginary components are sign-inverted 
        % utilizing MATLAB's low-level unary minus for high performance.
        Z = abtessarine(X - Y.A, -Y.B, -Y.C, -Y.D);
        return;
    end
    
    % --- 2. HYBRID SUBTRACTION: abtessarine - Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % Only the 'A' component is modified. Hypercomplex components 
        % are passed by reference without triggering redundant memory copies.
        Z = abtessarine(X.A - Y, X.B, X.C, X.D);
        return;
    end

    % --- 3. CORE SUBTRACTION: abtessarine - abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        % Pure component-wise subtraction. Dimensional compatibility checks 
        % are handled by the native engine, avoiding manual overhead.
        Z = abtessarine(X.A - Y.A, X.B - Y.B, X.C - Y.C, X.D - Y.D);
        return;
    end
    
    % --- 4. TYPE VALIDATION SHIELD ---
    error('abtessarine:minus:InvalidTypes', ...
          'The minus operator is restricted to abtessarine objects and compatible numeric types.');
end