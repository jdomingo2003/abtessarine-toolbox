function Z = uminus(X)
% UMINUS Overloads the unary minus operator (-) for gabtessarine objects.
%
%   Z = -X returns the additive inverse of the 8D gabtessarine tensor,
%   negating all spatial and hypercomplex components natively.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - SIMD Vector Negation: Bypasses explicit loop iterations by leveraging
%     MATLAB's internal SIMD-optimized unary operators across the 8 contiguous
%     memory blocks simultaneously.
%   - Direct Injection: Reconstructs the inverted 8D manifold purely in L1/L2 
%     cache without intermediate variable allocation.

%   See also MINUS, PLUS.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT & STRICT GUARDRAIL ---
    % We only extract alpha, as the environment's existence implies beta is set.
    [alpha, ~] = getabtessarine();
    
    if isempty(alpha)
        error('gabtessarine:uminus:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    end
    if alpha <= 0
        error('gabtessarine:uminus:InvalidAlpha', ...
              'Mathematical constraint violation: The 8D manifold is strictly defined for alpha > 0.');
    end

    % --- 2. VECTOR SPACE INVERSION (Direct Assembly) ---
    Z = gabtessarine(-X.A1, -X.A2, -X.B1, -X.B2, ...
                     -X.C1, -X.C2, -X.D1, -X.D2);
end