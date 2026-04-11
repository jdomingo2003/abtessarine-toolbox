function [varargout] = size(obj, varargin)
% SIZE Overloads the size function for abtessarine objects.
%
%   D = SIZE(X) returns a row vector containing the dimensions of the 
%   abtessarine array X.
%
%   [M, N] = SIZE(X) returns the number of rows and columns in 
%   separate output variables.
%
%   K = SIZE(X, DIM) returns the size of the dimension specified 
%   by the scalar DIM.

%   IMPLEMENTATION STRATEGY:
%   Since the structural integrity of the abtessarine object requires 
%   all four components (A, B, C, D) to maintain identical dimensions, 
%    this function delegates the request to the principal component 'A'. 
%   This ensures 100% compatibility with MATLAB's native array 
%   handling and indexing logic.

%   See also LENGTH, NDIMS, RESHAPE.

    % Delegate the native size function to the principal component.
    % Utilizing varargout and varargin ensures support for all native 
    % MATLAB signatures (e.g., multi-output or dimension-specific queries).
    [varargout{1:nargout}] = size(obj.A, varargin{:});
    
end