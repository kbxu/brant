function [dist, pred, seq, sigma] = bfs(gMatrix, s, gtype)
% bfs used to get a tree by algorithm "breadth first search".
% Input:
%	gMatrix	    symmetric adjacency matrix
%   s           source node, a integer
%   gtype  type of graph: 'binary' and 'weighted'(default).
% Usage:
%	[dist ,pred, seq, sigma] = bfs(gMatrix, s, gtype) returns vector 'dist'
%   record distance from source node,the corresponding predecessors'pred',
%   order of search 'seq',and number of shortest paths from source node.
% Example:
%	G = CCM_TestGraph1('nograph');
%   [dist, pred, seq, sigma] = bfs(G, 1, 'binary');
% Note:
%	(1) dist and sigma are vectors,but pred is a matrix.
%   (2) bfs is alway as a subfunction of CCM_SBetweenness.
%   (3) in some mean,bfs was similar to the function "graphtraverse".
% Refer:
%   Ulrik Barandes  A faster algorithm for betweennes centrality.
% See also CCM_SBetweenness, GRAPHTRAVERSE

% Write by: Hu Yong,Nov,2010 
% Revised : Dec,2010
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

narginchk(2, 3);
if(nargin < 3),    gtype  = 'weighted';   end
%if(issparse(gMatrix)), gMatrix = sparse(gMatrix);  end
N = length(gMatrix);

% Preallocate
seq   = zeros(N, 1);                %order of search
pred  = sparse(N, N);               %non-zero value in each column is predecessors
dist  = inf*ones(N, 1);dist(s) = 0; %distance of the short path from source
sigma = zeros(N, 1); sigma(s)= 1;   %record the number of shortest path  
quence= zeros(N, 1); quence(1) = s; %node adding sequence

steps   = 0;
switch(upper(gtype))
case 'BINARY'% Binary & BFS method
	% Labelling and compute the depth
    while(any(quence > 0))
        steps = steps + 1;
        node = quence(steps);%select 
        quence(steps) = -1;   %and dequeue, record as -1
        seq(steps) = node;   %adding to sequence          
            
        neigbor = find(gMatrix(node,:));    %neigbor nodes
        for i = neigbor
            % Node i found for the first time?
           	if(isinf(dist(i))),
                quence(find(quence,1,'last')+1)  = i;
               	dist(i) = dist(node) + 1;
            end
                
         	% Shortest path to i via node?
          	if(dist(i)  == dist(node) + 1)
            	sigma(i) = sigma(i) + sigma(node);
               	pred(i, nnz(pred(i,:))+1) = node;%node is predecessor of i
            end
        end
   	end
  
case 'WEIGHTED'% Weighted & Dijkstra method
	% Labelling and compute the Distance
    while(any(quence > 0))
        tmp = quence(quence > 0);
        [I, J] = min(dist(tmp));
        node   = tmp(J);%coord of current node        
        quence(quence == node) = -1;%and dequeue 
        
        steps  = steps + 1;
        seq(steps) = node;%adding to sequence 

        % Compute the sigma-vaule
        for i = 1:nnz(pred(node,:))
            sigma(node) = sigma(node) + sigma(pred(node,i));
        end
            
        neigbor  = find(gMatrix(node,:));%neigbor nodes
       	for i = neigbor
           	flag = 0;
                
          	% Node i found for the first time ?
           	if(isinf(dist(i))),
                quence(find(~quence,1)) =i;
               	dist(i)   = dist(node) + gMatrix(node,i);
               	pred(i,1) = node;%label
               	flag      = 1;
            end
                
         	% Shortest path to i may via CurrentNode ?
         	if(dist(i) > dist(node) + gMatrix(node,i))
            	dist(i) = dist(node) + gMatrix(node,i);
               	pred(i,nnz(pred(i,:))) = node;%change the label
               	flag = 1;
           	end
                
           % Check label
           	if((flag ~= 1) && (dist(i)  == dist(node) + gMatrix(node,i))),
             	pred(i,nnz(pred(i,:))+1) = node;%add label
            end
        end
    end
    
otherwise% Wrong input_type
  	error('Wrong type! just for "Binary" and "Weighted"');
end
%%%