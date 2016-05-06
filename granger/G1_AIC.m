function [Rss,sigE,pe,Afa] = G1_AIC(y,Max_p)
% Determine order of model y=ay+e by AIC Function (Akaike information
% criterion).
% Input:
%   y       times series,a vector nx1
%   Max_p   a positive integer,the max order
% Usage:
%   [Rss,sigE,pe,Afa] = G1_AIC(y,Max_p) returns "Rss" the variance of error,
%   while the mean of y is zero,"sigE" is the maximized value of the
%   likelihood function for the estimated model,"pe" is the order of the
%   model,and "Afa" is the coefficient.
% Revised by: Hu Yong,Jan,2011

n     = length(y);
AICV  = zeros(length(n),1);
for p = 1:Max_p
    Rss    = AR_Model(y,p);         %AR model
    Sigma  = sqrt(Rss/(n-2*p+1));   %the max-value of likelihood function
    AICV(p)= log(Sigma)+2*p/(n-p);  %p/(n-p) is the number of parameters in
end                                 %the statistical model

% Find the best-estimated model
[temp,pe]  = min(AICV);             %get the order of the best model
[Rss,Afa]  = AR_Model(y,pe);        %recompute
sigE       = sqrt(Rss/(n-2*pe+1));  