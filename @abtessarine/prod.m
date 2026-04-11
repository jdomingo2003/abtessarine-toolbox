function P = prod(V)
% PROD Product of array elements for abtessarine objects.
%
%   P = PROD(V) computes the product of the elements of V along the first 
%   non-singleton dimension. For vectors, it returns the total product. 
%   For matrices, it returns a row vector containing the product of each column.
%
%   REMARKS:
%   This implementation adheres to standard MATLAB dimensional heuristics. 
%   It requires the element-wise multiplication operator (.*) to be 
%   defined via 'times.m' within the abtessarine class.
%
%   METHODOLOGY:
%   The function utilizes dynamic subscript indexing to traverse the 
%   specified dimension, performing cumulative Hadamard-like products 
%   within the algebraic space defined by the structural constants.

%   See also SUM, DIFF, TIMES, MTIMES.

    % --- 1. DIMENSIONAL ANALYSIS ---
    % Identifies the first non-singleton dimension to mimic native behavior
    dim = find(size(V.A) > 1, 1);
    
    % Default to the first dimension for scalar objects or 1x1 arrays
    if isempty(dim)
        dim = 1; 
    end
    
    % Retrieve the cardinality along the operating dimension
    nElements = size(V.A, dim);
    
    % --- 2. BOUNDARY CASE HANDLING ---
    % Returns the multiplicative identity if the input array is empty
    if nElements == 0
        P = abtessarine(ones(size(V.A)), zeros(size(V.B)), ...
                       zeros(size(V.C)), zeros(size(V.D)));
        return;
    end
    
    % --- 3. DYNAMIC SLICING PREPARATION ---
    % Initialize subscript cell array for multidimensional indexing
    idx = repmat({':'}, 1, ndims(V.A));
    
    % --- 4. CUMULATIVE PRODUCT INITIALIZATION ---
    % Extract the first element/slice along the target dimension
    idx{dim} = 1;
    P = abtessarine(V.A(idx{:}), V.B(idx{:}), V.C(idx{:}), V.D(idx{:}));
    
    % --- 5. RECURSIVE MULTIPLICATION LOOP ---
    % Sequentially apply the overloaded element-wise operator (.*)
    for i = 2:nElements
        idx{dim} = i;
        next_element = abtessarine(V.A(idx{:}), V.B(idx{:}), ...
                                  V.C(idx{:}), V.D(idx{:}));
        
        % Core algebraic operation: utilizes the class-specific 'times' method
        P = P .* next_element; 
    end
end