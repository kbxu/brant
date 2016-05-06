function [DegreeGlobal, DegreeNodal] = CCM_Degree(gMatrix)
% CCM_Degree calulates node degree in graph
% Input:
%	gMatrix    symmetry connect binary matrix  
% Usage:
%	[DegreeGlobal, DegreeNodal] = CCM_Degree(gMatrix) returns the mean
%	degree of the network,namely DegreeGlobal,and the degree of each node.
% Example:
%	gMatrix = CCM_TestGraph1('nograph');
%   [DegreeGlobal, DegreeNodal] = CCM_Degree(gMatrix);
% Note:
%	1)Actually,if the network is directed,then DegreeNodal depicts the 
%     in-degree, and DegreeGlobal represents the mean of in-degree.
%   2)if the network is weighted,then degree is weighted-degree.
% Refer:
%	[1] http://en.wikipedia.org/wiki/Degree_(graph_theory)
%   [2] M.E.J.Newman  Analysis of weighted networks(2004)
% See also SUM,MEAN

% Written by Yong Liu, Oct,2007
%   Revised by Hu Yong,Dec,2010
% Center for Computational Medicine (CCM),Institute of Automation,Chinese 
% Academy of Sciences (IACAS), China.
% E-mail: yliu@nlpr.ia.ac.cn // liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007

gMatrix(1:(length(gMatrix)+1):end) = 0;%Clear self-edges
DegreeNodal  = sum(gMatrix)';
DegreeGlobal = mean(DegreeNodal);
%%%