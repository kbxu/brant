function [Cp_Global, Cp_Nodal] = CCM_ClusteringCoef(gMatrix, Types)
% CCM_ClusteringCoef calculates clustering coefficients.
% Input:
%   gMatrix     adjacency matrix
%   Types       type of graph: 'binary','weighted','directed','all'(default).
% Usage:
%   [Cp_Global, Cp_Nodal] = CCM_ClusteringCoef(gMatrix, Types) returns
%   clustering coefficients for all nodes "Cp_Nodal" and average clustering
%   coefficient of network "Cp_Global".
% Example:
%   G = CCM_TestGraph1('nograph');
%   [Cp_Global, Cp_Nodal] = CCM_ClusteringCoef(G);
% Note:
%   1) one node have vaule 0, while which only has a neighbour or none.
%   2) The dircted network termed triplets that fulfill the follow condition
%      as non-vacuous: j->i->k and k->i-j,if don't satisfy with that as
%      vacuous, just like: j->i,k->i and i->j,i->k. and the closed triplets
%      only j->i->k == j->k and k->i->j == k->j.
%   3) 'ALL' type network code from Mika Rubinov's BCT toolkit.
% Refer:
%  [1] Barrat et al. (2004) The architecture of the complex weighted networks.
%  [2] Wasserman,S.,Faust,K.(1994) Social Network Analysis: Methods and
%      Applications.
%  [3] Tore Opsahl and Pietro Panzarasa (2009). "Clustering in Weighted
%      Networks". Social Networks31(2).
% See also CCM_Transitivity

% Written by Yong Liu, Oct,2007
% Center for Computational Medicine (CCM),
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.
% Revise by Hu Yong, Nov, 2010

% E-mail: yliu@nlpr.ia.ac.cn
% based on Matlab 2006a
% $Revision: 1.0, Copywrite (c) 2007

% error(nargchk(1,2,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(1,2,nargin,'struct'));
else
    narginchk(1, 2);
end
if(nargin < 2),    Types = 'all';   end

N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;%Clear self-edges

Cp_Nodal = zeros(N,1);   %Preallocate
switch(upper(Types))
    case 'BINARY'%Binary network
        gMatrix = double(gMatrix > 0);%Ensure binary network
        for i = 1:N
            neighbor = (gMatrix(i,:) > 0);
            Num      = sum(neighbor);%number of neighbor nodes
            temp     = gMatrix(neighbor, neighbor);
            if(Num > 1)
                Cp_Nodal(i) = sum(temp(:))/Num/(Num-1);
            end
        end
        
    case 'WEIGHTED'% Weighted network -- arithmetic mean
        for i = 1:N
            neighbor = (gMatrix(i,:) > 0);
            n_weight = gMatrix(i,neighbor);
            Si       = sum(n_weight);
            Num      = sum(neighbor);
            if(Num > 1)
                n_weight  = ones(Num,1)*n_weight;
                n_weight  = n_weight + n_weight';
                n_weight  = n_weight.*(gMatrix(neighbor, neighbor) > 0);
                Cp_Nodal(i) = sum(n_weight(:))/(2*Si*(Num-1));
            end
        end
        
        %case 'WEIGHTED'% Weighted network -- geometric mean
        %	A  = (gMatrix~= 0);
        %	G3 = diag((gMatrix.^(1/3) )^3);)
        %	A(A == 0) = inf;  %close-triplet no exist,let CpNode=0 (A=inf)
        %	CpNode = G3./(A.*(A-1));
        
    case 'DIRECTED', % Directed network
        for i = 1:N
            inset   = (gMatrix(:,i) > 0);  %in-nodes set
            outset  = (gMatrix(i,:) > 0)'; %out-nodes set
            if(any(inset & outset))
                allset = and(inset, outset);
                % Ensure aji*aik > 0,j belongs to inset,and k belongs to outset
                total   = sum(inset)*sum(outset) - sum(allset);
                tri     = sum(sum(gMatrix(inset, outset)));
                Cp_Nodal(i) = tri./total;
            end
        end
        
        %case 'DIRECTED', % Directed network -- clarity format (from Mika Rubinov, UNSW)
        %	G  = gMatrix + gMatrix';           %symmetrized
        %	D  = sum(G,2);                     %total degree
        %	g3 = diag(G^3)/2;                  %number of triplet
        %	D(g3 == 0) = inf;                  %3-cycles no exist,let Cp=0
        %	c3 = D.*(D-1) - 2*diag(gMatrix^2); %number of all possible 3-cycles
        %	Cp_Nodal   = g3./c3;
        
        %Note: Directed & weighted network (from Mika Rubinov)
    case 'ALL',%All type
        A  = (gMatrix~= 0);                 %adjacency matrix
        G  = gMatrix.^(1/3) + (gMatrix.').^(1/3);
        D  = sum(A + A.',2);                %total degree
        g3 = diag(G^3)/2;                   %number of triplet
        D(g3 == 0) = inf;                   %3-cycles no exist,let Cp=0
        c3 = D.*(D-1) - 2*diag(A^2);
        Cp_Nodal   = g3./c3;
    otherwise,%Eorr Msg
        error('Type only four: "Binary","Weighted","Directed",and "All"');
end
% Cp_Global = sum(Cp_Nodal)/N; % commented by kb
Cp_Global = mean(Cp_Nodal);
%%%