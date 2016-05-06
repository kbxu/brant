function [Rss,Afa] = AR_Model(y,p)
% AR_Model estimates AR parameter by LS(least square)
% Model: y = a*y + e
% Input:
%   y       times series,a vector nx1
%   p       a positive integer,the order of model
% Usage:
%   [Rss,Afa] = AR_Model(y,p) returns 
%               * "Rss"-- the variance of error
%               * Afa  -- the coefficient of model
% Note:
%          |y(p)   ... y(1) |
%      Q = |y(p+1) ... y(2) |
%          |       ...      |
%          |y(n-1) ...y(n-p)|
% Also see G1_AIC
% Revised by: Hu Yong,Jan,2011

n  = length(y);
y1 = y(p+1:n);

% Construct Q
Q  = zeros(n-p,p);
for i = 1:p
    Q(:,p+1-i) = y(i:(n-p+i-1));
end

% Solve y1 = Q*Afa + error;
% warning('off','all);
Afa  = ((Q.'*Q)^(-1))*(Q.'*y1);
temp = y1 - Q*Afa;
Rss  = temp'*temp;     %variance,while mean(y)=0