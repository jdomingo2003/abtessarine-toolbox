function obj = subsasgn(obj, S, val)
% SUBSASGN Overloads index assignment for gabtessarine objects.
%
%   Allows modifying specific elements of the gabtessarine array 
%   using parentheses, e.g., X(1,1) = Y. Maintains the integrity of the
%   HPC architecture (1 object = 8 internal arrays).
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Native Scalar Expansion: When upcasting lower-dimensional objects 
%     (4D or numeric) into the 8D manifold, missing orthogonal components 
%     are assigned using scalar 0. MATLAB's JIT compiler natively expands 
%     scalars to match the indexed region, entirely bypassing the costly 
%     allocation of intermediate zero-arrays.
%   - Built-in Delegation: Dot notation assignments (e.g., X.A1 = Y) bypass 
%     custom evaluation trees and hook directly into MATLAB's pre-compiled 
%     C/C++ backend for maximum throughput.

%   See also SUBSREF, DISP.

    switch S(1).type
        case '()'
            % 1. Array indexing assignment: obj(i,j) = val
            idx = S(1).subs;
            
            % If the variable did not exist in the workspace, initialize it
            if isempty(obj) || ~isa(obj, 'gabtessarine')
                obj = gabtessarine([], [], [], [], [], [], [], []);
            end
            
            % Inject the data strictly into the internal memory blocks
            if isa(val, 'gabtessarine')
                % Full 8D isomorphic assignment
                obj.A1(idx{:}) = val.A1;
                obj.A2(idx{:}) = val.A2;
                obj.B1(idx{:}) = val.B1;
                obj.B2(idx{:}) = val.B2;
                obj.C1(idx{:}) = val.C1;
                obj.C2(idx{:}) = val.C2;
                obj.D1(idx{:}) = val.D1;
                obj.D2(idx{:}) = val.D2;
                
            elseif isa(val, 'abtessarine')
                % Upcast from 4D to 8D on the fly
                % HPC Optimization: Scalar 0 forces direct memory zeroing
                obj.A1(idx{:}) = val.A;  obj.A2(idx{:}) = 0;
                obj.B1(idx{:}) = val.B;  obj.B2(idx{:}) = 0;
                obj.C1(idx{:}) = val.C;  obj.C2(idx{:}) = 0;
                obj.D1(idx{:}) = val.D;  obj.D2(idx{:}) = 0;
                
            elseif isnumeric(val)
                % Upcast from 2D (numeric) to 8D
                % HPC Optimization: Scalar 0 bypasses matrix preallocation
                obj.A1(idx{:}) = val;    obj.A2(idx{:}) = 0;
                obj.B1(idx{:}) = 0;      obj.B2(idx{:}) = 0;
                obj.C1(idx{:}) = 0;      obj.C2(idx{:}) = 0;
                obj.D1(idx{:}) = 0;      obj.D2(idx{:}) = 0;
                
            else
                error('gabtessarine:subsasgn:InvalidAssignment', ...
                      'Type mismatch: Only numeric, abtessarine, or gabtessarine objects can be assigned.');
            end
            
        case '.'
            % 2. Property assignment: obj.A1 = val
            % Delegate to MATLAB's built-in function for maximum speed
            obj = builtin('subsasgn', obj, S, val);
            
        case '{}'
            % 3. Cell indexing block
            error('gabtessarine:subsasgn:CellNotSupported', ...
                  'Cell assignment {} is strictly unsupported for memory-contiguous gabtessarine manifolds.');
    end
end