function Z = mtimes(X, Y)
% MTIMES Overloads the matrix multiplication operator (*) for gabtessarine objects.
%
%   Z = X * Y performs the 8-dimensional hypercomplex matrix product.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Zero-Padding Elimination: When multiplying 4D (abtessarine) by 8D 
%     (gabtessarine) objects, the algorithm bypasses the creation of 
%     8D intermediate structures, executing mathematically reduced equations.
%   - BLAS Parenthesis Protection: Expressions like 'alpha*(A*B)' force 
%     MATLAB's JIT compiler to delegate the dense matrix multiplication 
%     directly to underlying BLAS libraries before applying scalar scaling, 
%     preventing the allocation of intermediate memory arrays.
%   - Cayley-Dickson Unrolling: The 64 fundamental block products are 
%     algebraically unrolled to bypass loop overhead.

%   See also TIMES, KRON.

    % --- 1. GLOBAL ALGEBRAIC ENVIRONMENT & STRICT GUARDRAIL ---
    [alpha, beta] = getabtessarine();
    
    if isempty(alpha) || isempty(beta)
        error('gabtessarine:mtimes:MissingEnvironment', ...
              'Global environment undefined. Run setabtessarine first.');
    end
    
    % Mathematical constraint for the 8D generalized algebra
    if alpha <= 0
        error('gabtessarine:mtimes:InvalidAlpha', ...
              'Matrix multiplication in the 8D manifold is strictly defined for alpha > 0.');
    end

    % --- 2. UPCASTING: NUMERIC (X) * GABTESSARINE (Y) ---
    if isnumeric(X) && isa(Y, 'gabtessarine')
        Z = gabtessarine(X * Y.A1, X * Y.A2, X * Y.B1, X * Y.B2, ...
                         X * Y.C1, X * Y.C2, X * Y.D1, X * Y.D2);
        return;
    end
    
    % --- 2b. UPCASTING: GABTESSARINE (X) * NUMERIC (Y) ---
    if isa(X, 'gabtessarine') && isnumeric(Y)
        Z = gabtessarine(X.A1 * Y, X.A2 * Y, X.B1 * Y, X.B2 * Y, ...
                         X.C1 * Y, X.C2 * Y, X.D1 * Y, X.D2 * Y);
        return;
    end

    % --- 3. MIXED ALGEBRAS (4D * 8D) - HPC Direct Injection ---
    % Avoids zero-padding overhead by executing geometrically reduced equations.
    if isa(X, 'abtessarine') && isa(Y, 'gabtessarine')
        % X is 4D (lacks A2, B2, C2, D2). Epsilon cross-terms vanish.
        M1_1 = X.A*Y.A1 + alpha*(X.B*Y.B1);
        M1_2 = X.A*Y.A2 + alpha*(X.B*Y.B2);
        M1_3 = X.A*Y.B1 + X.B*Y.A1;
        M1_4 = X.A*Y.B2 + X.B*Y.A2;
        
        M2_1 = X.C*Y.C1 + alpha*(X.D*Y.D1);
        M2_2 = X.C*Y.C2 + alpha*(X.D*Y.D2);
        M2_3 = X.C*Y.D1 + X.D*Y.C1;
        M2_4 = X.C*Y.D2 + X.D*Y.C2;
        
        M3_1 = X.A*Y.C1 + alpha*(X.B*Y.D1);
        M3_2 = X.A*Y.C2 + alpha*(X.B*Y.D2);
        M3_3 = X.A*Y.D1 + X.B*Y.C1;
        M3_4 = X.A*Y.D2 + X.B*Y.C2;
        
        M4_1 = X.C*Y.A1 + alpha*(X.D*Y.B1);
        M4_2 = X.C*Y.A2 + alpha*(X.D*Y.B2);
        M4_3 = X.C*Y.B1 + X.D*Y.A1;
        M4_4 = X.C*Y.B2 + X.D*Y.A2;
        
        Z = gabtessarine(M1_1 + beta * M2_1, M1_2 + beta * M2_2, M1_3 + beta * M2_3, M1_4 + beta * M2_4, ...
                         M3_1 + M4_1, M3_2 + M4_2, M3_3 + M4_3, M3_4 + M4_4);
        return;
    end
    
    if isa(X, 'gabtessarine') && isa(Y, 'abtessarine')
        % Y is 4D (lacks A2, B2, C2, D2). Epsilon cross-terms vanish.
        M1_1 = X.A1*Y.A + alpha*(X.B1*Y.B);
        M1_2 = X.A2*Y.A + alpha*(X.B2*Y.B);
        M1_3 = X.A1*Y.B + X.B1*Y.A;
        M1_4 = X.A2*Y.B + X.B2*Y.A;
        
        M2_1 = X.C1*Y.C + alpha*(X.D1*Y.D);
        M2_2 = X.C2*Y.C + alpha*(X.D2*Y.D);
        M2_3 = X.C1*Y.D + X.D1*Y.C;
        M2_4 = X.C2*Y.D + X.D2*Y.C;
        
        M3_1 = X.A1*Y.C + alpha*(X.B1*Y.D);
        M3_2 = X.A2*Y.C + alpha*(X.B2*Y.D);
        M3_3 = X.A1*Y.D + X.B1*Y.C;
        M3_4 = X.A2*Y.D + X.B2*Y.C;
        
        M4_1 = X.C1*Y.A + alpha*(X.D1*Y.B);
        M4_2 = X.C2*Y.A + alpha*(X.D2*Y.B);
        M4_3 = X.C1*Y.B + X.D1*Y.A;
        M4_4 = X.C2*Y.B + X.D2*Y.A;
        
        Z = gabtessarine(M1_1 + beta * M2_1, M1_2 + beta * M2_2, M1_3 + beta * M2_3, M1_4 + beta * M2_4, ...
                         M3_1 + M4_1, M3_2 + M4_2, M3_3 + M4_3, M3_4 + M4_4);
        return;
    end

    % --- 4. CORE MULTIPLICATION: 8D * 8D ---
    if isa(X, 'gabtessarine') && isa(Y, 'gabtessarine')
        
        % Dimension validation for matrix product
        szX = size(X.A1); szY = size(Y.A1);
        isScalarX = isequal(szX, [1 1]); 
        isScalarY = isequal(szY, [1 1]);
        
        if ~(isScalarX || isScalarY) && (szX(2) ~= szY(1))
            error('gabtessarine:mtimes:InnerDimensions', ...
                  'Incompatible matrix dimensions. Inner dimensions must agree (X cols == Y rows).');
        end
        
        % Direct extraction to L1 Cache
        XA1 = X.A1; XA2 = X.A2; XB1 = X.B1; XB2 = X.B2;
        XC1 = X.C1; XC2 = X.C2; XD1 = X.D1; XD2 = X.D2;
        
        YA1 = Y.A1; YA2 = Y.A2; YB1 = Y.B1; YB2 = Y.B2;
        YC1 = Y.C1; YC2 = Y.C2; YD1 = Y.D1; YD2 = Y.D2;

        % --- UNROLLED CAYLEY-DICKSON CONSTRUCTION ---
        % Incorporates ε^2 = -1 directly into the signs (-XA2*YA2, etc.)
        M1_1 = XA1*YA1 - XA2*YA2 + alpha*(XB1*YB1) - alpha*(XB2*YB2);
        M1_2 = XA1*YA2 + XA2*YA1 + alpha*(XB1*YB2) + alpha*(XB2*YB1);
        M1_3 = XA1*YB1 - XA2*YB2 + XB1*YA1 - XB2*YA2;
        M1_4 = XA1*YB2 + XA2*YB1 + XB1*YA2 + XB2*YA1;
        
        M2_1 = XC1*YC1 - XC2*YC2 + alpha*(XD1*YD1) - alpha*(XD2*YD2);
        M2_2 = XC1*YC2 + XC2*YC1 + alpha*(XD1*YD2) + alpha*(XD2*YD1);
        M2_3 = XC1*YD1 - XC2*YD2 + XD1*YC1 - XD2*YC2;
        M2_4 = XC1*YD2 + XC2*YD1 + XD1*YC2 + XD2*YC1;
        
        M3_1 = XA1*YC1 - XA2*YC2 + alpha*(XB1*YD1) - alpha*(XB2*YD2);
        M3_2 = XA1*YC2 + XA2*YC1 + alpha*(XB1*YD2) + alpha*(XB2*YD1);
        M3_3 = XA1*YD1 - XA2*YD2 + XB1*YC1 - XB2*YC2;
        M3_4 = XA1*YD2 + XA2*YD1 + XB1*YC2 + XB2*YC1;
        
        M4_1 = XC1*YA1 - XC2*YA2 + alpha*(XD1*YB1) - alpha*(XD2*YB2);
        M4_2 = XC1*YA2 + XC2*YA1 + alpha*(XD1*YB2) + alpha*(XD2*YB1);
        M4_3 = XC1*YB1 - XC2*YB2 + XD1*YA1 - XD2*YA2;
        M4_4 = XC1*YB2 + XC2*YB1 + XD1*YA2 + XD2*YA1;
        
        % --- FINAL OBJECT ASSEMBLY ---
        Z = gabtessarine(...
            M1_1 + beta * M2_1, M1_2 + beta * M2_2, ... 
            M1_3 + beta * M2_3, M1_4 + beta * M2_4, ... 
            M3_1 + M4_1,        M3_2 + M4_2,        ... 
            M3_3 + M4_3,        M3_4 + M4_4         ... 
        );
        return;
    end
end