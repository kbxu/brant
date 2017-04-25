function Mi = CCM_MutualInfo(P1,P2)
% CCM_MutualInfo computes the normalised multual information between 
% real-communities P1 and found-communities P2 which got from some
% algorithms.
% Input:
%   P1,P2   two partitions of graph,maybe vectors Nx1 or two cell-arraries
% Usage:
%   Mi = CCM_MutualInfo(P1,P2) returns the similar value between partitions
% Note: 
%   1) there don't have any empty-subpart in P1 and P2;
%                       -2*sum_i(sum_j(Nij*log(Nij/(Ni.)/(N.j))))
%   2) NMI(A,B) =  ---------------------------------------------
%                        sum_i(Ni.)*log(Ni.)+sum_j(N.j)*log(N.j)
%       where N is the normalised confusion matrix,(Ni.) = sum_j(Nij)
% Refer:
%       Leon Danon etc. Comparing community structure identification.
% See also xxx

% Written by Hu Yong, Dec,2010
% E-mail: carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
% error(nargchk(1,2,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(1,2,nargin,'struct'));
else
    narginchk(1, 2);
end
% Unify format
if ~iscell(P1)
    temp = P1;
    P1   = cell(0);
    for i = 1:max(temp)
        P1{size(P1,2)+1} = find(temp == i);
    end
end

if ~iscell(P2)
    temp = P2;
    P2   = cell(0);
    for i = 1:max(temp)
        P2{size(P2,2)+1} = find(temp == i);
    end
end
% ###### End check ###########

np1 = length(P1);           %number of subparts in P1
np2 = length(P2);
cM  = zeros(np1,np2);       %confusion matrix
for i = 1:np1
    for j = 1:np2
        cM(i,j) = length(intersect(P1{i},P2{j}));
    end
end

cM = cM/sum(cM(:));         %normalization
Ni = sum(cM,2);             %Ni. -- cA x 1 size
Nj = sum(cM,1);             %N.j -- 1 x cB size

% Numerator
Mi_num = cM.*log(cM./(Ni*Nj));
Mi_num(isnan(Mi_num)) = 0;
Mi_num = -2*sum(Mi_num(:));

% Denominator
Ni(~logical(Ni)) = [];      %clear 0-intersect elements
Nj(~logical(Nj)) = [];
Mi_den = sum(Ni.*log(Ni)) + sum(Nj.*log(Nj));

Mi     = Mi_num/Mi_den;
%%%