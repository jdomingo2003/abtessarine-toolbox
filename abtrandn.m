function Z = abtrandn(varargin)
% ABTRANDN Normally distributed pseudo-random numbers for 4D abtessarine arrays.
%
%   Z = abtrandn(N) returns an N-by-N abtessarine matrix with random entries
%   drawn from a standard normal distribution with mean 0 and variance 1.
%   Z = abtrandn(M, N) returns an M-by-N abtessarine random matrix.
%   Z = abtrandn(SZ1,...,SZN) returns an SZ1-by-...-by-SZN array of normally 
%   distributed tensors.
%
%   Note: This function follows the MATLAB prefix convention (e.g., 'sprandn') 
%   for consistent API design.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Statistical Independence: Stochastic hypercomplex manifolds require strictly 
%     independent orthogonal planes to prevent artificial dimensional correlation. 
%     The algorithm executes four separate multithreaded calls to MATLAB's C-level 
%     PRNG utilizing the Ziggurat algorithm for normal distributions.
%   - Direct Vectorization: Bypasses element-wise iterative assignment by 
%     generating dense random spatial blocks natively in continuous memory, 
%     scaling in pure O(4N) spatial complexity.

    % Generate independent normally distributed arrays for each orthogonal dimension
    A = randn(varargin{:});
    B = randn(varargin{:});
    C = randn(varargin{:});
    D = randn(varargin{:});
    
    % Construct and return the 4D stochastic manifold
    Z = abtessarine(A, B, C, D);
end