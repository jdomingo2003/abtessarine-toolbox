function Z_out = transpose(X)
% TRANSPOSE Non-conjugate (simple) transpose for abtessarine objects.
%
%   Z = X.' performs the simple transpose of the abtessarine matrix X.
%
%   ALGORITHMIC ARCHITECTURE:
%   This function overloads the dot-transpose operator (.') by applying 
%   the native MATLAB transpose to each of the four internal components 
%   (A, B, C, D) independently. 
%
%   Unlike CTRANSPOSE ('), this operation does NOT apply algebraic 
%   conjugation to the hypercomplex units (i, j, k). It is a purely 
%   geometric reordering of the array elements, maintaining O(1) memory 
%   efficiency for large-scale matrices.

%   See also CTRANSPOSE, PERMUTE, HERMITIAN.

    % Direct instantiation using native transpose on all components.
    % The use of .' on sub-blocks ensures that even if components 
    % were complex-valued (which they shouldn't be in this 4D model), 
    % the operation remains a simple transpose.
    Z_out = abtessarine(X.A.', X.B.', X.C.', X.D.');
    
end