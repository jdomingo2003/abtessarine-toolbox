function obj_out = conj_k(obj)
% CONJ_K Computes the directional involution with respect to the 'k' axis.
%
%   X_k = conj_k(X) returns the structural involution X^k, a fundamental 
%   topological transformation utilized in widely linear signal processing 
%   and augmented statistics.
%
%   Analytically, this mapping preserves the real and 'k' components 
%   while strictly inverting the signs of the 'i' and 'j' components.

%   See also CONJ_I, CONJ_J, CTRANSPOSE, HERMITIAN.

% --- DIRECT MEMORY ALLOCATION ---
    % Topological involution independent of algebraic rules (alpha, beta).
    obj_out = abtessarine(obj.A, -obj.B, -obj.C, obj.D);
end