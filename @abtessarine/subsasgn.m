function obj = subsasgn(obj, S, val)
% SUBSASGN Overloads index assignment for abtessarine objects.
%
%   X(i,j) = VAL modifies the specific elements of the abtessarine array.
%   This implementation ensures algebraic integrity by synchronizing the 
%   assignment across the four internal hypercomplex components (A, B, C, D).
%
%   BEHAVIOR:
%   - If VAL is an abtessarine object: Components are mapped 1-to-1.
%   - If VAL is numeric: VAL is assigned to component A, while B, C, and D 
%     are automatically padded with zeros to maintain the domain consistency.
%   - Dot notation (X.A = ...): Delegated to native MATLAB built-ins.

%   See also SUBSREF, DISP.

    switch S(1).type
        case '()'
            % --- 1. INDEXED ASSIGNMENT: X(idx) = VAL ---
            idx = S(1).subs;
            
            % Auto-initialization for empty objects (Lazy Loading)
            if isempty(obj) || ~isa(obj, 'abtessarine')
                obj = abtessarine([], [], [], []);
            end
            
            % Branching based on input type for structural synchronization
            if isa(val, 'abtessarine')
                % Synchronized component-wise injection
                obj.A(idx{:}) = val.A;
                obj.B(idx{:}) = val.B;
                obj.C(idx{:}) = val.C;
                obj.D(idx{:}) = val.D;
                
            elseif isnumeric(val)
                % Domain promotion: Numeric value occupies the real part A
                % while hypercomplex parts are nullified for those indices.
                obj.A(idx{:}) = val;
                obj.B(idx{:}) = zeros(size(val));
                obj.C(idx{:}) = zeros(size(val));
                obj.D(idx{:}) = zeros(size(val));
            else
                error('abtessarine:subsasgn:InvalidAssignment', ...
                      'Assignment requires numeric values or abtessarine objects.');
            end
            
        case '.'
            % --- 2. PROPERTY ASSIGNMENT: X.prop = VAL ---
            % High-speed delegation to the native MATLAB property engine
            obj = builtin('subsasgn', obj, S, val);
            
        case '{}'
            % --- 3. CELL ACCESS (UNSUPPORTED) ---
            error('abtessarine:subsasgn:CellNotSupported', ...
                  'Cell-style indexing ({}) is undefined for the abtessarine class.');
    end
end