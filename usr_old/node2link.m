function [S,Ind] = node2link(gMatrix)
% node2link transforms adjacent matrix of node-graph to connect matrix of 
%           line-graph
% Input:
%	gMatrix	    symmetric matrix, gMatrix(i,j) > 0 represents for node i
%               connect to node j.
% Usage:
%	[S,Ind] = node2link(gMatrix) returns a similary matrix S by method of
%	Tanimoto coefficient computing, and corresponding index set.
% Example:
%	gMatrix = round(sprand(10,10,0.3));
%   gMatrix = gMatrix + gMatrix';%symmetric property
%	[S,Ind] = node2link(gMatrix);
% Note:
%	S is a sparse matrix,Ind(i,1) and Ind(i,2) are the endpoint of edge i.
% Refer:
%	Yong.Yeol.Ahn.Link communities reveal multiscale complexity in networks
% See also linkCommunity

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.2, Copywrite (c) 2010

% ###### Input check #########
if ~issparse(gMatrix)
    gMatrix = sparse(gMatrix);
end

% symetric property check
% another method -- issym = @(x) isequal(x,x'); 
% issym = @(x) all(all(x==x.'));
% if ~issym(gMatrix)
%     error('Bad input !');
% end
% ###### End check #########

N = length(gMatrix);            %number of nodes
M = nnz(gMatrix)/2;             %number of edges


Ind = sparse(N,N);              %preprocessing
[I,J] = find(tril(gMatrix'));   %[J,I] is index-vector,namely,Indtemp
for i = 1:M
    Ind(J(i),I(i)) = i;
end
Ind = Ind + Ind';               %where Ind(i,j) represents edge index with 
                                %two endpoint i and j.
Indtemp = [J,I];

% Compte Tanimoto coefficient(Jaccard index for 0-1 matrix)
gMatrix(logical(speye(N))) = sum(gMatrix)./sum(gMatrix > 0);
Stemp = gMatrix * gMatrix.';  	%for similar_vaule
Stemp = Stemp./(repmat(sum(gMatrix.^2),N,1) + repmat(sum(gMatrix.^2,2),1,N)...
        - Stemp);

% Transform
S = sparse(M,M);
for i = 1:N
    [I,J] = find(Ind(i,:));
    if length(J) > 1
        edgePair = nchoosek(J,2);
        for j = 1:size(edgePair,1)
            S(Ind(i,edgePair(j,1)),Ind(i,edgePair(j,2))) = ...
                                        Stemp(edgePair(j,1),edgePair(j,2));
        end
    end
end
S = max(S,S');

Ind = Indtemp;
%%%