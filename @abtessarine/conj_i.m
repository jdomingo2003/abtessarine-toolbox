function obj_out = conj_i(obj)
% CONJ_I Computes the directional involution with respect to the 'i' axis.
%
%   X_i = conj_i(X) returns the structural involution X^i, a fundamental 
%   topological transformation utilized in widely linear signal processing 
%   and augmented statistics.
%
%   Analytically, this mapping preserves the real and 'i' components 
%   while strictly inverting the signs of the 'j' and 'k' components.

%   See also CONJ_J, CONJ_K, CTRANSPOSE, HERMITIAN.

    % --- DIRECT MEMORY ALLOCATION ---
    % Topological involution independent of algebraic rules (alpha, beta).
    obj_out = abtessarine(obj.A, obj.B, -obj.C, -obj.D);
end