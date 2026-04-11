function Z = repmat(X, varargin)
% REPMAT Replicate and tile an abtessarine array.
%
%   Z = REPMAT(X, N) creates a large abtessarine array consisting of an 
%   N-by-N tiling of copies of X. 
%   Z = REPMAT(X, M, N) creates a tiling of copies of X with M row copies 
%   and N column copies.
%   Z = REPMAT(X, [M N P ...]) tiles the array X to produce a 
%   multidimensional array.
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - Contiguous Memory Preallocation: Delegates the tiling operation to 
%     the native backend, ensuring that the heavy memory block copies 
%     (memcpy) are executed at the lowest possible level in C/Fortran.
%
%   See also: RESHAPE, KRON, CAT, SQUEEZE.

    % Delegate directly using varargin expansion for flexible argument handling
    Z = abtessarine(repmat(X.A, varargin{:}), ...
                    repmat(X.B, varargin{:}), ...
                    repmat(X.C, varargin{:}), ...
                    repmat(X.D, varargin{:}));
end