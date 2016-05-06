function [Rss,Afa,Error] = Regressive_Model(y,x,q)
% Given order q, solving the model y=bx+e
% Input:
%   x,y     times series,both are vectors nx1
%   q       a positive integer,order of x
% Usage:
%   [Rss,Afa,Error] = Regressive_model(y,x,q) returns "Rss" the variance of
%   error,while mean(y)=0,"Afa" is the coefficient of model,and "Error" is 
%   the error of model.
% Note:
%          |x(q)   ...x(1)   |
%      Q = |x(q+1) ... x(2)  |
%          |       ...       |
%          |x(n-1) ... x(n-q)|
% Also see R_AIC
% Revised by: Hu Yong,Jan,2011

n  = length(y);
y1 = y(q+1:n);

% Construct Q
Q  = zeros(n-q,q);
for i = 1:q
    Q(:,i) = x((q+1-i):(n-i));
end

% Solve y1 = Q*G_Afa + Error;
% warning('off','all);
Afa   = ((Q'*Q)^(-1))*(Q'*y1);
Error = y1-Q*Afa;
Rss   = Error'*Error;       %variance,while mean(y)=0
