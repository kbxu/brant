function [eff_global, eff_nodal] = brant_GlobalEfficiency(gMatrix)

dist = graphallshortestpaths(sparse(gMatrix), 'Directed', false);

N = size(dist, 1);
eff_mat = 1./ dist;
eff_mat(~isfinite(eff_mat)) = 0;

eff_global = sum(eff_mat(:)) / (N * (N - 1));

if nargout > 1
    eff_nodal = sum(eff_mat, 2) / (N - 1);
end