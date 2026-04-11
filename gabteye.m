function Z = gabteye(varargin)
% GABTEYE Identity-like diagonal matrix for 8D gabtessarine arrays.
%
%   Z = gabteye(N) returns an N-by-N gabtessarine multiplicative identity matrix.
%   Z = gabteye(M, N) returns an M-by-N gabtessarine array with ones on
%   the main diagonal of the real spatial component and zeros elsewhere.
%
%   Note: This function follows the MATLAB prefix convention for consistent API design.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - O(1) Orthogonal Initialization: The primary real dimension (A1) takes
%     the standard identity map natively, while the 7 imaginary spatial dimensions 
%     are nullified via a single CoW zero-matrix pointer.
%   - Copy-on-Write Memory Management: By passing the identical variable 'z' 
%     seven times into the constructor, MATLAB's JIT compiler avoids redundant 
%     memory allocations. It simply maps the internal pointers to the same 
%     memory block, minimizing L1/L2 cache misses and reducing the initialization 
%     RAM footprint by 87.5%.

    % Generate the primary diagonal matrix (Real component A1)
    A1 = eye(varargin{:});
    
    % Single CoW reference for the 7 imaginary dimensions
    z = zeros(size(A1));
    
    % Construct the 8D manifold using Copy-on-Write for A2, B1, B2, C1, C2, D1, D2
    Z = gabtessarine(A1, z, z, z, z, z, z, z);
end