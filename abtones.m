function Z = abtones(varargin)
% ABTONES Create an abtessarine array of all ones.
%
%   Z = ABTONES(N) returns an N-by-N abtessarine matrix with ones in 
%   the real component (A) and zeros in the hypercomplex components 
%   (B, C, D), representing the multiplicative identity.
%   Z = ABTONES(SZ1, SZ2, ...) returns an array of ones with the 
%   specified dimensions.
%   Z = ABTONES(..., 'like', Y) returns an array of ones of the same 
%   underlying data type and complexity as the numeric array Y.
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - Native Allocation: Directly leverages MATLAB's highly optimized 
%     built-in 'ones' and 'zeros' functions for contiguous memory preallocation.
%   - Type-Safe Casting: Uses the 'like' directive internally to guarantee 
%     that GPU arrays (gpuArray), single precision, or distributed arrays 
%     are preserved strictly across the entire hypercomplex manifold without 
%     implicit memory transfers.
%
%   See also: ABTESSARINE, ONES, ZEROS.

    % Generate the real component (A) filled with ones using native varargin expansion
    A = ones(varargin{:});
    
    % Generate the hypercomplex components (B, C, D) filled with zeros.
    % Utilizing zeros(size(A), 'like', A) ensures zero-overhead type and 
    % hardware location matching (e.g., keeping data on the GPU if A is a gpuArray).
    Z = abtessarine(A, ...
                    zeros(size(A), 'like', A), ...
                    zeros(size(A), 'like', A), ...
                    zeros(size(A), 'like', A));
end