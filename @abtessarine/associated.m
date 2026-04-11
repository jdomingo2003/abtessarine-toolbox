function XE = associated(X)
% ASSOCIATED Computes the associated representation of an abtessarine object.
%
%   XE = associated(X) computes the block projection utilizing the globally 
%   configured alpha and beta parameters.
%   (Ensure setabtessarine(alpha, beta) has been executed prior to invocation).
%
%   Note: This function returns a new abtessarine object constructed from 
%   the idempotent projections defined within the theoretical framework.

%   See also ABTESSARINE, SETABTESSARINE.

    % --- 1. INPUT VALIDATION ---
    if nargin < 1
        error('abtessarine:associated:NotEnoughInputs', ...
              'Input argument X representing the abtessarine object is required.');
    end
    
    % --- 2. RETRIEVE GLOBAL PARAMETERS ---
    % Retrieve the alpha and beta parameters from the global workspace established by setabtessarine.
    [alpha, beta] = getabtessarine();
    
    % Verify parameter initialization and throw a descriptive error if uninitialized.
    if isempty(alpha) || isempty(beta)
        error('abtessarine:associated:ParametersNotSet', ...
              'Global operational parameters are uninitialized. Execute setabtessarine(alpha, beta) prior to this operation.');
    end
    
    % --- 3. PRECOMPUTATION OF IDEMPOTENT BASES ---
    g = sqrt(beta);
    
    % Shared symmetric and antisymmetric real projections
    AS = X.A + g * X.C;
    AD = X.A - g * X.C;
    
    % --- 4. BIFURCATED MATRIX ASSEMBLY (Direct Allocation) ---
    if alpha < 0
        % Route 1: alpha < 0 
        % The theoretical definition dictates that the imaginary-equivalent 
        % blocks evaluate to zero (EE) under this specific isomorphic mapping.
        EE = zeros(size(X.A));
        
        % Direct memory allocation for the resulting abtessarine object
        XE = abtessarine(AS, EE, AD, EE);
        
    else
        % Route 2: alpha > 0
        % Complete four-block idempotent expansion
        z = sqrt(alpha);
        
        zBS = z * (X.B + g * X.D);
        zBD = z * (X.B - g * X.D);
        
        % Direct memory allocation avoiding temporary variable overhead
        XE = abtessarine(AS + zBS, AS - zBS, AD + zBD, AD - zBD);
    end
end