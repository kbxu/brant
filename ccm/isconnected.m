function flag = isconnected(gMatrix,s,t)
% isconnected determines the connectivity of network
% Input:
%	gMatrix	    adjacent matrix
%   s           a source node
%   t           target nodes,default is all nodes excepting source node
% Usage:
%   flag = isconnected(gMatrix) returns flag=1(true) represents network is
%   connected from some node to all nodes,otherwise flag=0(false)
%   flag = isconnected(gMatrix,s,t) returns connectivity of s -> t
% Example:
%	G    = round(rand(100));
%   flag = isconnected(G);
% Note:
%	if gMatrix denotes directed graph, what's checked is weakly connected!
% Refer:
%	Ulrik.Barandes  A faster algorithm for betweennes centrality
% See also brances,bfs

% Write by: Hu Yong,Jan,2011
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
if verLessThan('matlab', '7.14')
    error(nargchk(1,3,nargin,'struct'));
else
    narginchk(1, 3);
end
N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;       %clear self-edges
if nargin < 2
    s = unidrnd(N);
    t = 1:N;
else
    t = 1:N;
end
% ###### End check ###########

flag   = false;              	%pre-definite              
node   = true(1,N);

quence = s(1);
node(s(1)) = false;
% Start BFS search
while (~isempty(quence))
    cnode       = quence(1);    %current node
    quence(1)   = [];           %dequeue
    
    % As the node which is the neighbors of current node,and were first 
    % selected to the candidate.
    candidate = find(gMatrix(cnode,:).*node);
    quence    = [quence,candidate];
    node(candidate) = false;
    
    if ~any(node(t))            %if reach target nodes
        flag = true;
        break;
    end
end
%%%