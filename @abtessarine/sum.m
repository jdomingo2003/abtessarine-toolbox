function Y = sum(X, varargin)
% SUM Overloads the sum function for abtessarine objects.
%
%   Y = SUM(X) sums the elements of X along the first non-singleton dimension.
%   Y = SUM(X, DIM) sums along the dimension DIM.
%   Y = SUM(X, 'all') sums all elements into a single abtessarine scalar.
%
%   COMPUTATIONAL STRATEGY:
%   The abtessarine sum is a topologically independent operation, meaning 
%   it is strictly component-wise. This implementation maximizes efficiency 
%   by delegating the heavy vectorization to MATLAB's native C-engine. 
%   By passing all extra arguments (DIM, 'all', 'omitnan') directly via 
%   varargin, we ensure 100% compatibility with standard MATLAB syntax 
%   without additional overhead.

%   See also PROD, DIFF, PLUS.

    % --- 1. HANDLING DEFAULT BEHAVIOR ---
    if isempty(varargin)
        % Replicate MATLAB's logic for finding the first non-singleton dimension.
        % This ensures X(1xN) sums to a scalar and NxM sums to a 1xM row.
        dim = find(size(X.A) > 1, 1);
        if isempty(dim)
            dim = 1; 
        end
        
        sA = sum(X.A, dim);
        sB = sum(X.B, dim);
        sC = sum(X.C, dim);
        sD = sum(X.D, dim);
    else
        % --- 2. ADVANCED ARGUMENT DELEGATION ---
        % Supports 'all', 'omitnan', and specific dimensions by piping 
        % varargin directly to the native sum function.
        sA = sum(X.A, varargin{:});
        sB = sum(X.B, varargin{:});
        sC = sum(X.C, varargin{:});
        sD = sum(X.D, varargin{:});
    end
    
    % --- 3. RECONSTRUCTION ---
    % Encapsulate the resulting matrices into a new abtessarine instance.
    Y = abtessarine(sA, sB, sC, sD);
    
end