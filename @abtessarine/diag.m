function D = diag(V)
% DIAG Extracts the main diagonal or constructs a diagonal abtessarine matrix.
%
%   D = diag(V) inherently overloads the native MATLAB diagonal manipulation 
%   function. If V is a 2D abtessarine matrix (or a 2D array of scalar objects), 
%   it returns a column vector comprising the principal diagonal elements. 
%   Conversely, if V is a 1D abtessarine vector, it constructs and returns 
%   a strictly square diagonal matrix.
%
%   This operation is purely structural and operates independently of the 
%   algebraic environment's global parameters (alpha, beta).

%   See also TRACE, SVD.

    % --- 1. MULTIDIMENSIONAL OBJECT ARRAY HANDLING ---
    % If the user initialized an array of individual abtessarine objects instead 
    % of a single object containing matrices, V.A returns a comma-separated list.
    % We concatenate and reshape them into standard numeric matrices first.
    if ~isscalar(V)
        sz = size(V);
        compA = diag(reshape([V.A], sz));
        compB = diag(reshape([V.B], sz));
        compC = diag(reshape([V.C], sz));
        compD = diag(reshape([V.D], sz));
        
        D = abtessarine(compA, compB, compC, compD);
        return;
    end

    % --- 2. SCALAR OBJECT (MATRIX COMPONENTS) HANDLING ---
    % Extract or allocate the principal diagonal for each constituent component 
    % utilizing native MATLAB optimizations.
    compA = diag(V.A);
    compB = diag(V.B);
    compC = diag(V.C);
    compD = diag(V.D);
    
    % --- 3. DIRECT MEMORY ALLOCATION ---
    % Reconstruct and return the resulting single abtessarine object.
    D = abtessarine(compA, compB, compC, compD);
end