function Ass = CCM_Assortative(gMatrix)
% CCM_Assortative calculates Assortativity coefficient of network.
% Input:
%	gMatrix     connect matrix,
% Usage:
%	Ass = CCM_Assortative(gMatrix) returns the assortative.
% Example:
%	G   = CCM_TestGraph1('nograph');
%   Ass = CCM_Assortative(G);
% Refer:
%	[1] M.E.J.Newman  Assortative mixing in networks(2002)
%   xxx [2] M.E.J.Newman  Mixing partterns in networks(2003) xxx discord
%   [3] Mikail.Rubinov Complex network measures of brain connectivity: Uses
%       and interpretations
% See also STRMATCH, SUM, FIND

% Write by: Hu Yong, Dec,2010
% Based on Matlab 2008a
% $Revision : 1.0, Copywrite (c) 2009

if(nargin > 1), error('Too many input.');   end
gMatrix(1:(length(gMatrix)+1):end) = 0;%Clear self-edges

degree = sum(gMatrix,1) + sum(gMatrix,2)';%In & out degree
[I,J]  = find(gMatrix>0);
M      = length(I);
degreei = zeros(M,1);
degreej = zeros(M,1);
for i = 1:M
    degreei(i) = degree(I(i));
    degreej(i) = degree(J(i));
end

% Calculate assortativity
Ass = (sum(degreei.*degreej)/M - (sum(degreei+degreej)/(2*M))^2)/...
      (sum(degreei.^2+degreej.^2)/(2*M) - (sum(degreei+degreej)/(2*M))^2);

% % There is another way for binary symmetric network.(Li Huan Dong)
% degree = sum(gMatrix>0);
% % Intermediate variables
% sumjk   = 0;
% sumj_k  = 0;
% sumj_k2 = 0;
% for j = 1:N
%     for k = 1:(j-1)
%         if(gMatrix(j,k) > 0)
%             sumjk   = sumjk   + degree(j)*degree(k);
%             sumj_k  = sumj_k  + (degree(j) + degree(k))/2;
%             sumj_k2 = sumj_k2 + (degree(j).^2 + degree(k).^2)/2;
%         end
%     end
% end
% Ass = (sumjk/M - (sumj_k/M).^2)/(sumj_k2/M - (sumj_k/M).^2);