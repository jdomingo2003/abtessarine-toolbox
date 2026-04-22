function x = abt2gabt(x1, x2)
% ABT2GABT Constructs a generalized abtessarine (8D) from 4D abtessarine objects.
%   X = abt2gabt(X1, X2) creates an 8D hypercomplex matrix using the
%   Cayley-Dickson construction form: X = X1 + X2 * epsilon.
%
%   If X2 is not provided, it pads the secondary 4D components with zeros,
%   safely promoting the 4D object to the 8D space.
%
%   See also gabtessarine, abtessarine.

    % 1. Argument handling (Allow promotion from 4D to 8D with a single input)
    if nargin < 2
        if isa(x1, 'abtessarine')
            x2 = abtessarine(zeros(size(x1.A)), zeros(size(x1.A)), ...
                             zeros(size(x1.A)), zeros(size(x1.A)));
        else
            error('abt2gabt:InvalidInput', 'Input must be an abtessarine object.');
        end
    end

    % 2. Strict type verification
    if ~(isa(x1, 'abtessarine') && isa(x2, 'abtessarine'))
        error('abt2gabt:InvalidType', 'Both inputs must be abtessarine objects.');
    end

    % 3. Dimension verification
    if ~isequal(size(x1.A), size(x2.A))
        error('abt2gabt:DimensionMismatch', 'Matrix dimensions of x1 and x2 must agree.');
    end

    % 4. Direct memory assembly (Mapping to the 8D class)
    % x1 provides the primary components (1, 3, 5, 7) internally A1, B1, C1, D1
    % x2 provides the secondary components (2, 4, 6, 8) internally A2, B2, C2, D2
    x = gabtessarine(x1.A, x2.A, x1.B, x2.B, x1.C, x2.C, x1.D, x2.D);
    
end