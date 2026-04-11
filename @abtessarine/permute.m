function Z = permute(X, order)
% PERMUTE Rearrange dimensions of an abtessarine array.
%
%   Z = PERMUTE(X, ORDER) rearranges the dimensions of the abtessarine 
%   array X so that they are in the order specified by the vector ORDER.
%   The resulting array has size Z_size = size(X)(ORDER).
%
%   ALGORITHMIC OPTIMIZATIONS FOR HPC:
%   - Memory Re-stride Delegation: Bypasses explicit memory copying where 
%     possible by delegating the multidimensional re-ordering directly to 
%     MATLAB's native C/C++ memory management engine across all four 
%     hypercomplex planes simultaneously.
%
%   See also: CTRANSPOSE, TRANSPOSE, RESHAPE, SQUEEZE.

    % Ensure order vector is provided and numeric
    if nargin < 2 || ~isnumeric(order)
        error('abtessarine:permute:InvalidOrder', ...
              'ORDER must be a numeric vector specifying the new dimension arrangement.');
    end

    % Delegate directly to the native engine
    Z = abtessarine(permute(X.A, order), ...
                    permute(X.B, order), ...
                    permute(X.C, order), ...
                    permute(X.D, order));
end