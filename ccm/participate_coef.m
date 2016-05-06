function p = participate_coef(gMatrix,C)
% participate_coef calcuates participation coefficient for partition C.
% Input:
%   gMatrix     connect matrix
%   C           node partition,either a vector,or cell-arry
% Usage:
%   p = participate_coef(gMatrix,C) returns participation coefficient p.
% Example:
%   G = CCM_TestGraph1('nograph');
%   [C,module] = CCM_EigenCommunity(G);
%   p = participate_coef(G,C);
% Note:
%   the output for directed graphs is the "out-neighbor" participation
%   coefficient.
% Refer:
%   Roger.Guimera. Functional cartography of complex metabolic
%   networks.(2005,Nature).
% See also CCM_xxxCommunity,MEAN,STD

% Write by: Hu Yong,Jun,2011 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2011

% Unify format
if ~iscell(C)
    temp  = C;
	C     = cell(0);
	for i = 1:max(temp)
        C{length(C)+1} = find(temp == i);
    end
end

N = length(gMatrix);                %number of nodes
p = ones(N,1);                      %preallocation
mdegree = sum(gMatrix,2);
mdegree(~mdegree) = inf;            %no (out)neighbors

for i  = 1:length(C)
    p = p - (sum(gMatrix(:,C{i}),2)./mdegree).^2;
end
%%%