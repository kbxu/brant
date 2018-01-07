function [s, l, g] = brant_SmallWorldness(G, simT, gType, kc, par_ind)


N = length(G);   G(1:(N+1):end) = 0;%clear self-edges

% Measure in real network

lp_real = brant_ShortestPathLength(G);
cp_real = brant_ClusteringCoef(G);

% lp_real = CCM_AvgShortestPath(G, 1:N);
% cp_real = CCM_ClusteringCoef(G, gType);

lp_rand = zeros(simT, 1);
cp_rand = zeros(simT, 1);

if (par_ind == 1)
    parfor i = 1:simT       
        newg = brant_randomizeGraph(G, kc);
        lp_rand(i) = brant_AveShortestPathLength(newg);
        cp_rand(i) = brant_ClusteringCoef(newg);
    end
else
    for i = 1:simT       
        newg = brant_randomizeGraph(G, kc);
        lp_rand(i) = brant_AveShortestPathLength(newg);
        cp_rand(i) = brant_ClusteringCoef(newg);
    end
end
    
% newg = G;
% T = nnz(G) * 100; % min(nnz(G), 100);%times of swap, different from simT
% if(csign > 0),
%     parfor i = 1:simT       
%         newg = brant_randomizeGraph_kc(G);
% %         newg = randomizeGraph_kc(G, T, gType);%randomize netowrk
% %         lp_rand(i) = CCM_AvgShortestPath(newg, 1:N);
%         lp_rand(i) = brant_globalefficiency(newg);
%         cp_rand(i) = brant_ClusteringCoef(newg);
% %         cp_rand(i) = CCM_ClusteringCoef(newg, gType);
%     end
% else
%     for i = 1:simT
%         newg = randomizeGraph(newg, T, gType);%randomize netowrk
%         lp_rand(i) = CCM_AvgShortestPath(newg, 1:N);
%         cp_rand(i) = CCM_ClusteringCoef(newg, gType);
%     end
% end
% disp([lp_rand, cp_rand]);
% lp_rand(1:30) = [];%eliminate suspect vaule 
% cp_rand(1:30) = [];
lp_rand = mean(lp_rand);
cp_rand = mean(cp_rand);

% SmallWorldness
l = lp_real / lp_rand;%lambada
g = cp_real / cp_rand;%gamma
s = g / l;            %sigma
