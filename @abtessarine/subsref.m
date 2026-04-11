function varargout = subsref(obj, S)
% SUBSREF Overloads indexing for abtessarine objects.
%
%   X(idx) extracts a sub-array or individual element from the 
%   abtessarine object, returning a new abtessarine instance.
%
%   X.prop allows direct access to internal properties (A, B, C, D).
%
%   IMPLEMENTATION STRATEGY:
%   The function implements "Synchronous Extraction" by slicing all four 
%   internal hypercomplex components (A, B, C, D) simultaneously using 
%   the requested indices. To maintain high-performance benchmarks, 
%   direct property access via dot notation is delegated to MATLAB's 
%   native C++ built-in engine.

%   See also SUBSASGN, DISP.

    switch S(1).type
        case '()'
            % --- 1. INDEXED EXTRACTION: out = X(idx) ---
            idx = S(1).subs;
            
            % Construct a new abtessarine object from the sliced components.
            % All 4 internal arrays are indexed simultaneously to ensure 
            % structural alignment.
            out = abtessarine(obj.A(idx{:}), obj.B(idx{:}), ...
                              obj.C(idx{:}), obj.D(idx{:}));
                          
            % Handle Command Chaining (e.g., val = X(1,2).A)
            if length(S) > 1
                % Recursively delegate the remaining index chain
                [varargout{1:nargout}] = builtin('subsref', out, S(2:end));
            else
                varargout{1} = out;
            end
            
        case '.'
            % --- 2. PROPERTY ACCESS: val = X.prop ---
            % Direct delegation to built-in for zero-overhead performance
            [varargout{1:nargout}] = builtin('subsref', obj, S);
            
        case '{}'
            % --- 3. CELL ACCESS (UNSUPPORTED) ---
            error('abtessarine:subsref:CellNotSupported', ...
                  'Cell array indexing ({}) is undefined for the abtessarine class.');
    end
end