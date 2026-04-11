classdef (InferiorClasses = {?abtessarine, ?double}) gabtessarine
% GABTESSARINE Object representing a generalized 8D alpha-beta tessarine.
%
%   X = GABTESSARINE(A1, A2, B1, B2, C1, C2, D1, D2) instantiates an 8-dimensional 
%   hypercomplex matrix. This class serves as the complexified extension 
%   of the standard 4D abtessarine space.
%
%   MATHEMATICAL STRUCTURE:
%   The algebra introduces a complex imaginary unit 'epsilon' (\epsilon^2 = -1) 
%   that commutes with the spatial basis {i, j, k}. The object is defined as:
%
%   X = (A1 + A2*eps) + (B1 + B2*eps)*i + (C1 + C2*eps)*j + (D1 + D2*eps)*k
%
%   ALGEBRAIC CONSTRAINT:
%   This 8D representation is mathematically required for hyperbolic geometries 
%   where Alpha > 0. In elliptic cases (Alpha <= 0), the 4D abtessarine 
%   retains algebraic closure.
%
%   See also: ABTESSARINE, SETABTESSARINE.

    properties
        A1 % Real component of basis 1
        A2 % Epsilon component of basis 1
        B1 % Real component of basis i
        B2 % Epsilon component of basis i
        C1 % Real component of basis j
        C2 % Epsilon component of basis j
        D1 % Real component of basis k
        D2 % Epsilon component of basis k
    end
    
    methods
        function obj = gabtessarine(a1, a2, b1, b2, c1, c2, d1, d2)
            %GABTESSARINE Class constructor.
            
            % --- 1. MEMORY PREALLOCATION SUPPORT (HPC) ---
            if nargin == 0
                obj.A1 = []; obj.A2 = []; obj.B1 = []; obj.B2 = [];
                obj.C1 = []; obj.C2 = []; obj.D1 = []; obj.D2 = [];
                return;
            end
            
            % --- 2. TOPOLOGICAL GUARDRAIL ---
            % Ensure the environment is set to Hyperbolic (Alpha > 0)
            alpha = getabtessarine(); 
            
            if isempty(alpha)
                error('gabtessarine:Constructor:MissingEnvironment', ...
                      'Global environment undefined. Run setabtessarine before instantiation.');
            elseif alpha <= 0
                error('gabtessarine:Constructor:InvalidAlpha', ...
                      ['Mathematical constraint: The 8D generalized algebra (gabtessarine) ' ...
                       'requires alpha > 0. Use 4D abtessarine for alpha <= 0.']);
            end
            
            % --- 3. INPUT VALIDATION ---
            if nargin ~= 8
                error('gabtessarine:Constructor:InputCount', ...
                      'Exactly 8 numeric arrays are required for GABTESSARINE initialization.');
            end
            
            % --- 4. DIMENSIONAL INTEGRITY CHECK ---
            sz = size(a1);
            if ~isequal(sz, size(a2)) || ~isequal(sz, size(b1)) || ~isequal(sz, size(b2)) || ...
               ~isequal(sz, size(c1)) || ~isequal(sz, size(c2)) || ~isequal(sz, size(d1)) || ~isequal(sz, size(d2))
                error('gabtessarine:Constructor:DimensionMismatch', ...
                      'Structural error: All 8 input arrays must possess identical dimensions.');
            end
            
            % --- 5. DIRECT MEMORY INJECTION ---
            obj.A1 = a1; obj.A2 = a2;
            obj.B1 = b1; obj.B2 = b2;
            obj.C1 = c1; obj.C2 = c2;
            obj.D1 = d1; obj.D2 = d2;
        end
    end
end