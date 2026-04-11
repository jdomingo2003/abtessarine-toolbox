function res = vertcat(varargin)
% VERTCAT Overloads vertical concatenation for gabtessarine objects: [X; Y; Z...]
%
%   Allows using MATLAB's standard bracket syntax with semicolons to 
%   vertically stack gabtessarine arrays, abtessarine arrays, and numeric matrices.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Cell-Array Buffering: Avoids the quadratic memory reallocation penalty
%     typical of iterative concatenation. Pointers to internal matrices are 
%     collected into preallocated cell arrays in O(1) per item.
%   - Single-Pass Delegation: A single terminal call to the C-level built-in 
%     'vertcat' simultaneously merges all accumulated blocks, minimizing JIT 
%     compiler overhead.
%   - Dimensional Padding: During algebraic upcasting (e.g., Numeric to 8D), 
%     missing orthogonal spaces are explicitly padded with dense zero-matrices 
%     to ensure boundary alignment prior to vertical stacking.

%   See also HORZCAT.

    % 1. Memory allocation for pointers (O(N) space where N = nargin)
    A1s = cell(nargin, 1); A2s = cell(nargin, 1);
    B1s = cell(nargin, 1); B2s = cell(nargin, 1);
    C1s = cell(nargin, 1); C2s = cell(nargin, 1);
    D1s = cell(nargin, 1); D2s = cell(nargin, 1);
    
    % 2. Extract and buffer internal arrays
    for i = 1:nargin
        item = varargin{i};
        
        if isa(item, 'gabtessarine')
            % Direct mapping for native 8D manifolds
            A1s{i} = item.A1; A2s{i} = item.A2;
            B1s{i} = item.B1; B2s{i} = item.B2;
            C1s{i} = item.C1; C2s{i} = item.C2;
            D1s{i} = item.D1; D2s{i} = item.D2;
            
        elseif isa(item, 'abtessarine')
            % Upcast from 4D to 8D 
            % Padding is mathematically required to align matrix columns
            A1s{i} = item.A; B1s{i} = item.B;
            C1s{i} = item.C; D1s{i} = item.D;
            
            z = zeros(size(item.A));
            A2s{i} = z; B2s{i} = z;
            C2s{i} = z; D2s{i} = z;
            
        elseif isnumeric(item)
            % Upcast from 2D numeric space to 8D
            A1s{i} = item;
            
            z = zeros(size(item));
            A2s{i} = z;
            B1s{i} = z; B2s{i} = z;
            C1s{i} = z; C2s{i} = z;
            D1s{i} = z; D2s{i} = z;
            
        else
            error('gabtessarine:vertcat:InvalidType', ...
                  'Type mismatch: Only gabtessarine, abtessarine, or numeric arrays can be vertically concatenated.');
        end
    end
    
    % 3. Terminal Assembly via Native C-Backend
    % Using 'vertcat' is slightly faster than 'cat(1, ...)' for 2D arrays
    res = gabtessarine(vertcat(A1s{:}), vertcat(A2s{:}), ...
                       vertcat(B1s{:}), vertcat(B2s{:}), ...
                       vertcat(C1s{:}), vertcat(C2s{:}), ...
                       vertcat(D1s{:}), vertcat(D2s{:}));
end