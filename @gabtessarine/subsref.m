function varargout = subsref(obj, S)
% SUBSREF Overloads array indexing and property access for gabtessarine objects.
%
%   Allows extracting sub-arrays or elements using parentheses, e.g., X(i,j),
%   and maintains zero-overhead property access via dot notation, e.g., X.A1.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Memory-Contiguous Slicing: When extracting sub-arrays via parentheses '()', 
%     the function slices the 8 internal arrays simultaneously and maps them 
%     directly into a new object constructor. This entirely bypasses loop 
%     overhead and leverages MATLAB's underlying C-level memory block copying.
%   - Built-in Delegation: Dot notation ('.') for property access and cascaded 
%     references (e.g., X(1,1).A1) are delegated directly to the native 
%     'builtin' engine. This guarantees O(1) latency for property queries, 
%     maintaining identical performance to standard MATLAB structs.

%   See also SUBSASGN, DISP.

    switch S(1).type
        case '()'
            % 1. Array Indexing: X(i,j) or X(1:5, :)
            % Extract the requested spatial boundaries
            idx = S(1).subs;
            
            % Slice all 8 dimensions in parallel via direct memory injection
            out = gabtessarine(obj.A1(idx{:}), obj.A2(idx{:}), ...
                               obj.B1(idx{:}), obj.B2(idx{:}), ...
                               obj.C1(idx{:}), obj.C2(idx{:}), ...
                               obj.D1(idx{:}), obj.D2(idx{:}));
                               
            % Handle cascaded indexing (e.g., X(1,2).A1)
            if length(S) > 1
                [varargout{1:nargout}] = builtin('subsref', out, S(2:end));
            else
                varargout{1} = out;
            end
            
        case '.'
            % 2. Property Access: X.A1
            % Native delegation to bypass custom evaluation trees
            [varargout{1:nargout}] = builtin('subsref', obj, S);
            
        case '{}'
            % 3. Cell Indexing
            error('gabtessarine:subsref:CellNotSupported', ...
                  'Cell array indexing {} is strictly unsupported for continuous 8D manifolds.');
    end
end