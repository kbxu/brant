function [NDGlobal,NDNodal] = CCM_NeighborDegree(gMatrix,graph_type)
% CCM_NeighborDegree computes average degree of neighbors of nodes in graph
% Input:
%	gMatrix     symmetry connect binary matrix  
%   graph_type  'binary'(default),'weighted','directed','all' for all type
% Usage:
%	[NDGlobal,NDNodal] = CCM_NeighborDegree(gMatrix,graph_type)
%	returns the mean average-neighbor-degree "NDGlobal",and average
%	neighbor degree of each node "NDNodal".
% Example:
%	gMatrix = CCM_TestGraph1('nograph');
%   [NDGlobal,NDNodal] = CCM_NeighborDegree(gMatrix,graph_type);
% Refer:
%	[1] Alain.Barrat  The architecture of complex weighted networks
%   [2] Mikail.Rubinov Complex network measures of brain connectivity: Uses
%       and interpretations.
% See also SUM,MEAN

% Written by Hu Yong, Jan,2011
% E-mail: carrot.hy2010@gmail.com
% based on Matlab 2008a
% Version (1.0)
% Copywrite (c) 2011

% ###### Input check #########
if nargin < 2
    graph_type = 'binary';
end

N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;       %clear self-edges
% ###### End check ###########

if(strcmpi(graph_type(1),'b') || strcmpi(graph_type(1),'w'))%binary or weighted
    NDNodal = gMatrix * sum(gMatrix,2)./sum(gMatrix,2);
    NDGlobal = mean(NDNodal);
elseif(strcmpi(graph_type(1),'d') || strcmpi(graph_type(1),'a'))%directed or all type
    gMatrix = gMatrix + gMatrix';
    NDNodal = gMatrix * sum(gMatrix,2)./(2*sum(gMatrix,2));
    NDGlobal = mean(NDNodal);
else
    error('Wrong graph_type!');
end