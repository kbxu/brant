function [G_Rss,G_Afa,Error] = Granger3_Model(z,s,x,q,y,p)
% Given order p,q,s, solving the model y=ay+bx+cz+e
% Input:
%   x,y     times series,both are vectors nx1
%   z       times series,matrix nxm
%   p       a positive integer,order of x
%   q       a positive integer,order of y
%   s       a positive integer,order of z
% Usage:
%   [G_Rss,G_Afa,Error] = Granger3_Model(z,s,x,q,y,p) returns "G_Rss" the 
%   variance of error,while the mean of y is zero,"G_Afa" is the coefficient
%   of model,and "Error" is the error of model.
% Note:
%          |y(pm)   ...y(pm+1-p) x(pm) ...x(pm+1-q) z(pm,1) ...z(pm,m),z(pm-1,1)..  |
%      Q = |y(pm+1) ... y(pm-p) x(pm+1) ... x(pm-q) z(pm+1,1),..z(pm+1,m),z(pm,1),..|
%          |        ...                 ...                   ...                 ..|
%          |y(n-1) ...  y(n-p)   x(n-1) ... x(n-q) z(n-1,1),...z(n-1,m),z(n-2,1),.. |
% Also see G_AIC2
% Revised by: Hu Yong,Jan,2011

n  = length(y);
m  = size(z,2);
pm = max([p,q,s]);
y1 = y(pm+1:n);

% Construct Q
Q  = zeros(n-pm,p+q+s*m);
for i = 1:p
    Q(:,i) = y((pm+1-i):(n-i));
end
for i = 1:q
    Q(:,p+i) = x((pm+1-i):(n-i));
end
for i = 1:s
    Q(:,p+q+((m*(i-1)+1):m*i)) = z((pm+1-i):(n-i),:);
end

% Solve y1 = Q*G_Afa + Error;
% warning('off','all);
G_Afa = ((Q.'*Q)^(-1))*(Q.'*y1);
Error = y1-Q*G_Afa;
G_Rss = Error'*Error;           %variance,while mean(y)=0