function setabtessarine(alpha, beta)
% SETABTESSARINE Configures the global parameters of the abtessarine algebra.
%
%   SETABTESSARINE(ALPHA, BETA) sets the values of the structural constants 
%   of the algebra for all subsequent operations with abtessarine objects.
%
%   Algebra rules: 
%       i^2 = alpha,  j^2 = beta,  k^2 = alpha * beta
%
%   Inputs:
%       ALPHA - Non-zero real scalar.
%       BETA  - Strictly positive real scalar.
%
%   Example:
%       setabtessarine(-1, 1) % Configures a classic abtessarine environment
%
%   See also: ABTESSARINE.

    % 1. ARGUMENT COUNT VALIDATION
    % Ensures the user inputs exactly 2 arguments.
    narginchk(2, 2);

    % 2. STRICT VALIDATION OF THE ALPHA PARAMETER
    % Requires: numeric, scalar, real, finite, non-NaN.
    validateattributes(alpha, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnan'}, ...
        'setabtessarine', 'alpha', 1);
    
    % Alpha must be mathematically non-zero
    if alpha == 0
        error('abtessarine:setabtessarine:ZeroAlpha', ...
              'The structural parameter ALPHA cannot be zero.');
    end

    % 3. STRICT VALIDATION OF THE BETA PARAMETER
    % Requires: numeric, scalar, real, finite, non-NaN, and > 0 (positive).
    validateattributes(beta, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnan', '>', 0}, ...
        'setabtessarine', 'beta', 2);

    % 4. GLOBAL ENVIRONMENT STORAGE
    % Store the values as 'double' to guarantee precision 
    % in future matrix multiplications.
    setappdata(0, 'Tessarine_Alpha', double(alpha));
    setappdata(0, 'Tessarine_Beta', double(beta));

    % 5. USER FEEDBACK
    fprintf('abtessarine environment successfully configured: alpha = %g, beta = %g\n', alpha, beta);
end