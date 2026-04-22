% Hypercomplex Alpha-Beta Tessarine Toolbox
% Version 1.1.0 (R2026a) 22-Apr-2026
%
% Environment Configuration & Matrix Generation
%   abt2gabt                 - Constructs an 8D gabtessarine from two abtessarine objects.
%   abteye                   - Creates an abtessarine identity matrix.
%   abtones                  - Creates an abtessarine array of ones.
%   abtpdm                   - Generates random Hermitian positive definite abtessarine matrices.
%   abtrand                  - Uniformly distributed random abtessarine matrices.
%   abtrandn                 - Normally distributed random abtessarine matrices.
%   abtzeros                 - Creates an abtessarine zeros array.
%   gabteye                  - Creates a gabteye identity matrix.
%   gabtrand                 - Uniformly distributed random 8D gabtessarine matrices.
%   gabtrandn                - Normally distributed random 8D gabtessarine matrices.
%   gabtzeros                - Creates a gabtessarine zeros array.
%   getabtessarine           - Retrieves current alpha/beta configuration and environment state.
%   setabtessarine           - Configures global alpha/beta parameters for the HPC environment.
%
% Core 4D Algebra (@abtessarine)
%   abtessarine    - Constructor for the 4-dimensional alpha-beta tessarine object.
%   associated     - Computes the real/complex isomorphic matrix representation.
%   augmented      - Constructs the augmented covariance matrix for WL modeling.
%   cat            - Concatenate arrays along specified dimension.
%   chol           - Cholesky factorization for Hermitian positive definite matrices.
%   conj_i         - Directional involution along the i-axis.
%   conj_j         - Directional involution along the j-axis.
%   conj_k         - Directional involution along the k-axis.
%   ctranspose     - Conjugate (Hermitian) transposition (').
%   det            - Isomorphic matrix determinant.
%   diag           - Diagonal elements or construct diagonal matrices.
%   diff           - Differences and approximate derivatives.
%   disp           - Formatted console display.
%   eig            - Full eigenvalues and eigenvectors computation.
%   eigs           - Subset of eigenvalues and eigenvectors for large matrices.
%   hermitian      - Parameterized Hermitian transposition.
%   horzcat        - Horizontal concatenation [,].
%   inv            - Matrix inverse via L1 cache-optimized algorithms.
%   kron           - Kronecker tensor product.
%   length         - Length of longest array dimension.
%   lu             - LU factorization with hypercomplex partial pivoting.
%   minus          - Subtraction (-).
%   mldivide       - Left matrix division (\).
%   mpower         - Matrix power (^).
%   mrdivide       - Right matrix division (/).
%   mtimes         - Matrix multiplication (*).
%   ndims          - Number of array dimensions.
%   norm           - Matrix or vector norms.
%   permute        - Reorder dimensions of N-D arrays.
%   pinv           - Moore-Penrose pseudoinverse via SVD.
%   plus           - Addition (+).
%   power          - Array power (.^).
%   prod           - Product of elements along dimensions.
%   qr             - Orthogonal-triangular QR decomposition.
%   repmat         - Replicate and tile matrices.
%   reshape        - Change shape of array without changing data.
%   size           - Array dimensions.
%   sqrtm          - Principal matrix square root.
%   squeeze        - Remove singleton dimensions.
%   subsasgn       - Subscripted assignment X(i,j) = Y.
%   subsref        - Subscripted reference Y = X(i,j).
%   sum            - Sum of elements along dimensions.
%   svd            - Singular value decomposition.
%   svds           - Subset of singular values and vectors.
%   times          - Array multiplication (.*).
%   trace          - Sum of diagonal elements.
%   transpose      - Geometric non-conjugate transposition (.').
%   uminus         - Unary minus (-).
%   uplus          - Unary plus (+).
%   vertcat        - Vertical concatenation [;].
%
% Extended 8D Algebra (@gabtessarine)
%   disp           - 8D formatted console display.
%   gabtessarine   - Constructor for the 8-dimensional generalized object.
%   horzcat        - 8D horizontal concatenation.
%   inv            - Computes the 8D inverse matrix.
%   kron           - 8D Kronecker tensor product.
%   minus          - 8D subtraction.
%   mtimes         - 8D matrix multiplication.
%   plus           - 8D addition.
%   size           - 8D array dimensions.
%   sqrtm          - Computes the 8D principal matrix square root.
%   subsasgn       - 8D subscripted assignment.
%   subsref        - 8D subscripted reference.
%   times          - 8D array multiplication.
%   uminus         - 8D unary minus.
%   vertcat        - 8D vertical concatenation.