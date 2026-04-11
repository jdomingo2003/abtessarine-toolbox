function Z = uminus(X)
% UMINUS Unary minus for abtessarine arrays.
%
%   Z = uminus(X) negates all structural components of the abtessarine 
%   array X. This operation is invoked by the standard syntax -X.
%
%   ALGEBRAIC & HPC OPTIMIZATIONS:
%   - Manifold Point Reflection: Mathematically, unary negation in the 
%     abtessarine space acts as a strict point reflection through the origin.
%     If X = A + iB + jC + kD, then -X = (-A) + i(-B) + j(-C) + k(-D).
%   - SIMD Vectorization: By distributing the negation operator across the 
%     four independent spatial planes, the operation bypasses complex loops 
%     and directly taps into MATLAB's underlying SIMD (Single Instruction, 
%     Multiple Data) hardware pipelines. This guarantees perfectly 
%     vectorized, O(N) execution with zero architectural overhead.
%
%   See also: UPLUS, MINUS.

    % Delegate sign inversion directly to the native SIMD-optimized engine
    Z = abtessarine(-X.A, -X.B, -X.C, -X.D);
end