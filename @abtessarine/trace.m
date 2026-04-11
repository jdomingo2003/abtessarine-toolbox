function t = trace(V)
% TRACE Sum of diagonal elements for abtessarine objects.
%
%   T = TRACE(X) returns the sum of the diagonal elements of the 
%   abtessarine matrix X as an abtessarine scalar.
%
%   MATHEMATICAL PRINCIPLE:
%   The trace is a linear operator. For any abtessarine matrix 
%   X = A + iB + jC + kD, the trace is defined as:
%   Tr(X) = Tr(A) + iTr(B) + jTr(C) + kTr(D).
%
%   This implementation leverages the native MATLAB trace function for each 
%   component to ensure maximum numerical precision and speed.

%   See also DET, DIAG, EIG.

    % --- 1. LINEAR COMPONENT EXTRACTION ---
    % Apply native trace to each structural array.
    % This handles square and non-square matrices according to MATLAB's 
    % standard behavior (though trace is typically for square matrices).
    trA = trace(V.A);
    trB = trace(V.B);
    trC = trace(V.C);
    trD = trace(V.D);
    
    % --- 2. SCALAR RECONSTRUCTION ---
    % Encapsulate the resulting sums into a single abtessarine scalar.
    t = abtessarine(trA, trB, trC, trD);
    
end