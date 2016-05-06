function [NDGlobal, NDNodal] = CCM_AvgNeighborDegree(gMatrix)
% Compute average neighbors' degree of nodes in network.
% Input:
%	gMatrix     adjacent matrix
% Usage:
%	[NDGlobal, NDNodal] = CCM_AvgNeighborDegree(gMatrix)
%	returns the mean average-neighbor-degree "NDGlobal",and 
%   average	neighbor degree of each node "NDNodal".
% Example:
%	gMatrix = CCM_TestGraph1('nograph');
%   [NDGlobal, NDNodal] = CCM_AvgNeighborDegree(gMatrix);
% Refer:
%	[1] Alain.Barrat  The architecture of complex weighted networks
%   [2] Mikail.Rubinov Complex network measures of brain connectivity: Uses
%       and interpretations.
% See also SUM, MEAN

% Written by Hu Yong, Jan,2011
% E-mail: carrot.hy2010@gmail.com
% based on Matlab 2008a
% Version (1.0)
% Copywrite (c) 2011

if(nargin>1), error('Too many input.'); end
gMatrix(1:(length(gMatrix)+1):end) = 0;%Clear self-edges

gMatrix  = gMatrix + gMatrix';
NDNodal  = gMatrix * sum(gMatrix,2)./(2*sum(gMatrix,2));
NDGlobal = mean(NDNodal);