function obj_out = conj_j(obj)
% CONJ_J Computes the directional involution with respect to the 'j' axis.
%
%   X_j = conj_j(X) returns the structural involution X^j, a fundamental 
%   topological transformation utilized in widely linear signal processing 
%   and augmented statistics.
%
%   Analytically, this mapping preserves the real and 'j' components 
%   while strictly inverting the signs of the 'i' and 'k' components.

%   See also CONJ_I, CONJ_K, CTRANSPOSE, HERMITIAN.

% --- DIRECT MEMORY ALLOCATION ---
    % Topological involution independent of algebraic rules (alpha, beta).
    obj_out = abtessarine(obj.A, -obj.B, obj.C, -obj.D);
end