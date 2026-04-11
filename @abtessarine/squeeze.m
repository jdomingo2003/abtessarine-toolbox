function Z = squeeze(X)
% SQUEEZE Remove singleton dimensions from an abtessarine array.
%
%   Z = SQUEEZE(X) returns an abtessarine array Z with the same elements 
%   as X but with all the singleton dimensions (dimensions of length 1) 
%   removed. A 2-D array is returned unaffected unless it is a row or 
%   column vector, which remains a vector.
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - Zero-Overhead Dimensional Collapse: Squeezing is performed purely 
%     on the array's metadata (header modification in the C backend) 
%     without physically moving data blocks in RAM.
%
%   See also: RESHAPE, PERMUTE, NDIMS.

    % Delegate directly to the native engine
    Z = abtessarine(squeeze(X.A), ...
                    squeeze(X.B), ...
                    squeeze(X.C), ...
                    squeeze(X.D));
end