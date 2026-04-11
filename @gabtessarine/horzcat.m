function res = horzcat(varargin)
% HORZCAT Horizontal concatenation for gabtessarine objects.
%
%   Z = [X, Y] performs horizontal concatenation, merging arrays side-by-side.
%
%   IMPLEMENTATION STRATEGY:
%   This function implements "Automatic Domain Promotion". It allows seamless 
%   merging of GABTESSARINE (8D), ABTESSARINE (4D), and numeric arrays (2D). 
%   Lower-dimensional structures are automatically upcast to the 8D manifold 
%   by zero-padding the ε-complex and hypercomplex components.
%
%   Final assembly is executed via MATLAB's native 'cat' engine along 
%   dimension 2 to ensure O(N) linear time complexity.

%   See also VERTCAT.

    % Pre-allocate cell arrays for all 8 hypercomplex components
    A1s = cell(1, nargin); A2s = cell(1, nargin);
    B1s = cell(1, nargin); B2s = cell(1, nargin);
    C1s = cell(1, nargin); C2s = cell(1, nargin);
    D1s = cell(1, nargin); D2s = cell(1, nargin);
    
    for i = 1:nargin
        item = varargin{i};
        
        if isa(item, 'gabtessarine')
            % Direct extraction (8D case)
            A1s{i} = item.A1; A2s{i} = item.A2;
            B1s{i} = item.B1; B2s{i} = item.B2;
            C1s{i} = item.C1; C2s{i} = item.C2;
            D1s{i} = item.D1; D2s{i} = item.D2;
            
        elseif isa(item, 'abtessarine')
            % Upcast 4D -> 8D: Standard components map to '1' parts,
            % while all epsilon (ε) parts are initialized to zero.
            A1s{i} = item.A; B1s{i} = item.B;
            C1s{i} = item.C; D1s{i} = item.D;
            
            z = zeros(size(item.A));
            A2s{i} = z; B2s{i} = z;
            C2s{i} = z; D2s{i} = z;
            
        elseif isnumeric(item)
            % Upcast 2D -> 8D: Numeric array maps to the fundamental real part.
            A1s{i} = item;
            
            z = zeros(size(item));
            A2s{i} = z;
            B1s{i} = z; B2s{i} = z;
            C1s{i} = z; C2s{i} = z;
            D1s{i} = z; D2s{i} = z;
            
        else
            error('gabtessarine:horzcat:InvalidType', ...
                  'Incompatible type. Only gabtessarine, abtessarine, or numeric types are supported.');
        end
    end
    
    % Perform high-speed native concatenation along dimension 2 (Horizontal)
    res = gabtessarine(cat(2, A1s{:}), cat(2, A2s{:}), ...
                       cat(2, B1s{:}), cat(2, B2s{:}), ...
                       cat(2, C1s{:}), cat(2, C2s{:}), ...
                       cat(2, D1s{:}), cat(2, D2s{:}));
end