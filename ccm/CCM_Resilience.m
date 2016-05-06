function P = CCM_Resilience(gMatrix)
% CCM_Resilience calulates cmulative degree distribution of network
% Input:
%	gMatrix    symmetry connect binary matrix  
% Usage:
%	P = CCM_Resilience(gMatrix) returns cmulative degree distribution,
%	P(1,:) denotes degree, P(2,:) represents corresponding probability.
% Note:
%	1)if the network is directed, P depicts the in-degree distribution.
%   2) P(K) = sum(p(x)) for x>=K where p(x) is the probability of a node
%   having degree x. 
% Refer:
%	V.Latora.Vulnerability and protection of infrastructure networks.2005
% See also HIST

% Written by: Hu Yong, Jan,2011
% E-mail    : carrot.hy2010@gmail.com
% based on Matlab 2008a
% Version (1.0)
% Copywrite (c) 2011

N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;%Clear self-edges

degree  = sum(gMatrix);
[K, I, J] = unique(degree);
P       = zeros(length(K),2);
P(:, 1) = K;
for i = 1:length(K)
    P(i, 2) = sum(degree == K(i))/length(J);
end
P(:, 2) = triu(true(length(K))) * P(:, 2);

% Or Using HIST function
% tmp    = hist(degree,K);
% tmp    = tmp./(sum(tmp));       %normalised
% P(2,:) = triu(true(length(K)))*tmp';