classdef abtessarine
% ABTESSARINE Object representing an element of the abtessarine algebra.
%
%   XT = abtessarine(A, B, C, D) constructs an instance of the 
%   abtessarine class from four numeric arrays (A, B, C, and D) 
%   of identical dimensions.
%
%   This object functions as a rigorous data container for the coordinates 
%   of the abtessarine array, defined analytically as: 
%   XT = A + B*i + C*j + D*k.
%   
%   The algebraic operational rules (alpha and beta parameters) are defined 
%   globally in the workspace environment and must be initialized using 
%   the setabtessarine function prior to any arithmetic operation.
%
%   Component Extraction (Properties):
%   Internal arrays can be accessed directly using dot notation, providing 
%   optimal computational efficiency:
%       real_part = XT.A;  % Retrieves the real component array
%       i_part    = XT.B;  % Retrieves the imaginary i component array
%       j_part    = XT.C;  % Retrieves the imaginary j component array
%       k_part    = XT.D;  % Retrieves the imaginary k component array
%

    properties
        A % Real component array
        B % Imaginary i component array
        C % Imaginary j component array
        D % Imaginary k component array
    end
    
    methods
        function obj = abtessarine(a, b, c, d)
            % Construct an instance of the abtessarine class.
            
            % 1. Zero-argument constructor for efficient memory preallocation.
            % Essential for initializing large arrays in High-Performance Computing (HPC) contexts.
            if nargin == 0
                obj.A = []; obj.B = []; obj.C = []; obj.D = [];
                return;
            end
            
            % 2. Input argument validation.
            if nargin ~= 4
                error('abtessarine:Constructor:InputCount', ...
                      'Exactly 4 numeric arrays (A, B, C, D) are required to instantiate the object.');
            end
            
            % 3. Dimensional consistency verification.
            % Utilizes isequal on size vectors to avoid element-wise operational overhead.
            szA = size(a);
            if ~isequal(szA, size(b)) || ~isequal(szA, size(c)) || ~isequal(szA, size(d))
                error('abtessarine:Constructor:DimensionMismatch', ...
                      'All four input arrays must possess strictly identical dimensions.');
            end
            
            % 4. Property assignment.
            obj.A = a;
            obj.B = b;
            obj.C = c;
            obj.D = d;
        end
    end
end