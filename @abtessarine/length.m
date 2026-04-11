function L = length(X)
% LENGTH Length of an abtessarine array.
%
%   L = length(X) returns the length of the largest array dimension in the 
%   abtessarine object X. For vectors, the length is simply the number 
%   of elements. For arrays with more dimensions, the length is strictly 
%   equivalent to max(size(X)).
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - O(1) Metadata Access: This function avoids any algebraic operations 
%     or memory allocations. It directly queries the dimensional metadata 
%     of the underlying real tensor (component A), guaranteeing 
%     instantaneous execution with zero overhead.
%
%   See also: SIZE, NDIMS.

    % Delegate the metadata query directly to the primary spatial plane
    L = length(X.A);
end