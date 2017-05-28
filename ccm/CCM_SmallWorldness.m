function [s, l, g] = CCM_SmallWorldness(G, simT, gType, csign)
% CCM_SmallWorldness computes small-worldness of network
% Input:
%   G       adjacency matrix of Graph, no has vaule inf!
%   simT    simulative times of random network, default 100
%   gType 	type of network,'binary', 'weighted' or 'directed'(default)
%   csign   sign of connectivity, 1 for keeping connectivity, 0 for no
%           considering (default)
% Usage:
%   s = CCM_SmallWorldness(G, simT, gType, 1) returns small-worldness of
%   network, meanwhile keeping connectivity.
% Example:
%   G = CCM_TestGraph1('nograph');
%   [s, l, g] = CCM_SmallWorldness_Connected(G, 'binary', 200, 1);
% Note:
%   1) l is the ratio of clustering coefficient between real and random
%      network,g is the ratio of shortest-path length between real and random
%      network.
%   2) Approximatively,cp_rand = mean(degree)/N,
%                      lp_rand = log(N)/log(mean(degree))
%      where N is the number of nodes,degree is the degree sequence of graph.

% Refer:
%   Yong Liu etc.Disrupted small-world networks in schizophrenia(2008).
% See also CCM_AvgShortestPath, CCM_Transitivity

% Written by Hu Yong, Dec,2010
% E-mail: carrot.hy2010@gmail.com
% based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010
% See also Net_ClusteringCoefficients

if verLessThan('matlab', '7.14')
    error(nargchk(1,4,nargin,'struct'));
else
    narginchk(1, 4);
end
if(nargin < 2),       gType = 'directed';   simT = 100;   csign = 0;
elseif(nargin < 3),   simT = 100;   csign = 0;
elseif(nargin < 4),   csign = 0;
end

N = length(G);   G(1:(N+1):end) = 0;%clear self-edges

% Measure in real network
lp_real = CCM_AvgShortestPath(G, 1:N);
cp_real = CCM_ClusteringCoef(G, gType);

% Switch graph type
if(any(strcmpi(gType(1:3),{'BIN','WEI'}))),
	gType = 'Binary';
elseif(any(strcmpi(gType(1:3),{'DIR','ALL'})))
    gType = 'Directed';
end

% Measure in rand network
fprintf('\tAdding 30 simulation of random-networks before. (Only the last %d simulations count)\n', simT);
simT  = simT + 30; %adding 30 to test
lp_rand = zeros(simT, 1);   cp_rand = zeros(simT, 1);

newg = G;
T = min(nnz(G), 100);%times of swap, different from simT
if(csign > 0)
    for i = 1:simT
        fprintf('\tRandom-network simulation of small-worldness %d\n', i);
        newg = randomizeGraph_kc(newg, T, gType);%randomize netowrk
        if i > 30 % modified by kb
            lp_rand(i) = CCM_AvgShortestPath(newg, 1:N);
            cp_rand(i) = CCM_ClusteringCoef(newg, gType);
        end
    end
else
    for i = 1:simT
        fprintf('\tRandom-network simulation of small-worldness %d\n', i);
        newg = randomizeGraph(newg, T, gType);%randomize netowrk
        if i > 30 % modified by kb
            lp_rand(i) = CCM_AvgShortestPath(newg, 1:N);
            cp_rand(i) = CCM_ClusteringCoef(newg, gType);
        end
    end
end

% modified by kb
lp_rand = mean(lp_rand(31:end));
cp_rand = mean(cp_rand(31:end));

% commented by kb
% lp_rand(1:30) = [];%eliminate suspect vaule 
% lp_rand = mean(lp_rand);
% cp_rand(1:30) = [];
% cp_rand = mean(cp_rand);


% SmallWorldness
l = lp_real/lp_rand;%lambada
g = cp_real/cp_rand;%gamma
s = g/l;            %sigma