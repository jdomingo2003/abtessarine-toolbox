function Z = cat(dim, varargin)
% CAT Concatenate abtessarine arrays along a specified dimension.
%
%   Z = CAT(DIM, A, B) concatenates the abtessarine arrays A and B 
%   along the dimension specified by DIM.
%   Z = CAT(DIM, A1, A2, A3, ...) concatenates all input arrays.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Native Multilinear Delegation: The algorithm unpacks hypercomplex planes 
%     and strictly delegates to the C-compiled 'cat' via MATLAB's 'builtin' 
%     function. This guarantees absolute bypass of OOP dispatching overhead 
%     and prevents recursive shadowing issues.
%   - Dynamic Type Coercion & CoW: Real numeric arrays mixed with abtessarine 
%     objects are coerced into the manifold natively, mapping imaginary planes 
%     to a single CoW zero-block to conserve L1/L2 cache.

%  See also HORZCAT, VERTCAT, REPMAT.

    % Ensure the dimension argument is valid to prevent built-in errors
    if isempty(dim) || ~isnumeric(dim) || ~isscalar(dim)
        error('Dimension argument must be a positive integer scalar.');
    end

    % Number of arrays to concatenate
    N = nargin - 1; 
    
    % Preallocate cell arrays for maximum extraction speed
    Ac = cell(1, N);
    Bc = cell(1, N);
    Cc = cell(1, N);
    Dc = cell(1, N);
    
    for k = 1:N
        item = varargin{k};
        
        if isa(item, 'abtessarine')
            Ac{k} = item.A;
            Bc{k} = item.B;
            Cc{k} = item.C;
            Dc{k} = item.D;
        else
            % Type Coercion: Real numeric array to abtessarine mapping
            Ac{k} = double(item);
            
            % Generate a single zero-block for CoW memory savings
            sz = size(item);
            z = zeros(sz);
            Bc{k} = z;
            Cc{k} = z;
            Dc{k} = z;
        end
    end
    
    % Delegate to the native C-engine using 'builtin' to prevent shadowing
    Z = abtessarine(builtin('cat', dim, Ac{:}), ...
                    builtin('cat', dim, Bc{:}), ...
                    builtin('cat', dim, Cc{:}), ...
                    builtin('cat', dim, Dc{:}));
end