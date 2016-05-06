function [EGlobal, ENodal, D_Global, D_Nodal] = CCM_GEfficiency(gMatrix)
% CCM_GEfficiency computes the global-efficiency of networks
% Input:
%   gMatrix     connect matrix
% Output:
%   EGlobal     the global efficiency of whole network
%   ENodal      the global efficiency of each node
%   D_Global	the mean shortest-path length of whole network
%   D_Nodal     the mean shortest-path length of each node
% Usage:
%   [EGlobal,ENodal] = CCM_GEfficiency(gMatrix) returns the average global
%   efficient of network,and node-efficient.
% Example:
%   G = CCM_TestGraph1('nograph');
%   [EGlobal, ENodal] = CCM_GEfficiency(G);
% Refer:
%   [1] Achard & Bullmore. Efficiency and cost of economical brain functional 
%       networks. (Plos computational biology)
%   [2] Latora V & Marchiori. Economic small-world behavior in weighted
%       networks.(2003)
% See also CCM_LEfficiency, dijk, MEAN, SUM

% Write by: Yong Liu,Oct,2007
% Revised : Hu Yong, Nov,2010
% Email   : yliugmj@gmail.com
% Center for Computational Medicine(CCM)
% National Laboratory of pattern Recognition
% Institute of Automation Chinese Academy of Sciences
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2007

N = length(gMatrix);

% Calculate the shortest-path from s to all node
D = dijk(gMatrix, 1:N);    % D(isinf(D)) = 0;

% Shortest-path length
D_Nodal  = sum(D,2)/(N-1); % D_Nodal(isnan(D_Nodal)) = [];
D_Global = mean(D_Nodal);

% Global efficiency
Effi = 1./D;
Effi(1:(N+1):end) = 0;     % set diagonal to zeros

ENodal  = sum(Effi,1)'/(N-1);
EGlobal = sum(ENodal)/N;
