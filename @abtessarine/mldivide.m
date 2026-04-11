function Z = mldivide(X, Y)
% MLDIVIDE Overloads left matrix division (\) for abtessarine objects.
%
%   Z = X \ Y solves the system of linear equations X * Z = Y in the 
%   abtessarine domain.
%
%   ALGORITHMIC METHODOLOGY:
%   To maximize stability and performance, this implementation avoids 
%   explicit matrix inversion. Instead, it utilizes an isomorphic decoupling 
%   strategy that maps the 4D system into independent 2D (complex) or 
%   1D (real) branches.
%
%   SOLVER STRATEGY:
%   The function delegates the actual computation to MATLAB's native 
%   backslash (\) operator on each branch. This implicitly triggers 
%   optimized LAPACK routines (typically LU factorization with partial 
%   pivoting), ensuring O(N^3) complexity and high numerical precision.
%   The result is then reconstructed via the inverse isomorphic mapping.

%   See also MRDIVIDE, INV, PINV, MTIMES.

    % --- 1. HYBRID DIVISION: Numeric \ abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Scalar/Matrix numeric divisor applied to all components
        Z = abtessarine(X \ Y.A, X \ Y.B, X \ Y.C, X \ Y.D);
        return;
    end
    
    % --- 2. DOMAIN PROMOTION: abtessarine \ Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % Promote numeric dividend Y to the abtessarine domain
        Y = abtessarine(Y, zeros(size(Y)), zeros(size(Y)), zeros(size(Y)));
    end

    % --- 3. CORE ALGORITHM: abtessarine \ abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        
        % Retrieve global environment parameters
        [alpha, beta] = getabtessarine();
        
        if isempty(alpha) || isempty(beta)
            error('abtessarine:mldivide:MissingEnvironment', ...
                  'Global algebraic parameters are uninitialized. Run setabtessarine.');
        end

        % --- FIRST REDUCTION: 4D to 2D (Beta/G Projection) ---
        g = sqrt(beta);
        
        % Projections for X (System Matrix)
        g_XC = g * X.C;   g_XD = g * X.D;
        X_AS = X.A + g_XC;  X_AD = X.A - g_XC;
        X_BS = X.B + g_XD;  X_BD = X.B - g_XD;
        
        % Projections for Y (Independent Terms)
        g_YC = g * Y.C;   g_YD = g * Y.D;
        Y_AS = Y.A + g_YC;  Y_AD = Y.A - g_YC;
        Y_BS = Y.B + g_YD;  Y_BD = Y.B - g_YD;

        % --- SECOND REDUCTION & SOLVER BIFURCATION (Alpha/Z Branching) ---
        if alpha < 0
            % COMPLEX BRANCH (Elliptic)
            z = sqrt(-alpha);
            inv_z = 1 / z;
            
            % Map to native Complex Double branches
            X_TS = X_AS + (X_BS * z) * 1i;
            X_TD = X_AD + (X_BD * z) * 1i;
            
            Y_TS = Y_AS + (Y_BS * z) * 1i;
            Y_TD = Y_AD + (Y_BD * z) * 1i;
            
            % Solve natively using MATLAB's internal LU/LAPACK engine
            TS = X_TS \ Y_TS;
            TD = X_TD \ Y_TD;
            
            % Component extraction from complex resultants
            E1 = real(TS); E2 = imag(TS) * inv_z;
            F1 = real(TD); F2 = imag(TD) * inv_z;
            
        else
            % REAL BRANCH (Hyperbolic)
            z = sqrt(alpha);
            inv_z2 = 0.5 / z;
            
            % Map to native Real branches (Full Idempotent Split)
            zX_BS = z * X_BS;  zX_BD = z * X_BD;
            X_SS = X_AS + zX_BS; X_DS = X_AS - zX_BS;
            X_SD = X_AD + zX_BD; X_DD = X_AD - zX_BD;
            
            zY_BS = z * Y_BS;  zY_BD = z * Y_BD;
            Y_SS = Y_AS + zY_BS; Y_DS = Y_AS - zY_BS;
            Y_SD = Y_AD + zY_BD; Y_DD = Y_AD - zY_BD;
            
            % Solve natively on all four real branches
            ES = X_SS \ Y_SS;
            FS = X_DS \ Y_DS;
            ED = X_SD \ Y_SD;
            FD = X_DD \ Y_DD;
            
            % Component extraction via algebraic recycling
            E1 = (ES + FS) * 0.5; E2 = (ES - FS) * inv_z2;
            F1 = (ED + FD) * 0.5; F2 = (ED - FD) * inv_z2;
        end

        % --- FINAL RECONSTRUCTION: 2D to 4D ---
        inv_g2 = 0.5 / g;
        
        Z = abtessarine((E1 + F1) * 0.5, ...
                        (E2 + F2) * 0.5, ...
                        (E1 - F1) * inv_g2, ...
                        (E2 - F2) * inv_g2);
        return;
    end
    
    error('abtessarine:mldivide:InvalidTypes', ...
          'Left division is only defined for abtessarine objects and numeric types.');
end