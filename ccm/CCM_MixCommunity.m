function [C,Qir,Pir,lBar] = CCM_MixCommunity(gMatrix,n)
% CCM_MixCommunity divides network to n-parts by stastical iteration.
% Input:
%   gMatrix     adjancent matrix of network
%   n           the number of partition,default is 2.
% Usage:
%   [C,Qir,Pir] = CCM_MixCommunity(gMatrix,n) returns the partition of
%   network in "C",the probability that vertex i belongs to group r --"Qir",
%   and the fraction of vertices in group r -- "Pir".
% Example:
%   G = CCM_TestGraph1('nograph');
%   [C,Qir,Pir] = CCM_MixCommunity(G,2);
% Note:
%   1)In prograom,Thetarj is the probability that a (directed) link from a 
%     particular node in group r connects to node i,and lBar is expected 
%     value for the log-likelihood by n.
%   2)The result will be different when runing it many times.
% Refer:
%   M.E.J.Newman Mixture models and exploratory analysis in networks

% Write by: Hu Yong,Nov,18th,2010
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
if verLessThan('matlab', '7.14')
    error(nargchk(1,2,nargin,'struct'));
else
    narginchk(1, 2);
end
% error(nargchk(1,2,nargin,'struct'));
if nargin < 2
    n = 2;                                      %default is bipartition
end

% ###### End check ###########

N = length(gMatrix);
gMatrix(1:(1+N):end) = 0;                       %clear self-edges

% Initial value,around the fixed point Pir = 1/n,Thetarj = 1/N
wave    = randn(n,1);                           %fluctuate
Pir     = (1 + wave/(5*max(abs(wave))))/n;
Pir    	= Pir/sum(Pir);                         %normalization

wave    = randn(n,N);
Thetarj = (1 + wave/(5*max(abs(wave(:)))))/N;
Thetarj = Thetarj./(sum(Thetarj,2)*ones(1,N));  %normalization

Qir     = ComputeQir(Pir,Thetarj,gMatrix);
lBar    = -10^5 + 1;
lBar_new= -inf;
num     = 0;
% First,the new-system is the same as the old one
while(lBar_new <= lBar && num < 10^5)           %upper limit of circulate
    % Update system
    lBar_new    = lBar;
    Thetarj_new = Thetarj;
    Pir_new     = Pir;
    Qir_new     = Qir;
    
    % Recompute    
    Pir = sum(Qir_new)/N;                   	% #Pir
    for r = 1:n                                 % #Thetarj
        tmp = (Qir_new(:,r))'*gMatrix;
        Thetarj(r,:) = tmp./sum(tmp);
    end
    Qir = ComputeQir(Pir_new,Thetarj_new,gMatrix);% #Qir
    tmp = gMatrix*log(Thetarj_new') + log(Qir);   % #lBar
    tmp = tmp.*Qir;
    lBar= sum(tmp(:));
    num = num + 1;
end

% Tidy
[tmp,C] = max(Qir,[],2);
C(tmp == 1/n) = 0;                        %0  represents overlap-node
C(tmp < 1/n)  = -1;                       %-1 represents independt-node

% ##### Subfunction #####
function Qir = ComputeQir(Pir,Thetarj,gMatrix)
% Calculating the Qir-value
N   = length(gMatrix);
n   = size(Thetarj,1);
Qir = zeros(N,n);
tmp = zeros(n,1);
for i = 1:N
    for j = 1:n
        tmp(j) = Pir(j)*prod(Thetarj(j,:).^gMatrix(i,:));
    end
    Qir(i,:) = tmp/sum(tmp);
end
%%%