function [sp_global, sp_nodal] = brant_AveShortestPathLength(gBin)

dist = graphallshortestpaths(sparse(gBin), 'Directed', false);

N = size(dist, 1);
dist(~isfinite(dist)) = 0;
sp_global = sum(dist(:)) / (N * (N - 1));

if nargout > 1
    sp_nodal = sum(dist, 2) / (N - 1);
end