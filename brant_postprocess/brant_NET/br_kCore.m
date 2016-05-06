function [kCore,GK] = br_kCore(Graph,Node,K)
% this function is used to compute K-core  of G;
% FORMAT function [KCore, GK] = br_kCore(Graph,Node,Time)
%
% Input  Graph --- Symmetry binary connect matrix
%           K --- the Number of K
%
% Output KCore ---- a stucture of k-core
%            GK --- left G Matrix after delete the node with degree <=K

% Refer:
% Dall'Asta L, Alvarez-Hamelin I, Barrat A, Vazquez A, Vespignani A.
% Exploring networks with traceroute-like probes: Theory and simulations.
% Theoretical Computer Science 2006; 355: 6-24.
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu,July,2008
% Brainnnetome Center
% www.brainnetome.org/yongliu
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2009
% Version (1.0)
% Copywrite (c) 2013,
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also
if nargin < 1,
    error('Requires at least one input arguments');
end

% % [I J] = size(p_vector);
% if (I = 1 & J == 1)
%     error('Requires matrix first  inputs.');
% end

if nargin < 2
    K = 1;
end
% Node = zeros(1,size(Graph,1));
[I J] = find(sum(Graph)<=K);

kCore = [];
if length(J)>0
    Graph(J,:) = 0;
    Graph(:,J) = 0;
    if K==1
        Node = [];
        kCore = J;
    else
        kCore = setdiff(J,Node);
    end
end
GK = Graph;
