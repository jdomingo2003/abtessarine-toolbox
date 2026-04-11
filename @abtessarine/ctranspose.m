function Z_out = ctranspose(X)
% CTRANSPOSE Computes the transpose Hermitian of an abtessarine matrix.
%
%   Z_out = ctranspose(X) applies the Hermitian transposition 
%   utilizing the globally defined operational rules (alpha, beta).
%   This function inherently overloads the standard MATLAB complex conjugate 
%   transpose operator (X').
%
%   Optimized with O(1) geometric memory reordering (.') and direct 
%   constructor injection to minimize RAM allocation overhead.

%   See also TRANSPOSE, HERMITIAN.

    % --- 1. INPUT VALIDATION ---
    if nargin < 1
        error('abtessarine:ctranspose:NotEnoughInputs', ...
              'Input argument X representing the abtessarine object is required.');
    end
    
    % --- 2. RETRIEVE GLOBAL PARAMETERS ---
    % Retrieve operational parameters using the standard getabtessarine interface.
    [alpha, beta] = getabtessarine();
    
    % Verify parameter initialization and throw a descriptive error if uninitialized.
    if isempty(alpha) || isempty(beta)
        error('abtessarine:ctranspose:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 3. PARAMETRIC HERMITIAN TRANSPOSITION ---
    % Extract the topological signatures defined by the algebraic environment.
    sign_a = sign(alpha);
    sign_b = sign(beta); 
    
    % The .' operator guarantees pure geometric memory transposition 
    % without implicit complex conjugation. The algebraic sign adjustments 
    % are injected directly into the constructor to bypass temporary matrix creation.
    Z_out = abtessarine(X.A.', ...
                        X.B.' * sign_a, ...
                        X.C.' * sign_b, ...
                        X.D.' * (sign_a * sign_b));
end