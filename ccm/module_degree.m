function z = module_degree(gMatrix,C)
% module_degree calcuates within-module degree z-score for partition C.
% Input:
%   gMatrix     connect matrix
%   C           node partition,either a vector,or cell-arry
% Usage:
%   z = module_degree(gMatrix,C) returns the z-score of within-module
% Example:
%   G = CCM_TestGraph1('nograph');
%   [C,module] = CCM_EigenCommunity(G);
%   z = module_degree(G,C);
% Note:
%   the output for directed graphs is the "out-neighbor" z-score.
% Refer:
%   Roger.Guimera. Functional cartography of complex metabolic
%   networks.(2005,Nature).
% See also CCM_xxxCommunity,MEAN,STD

% Write by: Mika Rubinov, UNSW(2008)
% $Revision: xxx, Copywrite (c) 2008

% Unify format
if ~iscell(C)
    temp  = C;
	C     = cell(0);
	for i = 1:max(temp)
        C{length(C)+1} = find(temp == i);
    end
end

z = zeros(length(gMatrix),1);       %preallocation
for i = 1:length(C)
    mdegree = sum(gMatrix(C{i},C{i}),2);
    z(C{i}) = (mdegree - mean(mdegree))./std(mdegree);
end
z(isnan(z)) = 0;