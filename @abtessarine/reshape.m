function Z = reshape(X, varargin)
% RESHAPE Reshape an abtessarine array.
%
%   Z = reshape(X, M, N, P, ...) returns an N-D abtessarine array with the 
%   same total number of elements as X but reshaped to have the size 
%   M-by-N-by-P-by-.... The product of the specified dimensions must be 
%   the same as numel(X).
%
%   Z = reshape(X, SZ) where SZ is a vector inherently defines the target 
%   size.
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - Bypasses intermediate loop structures by delegating the multi-
%     dimensional reshaping directly to MATLAB's native C/C++ memory 
%     reallocation engine (varargin unpacking).
%
%   See also: SQUEEZE, PERMUTE, REPMAT, SIZE.

    % --- 1. DELEGATION TO NATIVE ENGINE ---
    % Directly applies the spatial reshaping mapping to all four 
    % topological components simultaneously.
    Z = abtessarine(reshape(X.A, varargin{:}), ...
                    reshape(X.B, varargin{:}), ...
                    reshape(X.C, varargin{:}), ...
                    reshape(X.D, varargin{:}));
end