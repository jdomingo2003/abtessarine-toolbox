function Xa = augmented(X)
% AUGMENTED Constructs the augmented matrix representation for widely linear processing.
%
%   Xa = augmented(X) returns the augmented abtessarine object by performing 
%   a vertical concatenation of the original array X with its three principal 
%   directional involutions: X^i, X^j, and X^k.
%
%   Given an N-by-M abtessarine array X, the output Xa is a (4*N)-by-M 
%   array structured as follows:
%       [ X   ]
%       [ X^i ]
%       [ X^j ]
%       [ X^k ]
%
%   This structural augmentation is essential in augmented statistics for 
%   the precise computation of the full hypercomplex covariance matrix.

%   See also ABTESSARINE, CONJ_I, CONJ_J, CONJ_K.

    % --- DIRECT MEMORY ALLOCATION ---
    % Vertical concatenation bypasses intermediate function calls to optimize 
    % computational throughput. The sign distribution is strictly governed by 
    % the algebra's topological involutions:
    % X   ->  A,  B,  C,  D
    % X^i ->  A,  B, -C, -D
    % X^j ->  A, -B,  C, -D
    % X^k ->  A, -B, -C,  D
    
    A_aug = [X.A;  X.A;  X.A;  X.A];
    B_aug = [X.B;  X.B; -X.B; -X.B];
    C_aug = [X.C; -X.C;  X.C; -X.C];
    D_aug = [X.D; -X.D; -X.D;  X.D];
    
    Xa = abtessarine(A_aug, B_aug, C_aug, D_aug);
end