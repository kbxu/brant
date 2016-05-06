function [C,module] = CCM_GNCommunity(gMatrix)
% CCM_GNCommunity groups nodes by Girvan-Newman algorithm
% Input:
%   gMatrix     binary symmetric connected matrix
% Usage:
%   [C,module] = CCM_GNCommunity(gMatrix) returns node-clusteries,and max
%   modular value "module".
% Example:
%   G = CCM_TestGraph();
%   [C,module] = CCM_GNCommunity(G);
% Note:
%   1)input matrix must be symmetric.
%   2)when a edge deleted,there will almost generate two subgraphs.
% Refer:
%   M.E.J.Newman  Finding and evaluating community structure in network.
% See also CCM_xxxCommunity,branches,CCM_SBetweenness

% Write by: Hu Yong,Nov,7th,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;                   %clear self-edges
if ~issparse(gMatrix)
    gMatrix = sparse(gMatrix);
end

flag = xor(gMatrix,gMatrix');
if any(flag(:))
    error('Input matrix is non-symmetric');
end
% ###### End check ###########

M = nnz(gMatrix);                           %2 * number of edges
gdegree = sum(gMatrix);                     %degree
mmatrix = gMatrix - (gdegree.'*gdegree)/M;  %modularity matrix
% Initialization
C       = ones(N,1);                        %index of communities
num     = 1;                                %number of communities

uncheck = [1,0];
while(uncheck(1))
    s    = find(C == uncheck(1));        	%nodes of subgraph
    g    = gMatrix(s,s);                 	%connect matrix of subgraph
    flag = 1;
    
    % Delete edge one by one,until graph disconnected
    while(flag==1)
        b = CCM_SBetweenness(g,'edge','binary');
        % Randomly choice a edge with max betweenness-value
        [I,J] = find(b == max(b(:)));
        rc    = unidrnd(length(I));
        I     = I(rc);
        J     = J(rc);
        % Delete the specified edge
        g(I,J) = 0;
        g(J,I) = 0;
        % Check connectivity
        [flag,bset] = branches(g);          %when flag=2,quit
    end
    
    % Compute modularity of subgraph
    gmm  = mmatrix(s,s);                    %modularity of subgraph
    gmm  = gmm - diag(sum(gmm));
    bset = 2*bset -3;                       %transform 2 -> 1,1 -> -1
    sq   = bset.'*gmm*bset;
    
    % Determinate
    if sq > 1e-10
        num = num + 1;
        C(s(bset == 1))  = uncheck(1);      %remark
        C(s(bset == -1)) = num;
        uncheck  = cat(2,num,uncheck);      %the same as [num,uncheck]
    else
        uncheck(1) = [];
    end
end

% Compute modularity
temp   = repmat(C,1,N);                    	
module = ~(temp - temp.').*mmatrix./M;
module = sum(module(:));

% Tranformation
temp   = C;
C      = cell(0);
for i  = 1:max(temp)
	C{length(C)+1} = find(temp == i);
end
%%%