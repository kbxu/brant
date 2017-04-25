function [B_global,B] = CCM_SBetweenness(gMatrix, bType, gType)
% CCM_SBetweenness computes shorest-path betweenness about edges or nodes.
% Input:
%	gMatrix	    symmetric adjacency matrix
%   bType       type of betweenness:  'edge' and 'vertex'(default).
%   gType       type of graph: 'binary' and 'weighted'(default).
% Usage:
%	B = CCM_SBetweenness(gMatrix, 'vertex', 'binary') 
%   B = CCM_SBetweenness(gMatrix) returns betweenness on each node.
% Example:
%	G = CCM_TestGraph1('nograph');
%   B = CCM_SBetweenness(G, 'vertex', 'binary');
% Note:
%	(1) output B is a Nx1 array using default setting(N is the number of nodes).
%   (2) complexity: o(N) for 'binary' ,and o(N^2) for 'weighted'.
% Refer:
%   [1] Ulrik Barandes  A faster algorithm for betweennes centrality.
%	[2] M.E.J.Newman    Finding and evaluating community structure in network
% See also bfs,  CCM_RBetweenness

% Write by: Hu Yong, Nov,2010 
% Revised : Dec,2010
% Last revised: Mar, 2011
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

narginchk(1, 3);
if(nargin < 2),        bType = 'vertex';    gType = 'weighted';
elseif(nargin < 3),    gType = 'weighted';   end

N = size(gMatrix,1);%number of nodes
%gMatrix(1:(N+1):end) = 0;%clear self-edges

switch(upper(bType(1:4)))
case 'VERT'%Vertex-betweenness
    B = zeros(N, 1);
    for s = 1:N
        % Generated a tree from source node s
        [dist, pred, seq, sigma] = bfs(gMatrix, s, gType);
        seq(seq < 1) = -1;%avoid disconnected case
        
        delta = zeros(N,1);        
        % seq returns search order of non-increasing distance from soure
        while(any(seq > 0))
            I = find(seq > 0, 1, 'last');     %index
            node  = seq(I);   seq(I) = -1;    %select and dequeue
            predn = nonzeros(pred(node,:));   %predecessor of node
            delta(predn) = delta(predn) + sigma(predn)*(1+delta(node))/sigma(node);

            % Note! the betweenness of source node is zero!
            if(node ~= s),   B(node) = B(node) + delta(node);    end
        end
    end
    
case 'EDGE'%Edge-betweenness
	B = zeros(N, N);
	for s = 1:N
        % Generated a tree from source node s
        [dist, pred, seq, sigma] = bfs(gMatrix, s, gType);
        seq(seq == 0) = -1;%avoid disconnected case
        
        delta = zeros(N,1);
        % seq returns search order of non-increasing distance from soure
        while(any(seq > 0))        
            I = find(seq > 0, 1, 'last');     %index
            node  = seq(I);   seq(I) = -1;    %select and dequeue
            predn = nonzeros(pred(node,:));   %predecessor of node
            % Update delta
            delta(predn) = delta(predn) + sigma(predn)*(1+delta(node))/sigma(node);

            % Note! the betweenness of source node is zero!
            if(node ~= s),   
                B(predn, node) = B(predn, node) + sigma(predn)*(1+delta(node))/sigma(node);
            end
        end
    end 
% Error Msg
otherwise, error('Wrong btype, just for "vertex" or "Edge".');
end
B = 2*B./((N-1)*(N-2));        	%normalised
B_global = mean(B(:));
%%%