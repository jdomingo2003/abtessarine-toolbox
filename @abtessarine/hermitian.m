function Z_out = hermitian(X, alpha, beta)
% HERMITIAN Computes the generalized Hermitian transpose of an abtessarine matrix.
%
%   Z_out = hermitian(X, alpha, beta) applies a generalized Hermitian 
%   transposition utilizing the explicitly provided alpha and beta 
%   topological parameters.
%
%   CRITICAL NOTE: The input arguments alpha and beta correspond to the 
%   structural involution constants (theta, tau) defined within the 
%   theoretical framework. They function strictly independently of, and 
%   are not required to match, the global operational parameters configured 
%   in the algebraic environment via setabtessarine.
%
%   Optimized via O(1) geometric memory reordering (.') and direct 
%   constructor allocation to minimize computational overhead and memory footprint.

%   See also CTRANSPOSE, TRANSPOSE.


    % --- 1. INPUT VALIDATION ---
    if nargin < 3
        error('abtessarine:hermitian:NotEnoughInputs', ...
              'Explicit provision of the input matrix X, alongside the alpha and beta parameters, is required.');
    end
    
    % --- 2. PARAMETRIC HERMITIAN TRANSPOSITION ---
    % The native .' operator ensures purely geometric matrix transposition, 
    % avoiding implicit complex conjugation. The algebraic scaling factors 
    % are injected directly into the constructor to bypass intermediate array allocations.
    
    Z_out = abtessarine(X.A.', ...
                        X.B.' / alpha, ...
                        X.C.' / beta, ...
                        X.D.' / (alpha * beta));
end