function [C,module] = eigenmodule_br(gMatrix,vset,mmatrix)
% eigenmodule_br clusters nodes by using eigen-verctors recursively.
% Input:
%   gMatrix     adjancent matrix of network
%   vset        vertex set in network which need be partition(not always)
%   mmatrix     modularity matrix of network(not always)
% Usage:
%   [C,module] = eigenmodule_br(gMatrix,vset) returns a partition in "C",
%   which correspoding to the max modular value "module".
% Example:
%   G = CCM_TestGraph1();
%   [C,module] = eigenmodule_br(G);
% Note:
%   pay attention to the global variable "COMMUNITY"!
% Refer:
%   M.E.J.Newman   Modularity and community structure in network
% See also CCM_EigenCommunity,eigenmodule2,EIG,SIGN,SUM,MAX

% Write by: Hu Yong,Nov,15th,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

global COMMUNITY;                       %declaration
if isempty(COMMUNITY)
    COMMUNITY = cell(0);                %preallocation
end

% ###### Input check #########
if nargin < 2 
    vset    = 1:length(gMatrix);        %index of nodes
    gdegree = sum(gMatrix);             %degree
    mmatrix = gMatrix - (gdegree.'*gdegree)/sum(gdegree);%modularity matrix
elseif nargin < 3
    gdegree = sum(gMatrix);             
    mmatrix = gMatrix - (gdegree.'*gdegree)/sum(gdegree);%modularity matrix
end
% ###### End check #########

N   = length(vset);                     %number of nodes in subgraph
% M   = nnz(gMatrix);                   %%number of edges
gmm = mmatrix(vset,vset);               %modularity matrix of subgraph 

% Bipartition
[evector,evalue] = eig(gmm);            %compute  eigenvector and eigenvalue
[temp,position]  = max(diag(evalue));   %find the max eigenvaule
flag             = ones(N,1);           %label
flag(evector(:,position) < 0) = -1;

% Calculate modular
gmm  = gmm - diag(sum(gmm));
sq   = flag.'*gmm*flag;

% Recursive exit,indivisible
if sq > 1e-10
    eigenmodule_br(gMatrix,vset(flag == -1),mmatrix);%continue bipartition
    eigenmodule_br(gMatrix,vset(flag == 1),mmatrix);
else
    COMMUNITY{size(COMMUNITY,2)+1} = vset;
%     return;
end

% Output!
if nargout == 1
    C = COMMUNITY;
    clear global COMMUNITY;
elseif nargout == 2
    C = COMMUNITY;
    clear global COMMUNITY;
    
    % Compute modularity
    M     = nnz(gMatrix);              	%number of edges
    ind   = zeros(length(gMatrix));
    for i = 1:length(C)
        ind(C{i},C{i}) = 1;
    end
    module = ind.*mmatrix./M;
    module = sum(module(:));
end
%%%