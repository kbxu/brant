function [D_Global, D_Nodal] = CCM_AvgShortestPath(gMatrix, s, t)
% CCM_AvgShortestPath generates the shortest distance matrix of source nodes 
% indice s to the target nodes indice t.
% Input:
%   gMatrix     symmetry binary connect matrix or weighted connect matrix
%   s           source nodes, default is 1:N
%   t           target nodes, default is 1:N
% Usage:
%   [D_Global, D_Nodal] = CCM_AvgShortestPath(gMatrix) returns the mean
%   shortest-path length of whole network D_Global,and the mean shortest-path
%   length of each node in the network
% Example:
%   G = CCM_TestGraph1('nograph');
%   [D_Global, D_Nodal] = CCM_AvgShortestPath(G);
% See also dijk, MEAN, SUM

% Written by Yong Liu, Oct,2007
% Modified by Hu Yong, Nov 2010
% Center for Computational Medicine (CCM), 
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2007

% ###### Input check #########
% error(nargchk(1,3,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(1,3,nargin,'struct'));
else
    narginchk(1, 3);
end
N = length(gMatrix);
if(nargin < 2 || isempty(s)),    s = (1:N)';
else    s = s(:);   end

if(nargin < 3 || isempty(t)),    t = (1:N)';
else   t = t(:);    end

% Calculate the shortest-path from s to all node
D = dijk(gMatrix,s);%D(isinf(D)) = 0;
D = D(:,t);         %To target nodes

D_Nodal  = (sum(D,2)./sum(D>0,2));
% D_Nodal(isnan(D_Nodal)) = [];
D_Global = mean(D_Nodal);
