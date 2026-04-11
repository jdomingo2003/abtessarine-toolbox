function Z = abtrand(varargin)
% ABTRAND Uniformly distributed pseudo-random numbers for 4D abtessarine arrays.
%
%   Z = abtrand(N) returns an N-by-N abtessarine matrix with random entries
%   drawn from a standard uniform distribution on the open interval (0,1).
%   Z = abtrand(M, N) returns an M-by-N abtessarine random matrix.
%
%   IMPLEMENTATION STRATEGY & HPC OPTIMIZATIONS:
%   - Statistical Independence: Unlike null-space initialization, stochastic 
%     manifolds require strictly independent orthogonal planes. The algorithm 
%     executes four separate multithreaded calls to MATLAB's C-level PRNG.
%   - Direct Vectorization: Bypasses element-wise iterative assignment by 
%     generating dense random spatial blocks directly in continuous memory, 
%     ensuring optimal cache-line utilization.

    % Generate independent pseudo-random arrays for each orthogonal dimension
    A = rand(varargin{:});
    B = rand(varargin{:});
    C = rand(varargin{:});
    D = rand(varargin{:});
    
    % Construct and return the 4D stochastic manifold
    Z = abtessarine(A, B, C, D);
end