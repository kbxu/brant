function [CN, dV, C] = CCM_LinkCommunity(G, lbound)
% CCM_linkCommunity groups by link's agglomeration. 
% Input:
%	G	    symmetric matrix, gMatrix(i,j) > 0 represents for node i
%           connect to node j with weight gMatrix(i,j) (if it exists). 
%   lbound  lower bound of gather simmilarity value.
% Usage:
%	[CN, dV] = CCM_LinkCommunity( G ) returns node-clustering, 
%   and corresponding max-Dvaule
%   [CN, dV, C] = CCM_LinkCommunity( G ) returns link-clustering. C is a
%   matrix, when the same mark indicating in the same group.(except 0)
% Example:
%	G = round(rand(10)/2);
%   G = G + G';%symmetric property
%	[CN, dV, C] = CCM_LinkCommunity(G);
% Refer:
%	Yong.Yeol.Ahn  Link communities reveal multiscale complexity in	networks

% Write by: Hu Yong, Dec,2010 
% Last revised, Mar, 2011
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.3, Copywrite (c) 2010

if(nargin < 2), lbound = 0;   end

N = length( G );    %number of nodes
G(1:(N+1):end) = 0; %clear self-edges
M = nnz( G )/2;     %number of edges

% Compute similar matrix - Tanimoto coefficient(or Jaccard index)
G(logical(eye(N))) = sum(G)./sum(G > 0);
S = G * G.';
S = S./(repmat(sum(G.^2), N, 1) + repmat(sum(G.^2,2), 1, N) -  S);
S(1:(N+1):end) = 0;%clear diagonal elements
G(1:(N+1):end) = 0;

% Predefine
C   = zeros(N, N);
mcV = zeros(M, 1);
dV  = 0; num = 0;

last_dV = dV;%final result
last_C  = 0;
linkmerge = @(x,y) 2*x*(x-(y-1))./((y-2)*(y-1));
maxv = 1;
while(any(S(:)) & maxv >= lbound)
    % Find the max similarity value
    [maxv, I] = max(S(:));%coordinate(I,J)
    J = fix((I-1)/N) + 1;
    I = I - (J-1) * N;
    S(I, J) = 0; S(J, I) = 0;%delete

    %Find correspoding edges
    Itmp = (G(I,:) > 0);
    Jtmp = (G(:,J) > 0)';
    cNode = (Itmp & Jtmp);%common points, I-cNode-J
    cNode = find(cNode);

    %Check the mark
    for i = 1:length(cNode)
        if(any(C(I,cNode(i))) & isequal(C(I, cNode(i)),C(cNode(i), J)))
            continue;%have the same non-zero mark
        else%don't mark or have different marks
            oldmark = unique([C(I,cNode(i)), C(cNode(i),J)']);
            oldmark(oldmark == 0) = [];%delete 0 marked

            %Update mark
            num = num + 1;
            C([I,J], cNode(i)) = num;
            C(cNode(i), [I,J]) = num;
            for(i = 1:length(oldmark)),  C(C == oldmark(i)) = num;   end

            %Update mcValue
            [II, JJ] = find(tril(C) == num);
            mc = length(II);  nc = length(unique([II,JJ]));
            mcV(num) = linkmerge(mc, nc)/M;
            if(isempty(oldmark)),    dV = dV + mcV(num);
            else
                dV = dV + mcV(num) - sum(mcV(oldmark));
                mcV(oldmark) = 0;
            end

            if(dV > last_dV),  last_dV = dV;    last_C  = C;   end
        end
    end
end
C  = last_C;
dV = last_dV;

% Tranform to node group
mark = unique(nonzeros(C));
CN   = cell(1,length(mark));
for i = 1:length(mark)
    [I, J] = find(C == mark(i));
    CN{i} = unique([I, J]);
end  
    
