function [Rss,sigE,qe,Afa,Error] = R_AIC(y,x,Max_q)
% Determine order of model y=ax+e by AIC Function (Akaike information
% criterion).
% Input:
%   y,x     times series,a vector nx1
%   Max_q   a positive integer,the max order
% Usage:
%   [Rss,sigE,qe,Afa,Error] = R_AIC(y,x,Max_q) returns "Rss" the variance of error,
%   while the mean of y is zero,"sigE" is the maximized value of the
%   likelihood function for the estimated model,"qe" is the order of the
%   model,and "Afa" is the coefficient,"Error" is the error of model.
% Revised by: Hu Yong,Jan,2011

n    = length(y);
AICV = zeros(Max_q,1);
for q=1:Max_q
    Rss     = Regressive_Model(y,x,q);      %regressive model
    Sigma   = sqrt(Rss/(n-2*q+1));          %the max-value of likelihood function
    AICV(q) = log(Sigma)+2*q/(n-q);         %p/(n-p) is the number of parameters in
end                                         %the statistical model

% Find the best-estimated model
[temp,qe]   = min(AICV);                    %get the order of the best model
[Rss,Afa,Error] = Regressive_model(y,x,qe); %recompute
sigE = sqrt(Rss/(n-2*qe+1));