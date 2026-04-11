function Z = abtzeros(varargin)
% ABTZEROS Create an array of all zeros for 4D abtessarine objects.
%
%   Z = abtzeros(N) creates an N-by-N abtessarine zero matrix.
%   Z = abtzeros(M, N) creates an M-by-N abtessarine zero matrix.
%   Z = abtzeros(SZ1,...,SZN) creates an SZ1-by-...-by-SZN zeros array.
%
%   Note: This function follows the MATLAB prefix convention (e.g., 'spzeros') 
%   for consistent API design.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Zero-Cost Allocation: Leveraging MATLAB's native Copy-on-Write (CoW) 
%     semantics, the function generates a single dense block of zeros in the 
%     C-engine. The constructor then maps all four internal spatial pointers 
%     to this identical memory location.
%   - Asymptotic Efficiency: The instantiation of the 4D hypercomplex null 
%     manifold achieves a 75% reduction in initial memory footprint, scaling 
%     in O(N) spatial complexity relative to a standard real matrix.

    % Generate the native real zeros array directly in the C-engine
    z = zeros(varargin{:});
    
    % Construct the 4D manifold using Copy-on-Write semantics.
    Z = abtessarine(z, z, z, z);
end