function [B_global, B] = CCM_RBetweenness(gMatrix)
% CCM_RBetweenness computes random-walk betweenness
% Input:
%	gMatrix	    symmetric adjacency matrix
% Usage:
%	B = CCM_RBetweenness(gMatrix) returns betweenness on each node
% Example:
%	G = CCM_TestGraph1('nograph');
%   B = CCM_RBetweenness(G);
% Note:
%	(1) output B is a 1xN vector,N represents the number of nodes.
%   (2) this program just adapt to Binary-Network without weight,direction!
%   (3) complexity o(N^3) !
% Refer:
%	M.E.J.Newman  A mearsure of betweenness centrality based on random
%	walks (MI 48109-1120)
% See also CCM_SBetweenness

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
% error(nargchk(0,1,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(0,1,nargin,'struct'));
else
    narginchk(0,1);
end
if nargin > 1
    error('Many Input !');
end

if ~issparse(gMatrix)
    gMatrix = sparse(gMatrix);  %transform to sparse matrix
end
% ###### End check ###########

N = size(gMatrix,1);            %number of nodes
gMatrix(1:(N+1):end) = 0;       %clear self-edges

D = diag(sum(gMatrix));         %the diagonal matrix of node degrees
T = D - gMatrix;

Ttemp  = T(1:(N-1),1:(N-1));    %just like remove the last row and column
Ttemp  = inv(Ttemp);
T(N,:) = 0;                     %just like add zeros at the corresponding position
T(:,N) = 0;
T(1:(N-1),1:(N-1)) = Ttemp;

% There need be optimized,but i cann't reach it...
% Compute random-walk betweenness regardless of end-points of a path
B = zeros(1,N);
for s = 1:(N-1)
    for t = 2:N
        Nost = setdiff((1:N),[s,t]);%not sourse and target node
        for i = Nost
            Neighbour = find(gMatrix(i,:));
            if ~isempty(Neighbour)
                B(i)  = B(i) + sum(abs(T(i,s) - T(i,t) - T(Neighbour,s) +...
                        T(Neighbour,t)))./2;
            end
        end
    end
end
B = B./((N-1)*(N-2)/2);
B_global = mean(B(:));
%%%