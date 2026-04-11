function Z = mtimes(X, Y)
% MTIMES Overloads the multiplication operator (*) for abtessarine objects.
% 
%   Z = X * Y performs the hypercomplex matrix product. It supports 
%   standard matrix-matrix multiplication, matrix-vector products, 
%   and scalar expansion.
%
%   MATHEMATICAL OVERVIEW:
%   The function computes the abtessarine product by expanding the 
%   multiplication of two 4D arrays according to the algebraic rules:
%   i^2 = alpha, j^2 = beta, k^2 = alpha*beta. 
%
%   COMPUTATIONAL PERFORMANCE:
%   This implementation is FLOP-optimized to minimize the creation of 
%   temporary matrices. It delegates the 16 internal sub-products to 
%   MATLAB's native BLAS-optimized engine, ensuring maximum CPU 
%   utilization and high-speed throughput for large dense matrices.

%   See also TIMES, MPOWER, KRON, MRDIVIDE, MLDIVIDE.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:mtimes:MissingEnvironment', ...
              'Global algebraic parameters are uninitialized. Execute setabtessarine.');
    end

    % --- 2. HYBRID MULTIPLICATION: Numeric * abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Scalar or numeric matrix scaling applied to all components
        Z = abtessarine(X * Y.A, X * Y.B, X * Y.C, X * Y.D);
        return;
    end
    
    % --- 3. HYBRID MULTIPLICATION: abtessarine * Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % abtessarine matrix scaled by a numeric type
        Z = abtessarine(X.A * Y, X.B * Y, X.C * Y, X.D * Y);
        return;
    end

    % --- 4. CORE MULTIPLICATION: abtessarine * abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        
        % A. Dimension Validation (Fast-Fail)
        szX = size(X.A);
        szY = size(Y.A);
        
        % Check for scalar expansion (1x1 cases)
        isScalarX = isequal(szX, [1 1]);
        isScalarY = isequal(szY, [1 1]);
        
        % Standard matrix dimension check
        if ~(isScalarX || isScalarY) && (szX(2) ~= szY(1))
            error('abtessarine:mtimes:InnerDimensions', ...
                  'Incompatible matrix dimensions: %dx%d and %dx%d.', ...
                  szX(1), szX(2), szY(1), szY(2));
        end
        
        % B. Direct Component Extraction
        A1 = X.A; B1 = X.B; C1 = X.C; D1 = X.D;
        A2 = Y.A; B2 = Y.B; C2 = Y.C; D2 = Y.D;
        
        % C. Algebraic Constant Pre-calculation (k^2 = alpha * beta)
        ab = alpha * beta;
        
        % D. Hypercomplex Multiplication Kernel
        % This logic distributes the product over the basis {1, i, j, k}
        ZA = A1*A2 + alpha*(B1*B2) + beta*(C1*C2) + ab*(D1*D2);
        ZB = A1*B2 + B1*A2 + beta*(C1*D2) + beta*(D1*C2);
        ZC = A1*C2 + alpha*(B1*D2) + C1*A2 + alpha*(D1*B2);
        ZD = A1*D2 + B1*C2 + C1*B2 + D1*A2;
        
        % Construction of the resulting object
        Z = abtessarine(ZA, ZB, ZC, ZD);
        return;
    end
    
    % --- 5. TYPE VALIDATION SHIELD ---
    error('abtessarine:mtimes:InvalidTypes', ...
          'Multiplication is restricted to abtessarine objects and numeric types.');
end