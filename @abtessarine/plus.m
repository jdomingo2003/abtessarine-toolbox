function Z = plus(X, Y)
% PLUS Overloads the addition operator (+) for abtessarine objects.
%
%   Z = X + Y performs element-wise addition. This implementation is 
%   optimized to leverage MATLAB's native vectorized engine, ensuring 
%   minimal memory overhead and supporting implicit scalar expansion.
%
%   The operation follows the algebraic definition where numeric scalars 
%   or arrays only interact with the real component (A) of the tessarine 
%   structure, while addition between abtessarine objects is performed 
%   component-wise across the basis {1, i, j, k}.

%   See also MINUS, UPLUS, SUM.

    % --- 1. OPERATION: NUMERIC (Scalar/Array) + abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Numeric interaction is restricted to the primary real component (A)
        % leveraging native broadcasting for high performance.
        Z = abtessarine(X + Y.A, Y.B, Y.C, Y.D);
        return;
    end
    
    % --- 2. OPERATION: abtessarine + NUMERIC (Scalar/Array) ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % Numeric interaction is restricted to the primary real component (A)
        % leveraging native broadcasting for high performance.
        Z = abtessarine(X.A + Y, X.B, X.C, X.D);
        return;
    end

    % --- 3. OPERATION: abtessarine + abtessarine (Component-wise) ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        % Direct component injection to minimize intermediate memory allocation.
        % This approach avoids redundant data copies during large-scale operations.
        Z = abtessarine(X.A + Y.A, X.B + Y.B, X.C + Y.C, X.D + Y.D);
        return;
    end
    
    % --- 4. EXCEPTION HANDLING ---
    error('abtessarine:plus:InvalidInputTypes', ...
          'Algebraic error: Addition is only defined for abtessarine objects and numeric arrays.');
end