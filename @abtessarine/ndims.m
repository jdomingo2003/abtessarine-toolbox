function n = ndims(X)
% NDIMS Number of dimensions of an abtessarine array.
%
%   n = NDIMS(X) returns the number of dimensions in the abtessarine 
%   array X. The number of dimensions is always greater than or equal 
%   to 2 (e.g., a scalar or vector still has 2 dimensions).
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - O(1) Metadata Access: Bypasses implicit calls to size() by directly 
%     querying the precomputed metadata of the primary spatial plane (A).
%     Ensures zero-overhead tensor rank evaluation.
%
%   See also: SIZE, LENGTH.

    % Delegate the dimension count directly to the primary spatial plane
    n = ndims(X.A);
end