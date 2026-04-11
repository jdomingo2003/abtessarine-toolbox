function x = buildgabt(x1, x2)
% BUILDGABT Constructs a generalized abtessarine (8D) from two abtessarine (4D) objects.
%   X = BUILDGABT(X1, X2) creates an 8D hypercomplex matrix using the
%   Cayley-Dickson construction form: X = X1 + X2 * epsilon, where epsilon^2 = -1.
%
%   Inputs:
%       X1 - An object of class @abtessarine representing the primary 4D components.
%       X2 - An object of class @abtessarine representing the secondary (Cayley) 4D components.
%
%   Outputs:
%       X  - An object of class @gabtessarine representing the assembled 8D matrix.
%
%   See also: GABTESSARINE, ABTESSARINE, GABTZEROS, GABTEYE.

    % 1. FAST TYPE CHECKING
    if ~(isa(x1, 'abtessarine') && isa(x2, 'abtessarine'))
        error('gabtessarine:buildgabt:InvalidInputs', ...
              'Both inputs must be abtessarine objects.');
    end
    % 2. DIMENSION MATCHING (Optional but recommended for matrix safety)
    if ~isequal(size(x1.A), size(x2.A))
        error('gabtessarine:buildgabt:DimensionMismatch', ...
              'Matrix dimensions of x1 and x2 must agree.');
    end
    % 3. DIRECT MEMORY ASSEMBLY (Zero-overhead mapping)
    % Maps: x1 -> Primary components (1), x2 -> Cayley/Epsilon components (2)
    x = gabtessarine(x1.A, x2.A, x1.B, x2.B, x1.C, x2.C, x1.D, x2.D);
    
end