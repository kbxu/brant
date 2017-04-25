function [num,bset] = branches(gMatrix)
% branches is designed to calculate the connected components in the network.
% Input:
%	gMatrix	    adjacent matrix
% Usage:
%   num        = branches(gMatrix) returns the numbers of connected components.
%	[num,bset] = branches(gMatrix) returns node sets of connected components.
% Example:
%	G = round(rand(100));
%   G = G + G';%symmetric property
%   [num,bset] = branches(G);
% Note:
%	1)if gMatrix is a directed graph,there will make gMatrix symmetry,namely, 
%     will do gMatrix = gMatrix + gMatrix'.
%   2)bset is a vector,nodes have the same index belong to the same component.
% Refer:
%	Ulrik.Barandes  A faster algorithm for betweennes centrality
% See also CCM_ShortPathCommunity

% Write by: Hu Yong,nov,2010
% Revised : Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
% error(nargchk(0,1,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(0,1,nargin,'struct'));
else
    narginchk(0, 1);
end
if(~issparse(gMatrix))
    gMatrix = sparse(gMatrix);
end

% Directed graph check,not for weighted graph
temp = xor(logical(gMatrix),logical(gMatrix'));
if any(temp(:))
    gMatrix = gMatrix + gMatrix';
end
% ###### End check ###########

N = length(gMatrix);
node = 1:N;
bset = zeros(N,1);
num  = 0;

while any(node)
    quence = find(node,1);                %find a non-zero number in node-set
    num    = num + 1;
    
    % Start BFS search
    while(~isempty(quence))
        cnode       = quence(1);          %current node
        quence(1)   = [];                 %dequeue
        node(cnode) = 0;
        bset(cnode) = num;                %labeling
        
%         neighbor = find(gMatrix(cnode,:));%neighbor nodes of cnode
%         for i = neighbor
%             if node(i) ~= 0               %first found
%                 quence  = [quence,i];
%                 node(i) = 0;
%             end
%         end
%       <==> change to follow codes
        tmp       = find(gMatrix(cnode,:).*node);%neighbor + first found
        quence    = [quence,tmp];
        node(tmp) = 0;
    end
end
%%%