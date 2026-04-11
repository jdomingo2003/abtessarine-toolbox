function Z = mrdivide(X, Y)
% MRDIVIDE Overloads right matrix division (/) for abtessarine objects.
%
%   Z = X / Y solves the system of linear equations Z * Y = X in the 
%   abtessarine domain.
%
%   ALGORITHMIC STRATEGY:
%   This function implements an isomorphic mapping technique to solve the 
%   system without explicit matrix inversion. It projects the 4D 
%   abtessarine arrays into native 2D (complex) or 1D (real) branches 
%   based on the algebraic parameters alpha and beta. 
%
%   COMPUTATIONAL PERFORMANCE:
%   By delegating the operation to MATLAB's native forward slash (/) operator 
%   on each decoupled branch, the algorithm leverages optimized LAPACK 
%   routines for dense matrix factorization. The hypercomplex result is 
%   then reconstructed via an inverse isomorphic transformation.

%   See also MLDIVIDE, INV, PINV, MTIMES.
 
    % --- 1. HYBRID DIVISION: abtessarine / Numeric ---
    if isa(X, 'abtessarine') && isnumeric(Y)
        % Element-wise division of components by a numeric scalar or array
        Z = abtessarine(X.A / Y, X.B / Y, X.C / Y, X.D / Y);
        return;
    end
    
    % --- 2. DOMAIN PROMOTION: Numeric / abtessarine ---
    if isnumeric(X) && isa(Y, 'abtessarine')
        % Promote the numeric dividend X to the abtessarine domain
        X = abtessarine(X, zeros(size(X)), zeros(size(X)), zeros(size(X)));
    end

    % --- 3. CORE ALGORITHM: abtessarine / abtessarine ---
    if isa(X, 'abtessarine') && isa(Y, 'abtessarine')
        
        % Retrieve global algebraic environment
        [alpha, beta] = getabtessarine();
        
        if isempty(alpha) || isempty(beta)
            error('abtessarine:mrdivide:MissingEnvironment', ...
                  'Global algebraic parameters are uninitialized. Execute setabtessarine.');
        end

        % --- FIRST REDUCTION: 4D to 2D (Beta/G Projection) ---
        g = sqrt(beta);
        
        % Projections of X (Dividend)
        g_XC = g * X.C;   g_XD = g * X.D;
        X_AS = X.A + g_XC;  X_AD = X.A - g_XC;
        X_BS = X.B + g_XD;  X_BD = X.B - g_XD;
        
        % Projections of Y (Divisor)
        g_YC = g * Y.C;   g_YD = g * Y.D;
        Y_AS = Y.A + g_YC;  Y_AD = Y.A - g_YC;
        Y_BS = Y.B + g_YD;  Y_BD = Y.B - g_YD;

        % --- SECOND REDUCTION & SOLVER BIFURCATION (Alpha/Z Branching) ---
        if alpha < 0
            % COMPLEX BRANCH (Elliptic Mapping)
            z = sqrt(-alpha);
            inv_z = 1 / z;
            
            % Map to native Complex Double branches
            X_TS = X_AS + (X_BS * z) * 1i;
            X_TD = X_AD + (X_BD * z) * 1i;
            
            Y_TS = Y_AS + (Y_BS * z) * 1i;
            Y_TD = Y_AD + (Y_BD * z) * 1i;
            
            % Solve natively via MATLAB's internal LAPACK-based engine
            TS = X_TS / Y_TS;
            TD = X_TD / Y_TD;
            
            % Component extraction from complex solutions
            E1 = real(TS); E2 = imag(TS) * inv_z;
            F1 = real(TD); F2 = imag(TD) * inv_z;
            
        else
            % REAL BRANCH (Hyperbolic Mapping)
            z = sqrt(alpha);
            inv_z2 = 0.5 / z;
            
            % Map to native Real branches (Full Idempotent Split)
            zX_BS = z * X_BS;  zX_BD = z * X_BD;
            X_SS = X_AS + zX_BS; X_DS = X_AS - zX_BS;
            X_SD = X_AD + zX_BD; X_DD = X_AD - zX_BD;
            
            zY_BS = z * Y_BS;  zY_BD = z * Y_BD;
            Y_SS = Y_AS + zY_BS; Y_DS = Y_AS - zY_BS;
            Y_SD = Y_AD + zY_BD; Y_DD = Y_AD - zY_BD;
            
            % Solve natively across the four real branches
            ES = X_SS / Y_SS;
            FS = X_DS / Y_DS;
            ED = X_SD / Y_SD;
            FD = X_DD / Y_DD;
            
            % Reconstruct components using algebraic recycling
            E1 = (ES + FS) * 0.5; E2 = (ES - FS) * inv_z2;
            F1 = (ED + FD) * 0.5; F2 = (ED - FD) * inv_z2;
        end

        % --- FINAL INVERSE MAPPING: 2D to 4D ---
        inv_g2 = 0.5 / g;
        
        Z = abtessarine((E1 + F1) * 0.5, ...
                        (E2 + F2) * 0.5, ...
                        (E1 - F1) * inv_g2, ...
                        (E2 - F2) * inv_g2);
        return;
    end
    
    error('abtessarine:mrdivide:InvalidTypes', ...
          'Right division is only defined for abtessarine objects and compatible numeric types.');
end