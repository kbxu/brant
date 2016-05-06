function [G_Rss,G_Afa,Error] = Granger2_Model(x,q,y,p)
% Given order p,q, solving the model y=ay+bx+e
% Input:
%   x,y     times series,both are vectors nx1
%   p       a positive integer,order of x
%   q       a positive integer,order of y
% Usage:
%   [G_Rss,G_Afa,Error] = Granger2_Model(x,q,y,p) returns "G_Rss" the 
%   variance of error,while the mean of y is zero,"G_Afa" is the coefficient
%   of model,and "Error" is the error of model.
% Note:
%          |y(pm)   ...y(pm+1-p) x(pm) ...x(pm+1-q)|
%      Q = |y(pm+1) ... y(pm-p) x(pm+1) ... x(pm-q)|
%          |        ...                 ...        |
%          |y(n-1) ...  y(n-p)   x(n-1) ... x(n-q) |
% Also see G2_AIC
% Revised by: Hu Yong,Jan,2011

n  = length(y);
pm = max(p,q);
y1 = y(pm+1:n);

% Construct Q
Q  = zeros(n-pm,p+q);
for i = 1:p
    Q(:,i) = y((pm+1-i):(n-i));
end
for i = 1:q
    Q(:,p+i) = x((pm+1-i):(n-i));
end

% Solve y1 = Q*G_Afa + Error;
% warning('off','all);
G_Afa = ((Q'*Q)^(-1))*(Q'*y1);
Error = y1-Q*G_Afa;
G_Rss = Error'*Error;    %variance,while mean(y)=0