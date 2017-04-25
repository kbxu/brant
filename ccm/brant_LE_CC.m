function [LE, CC] = brant_LE_CC(gMatrix_CC, gMatrix_LE, LE_ind, CC_ind)
% adapted from CCM_ClusteringCoef and CCM_LEfficient
% works only for binary symmetric network
% LE_ind: 1, 0 -- calculate local efficiency when assigned to 1
% CC_ind: 1, 0 -- calculate clustering coefficient when assigned to 1

% Local efficiency and clustering coefficient
% Refer:
%   V.Latora,etc. Efficient Behavior of Small-World Networks.(Phys.Rev,lett.2001) 
%  [1] Barrat et al. (2004) The architecture of the complex weighted networks. 
%  [2] Wasserman,S.,Faust,K.(1994) Social Network Analysis: Methods and
%      Applications.
%  [3] Tore Opsahl and Pietro Panzarasa (2009). "Clustering in Weighted 
%      Networks". Social Networks31(2).

LE = [];
CC = [];

if ~any([LE_ind, CC_ind])    
    return;
end

N = size(gMatrix, 1);
gMatrix(1:(N+1):end) = 0;

if (CC_ind == 1)
    CC.nodal = zeros(N, 1);
end

if (LE_ind == 1)
    LE.nodal = zeros(N, 1);
end

gBin = gMatrix > 0;%Ensure binary network
for m = 1:N
    temp = gBin(gBin(m, :), gBin(m, :));
    Num = size(temp, 1);
    if(Num > 1),
        num_tot = Num * (Num - 1);
        
        if (CC_ind == 1)
            CC.nodal(m) = sum(temp(:)) / num_tot;
        end
        
        if (LE_ind == 1)
            effi = 1 ./ graphallshortestpaths(sparse(temp), 'Directed', false);
            effi(~isfinite(effi)) = 0;
            LE.nodal(m) = sum(effi(:)) / num_tot;
        end
    end
end

if CC_ind == 1
    CC.global = mean(CC.nodal);
end

if LE_ind == 1
    LE.global = mean(LE.nodal);
end
