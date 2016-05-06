function [G_Rss,sigEE,qe,pe,G_Afa,Error] = G2_AIC(x,Max_q,y,Max_p)
% Determine order of model y=ay+bx+e by AIC Function (Akaike information
% criterion).
% Input:
%   x,y     times series,both are vectors nx1
%   Max_q   a positive integer,the max order of x
%   Max_p   a positive integer,the max order of y
% Usage:
%   [G_Rss,sigEE,qe,pe,G_Afa,Error]=G2_AIC(x,Max_q,y,Max_p) returns "G_Rss"
%   represents the variance of error,while the mean of y is zero,"sigEE" is 
%   the maximized value of the likelihood function for the estimated model,
%   "qe","pe" is the order of the model,for x,and y respectively,and "G_Afa"
%   is the coefficient of model,"Error" is the error of model.
% Revised by: Hu Yong,Jan,2011

n     = length(y);
AICM  = zeros(Max_p,Max_q);
for p = 1:Max_p
    for q  = 1:Max_q
        pm = max(p,q);
        G_Rss = Granger2_Model(x,q,y,p);     %granger model
        Sigma = sqrt(G_Rss/(n-pm-p-q+1));   %the max-value of likelihood function
        AICM(p,q) = log(Sigma)+2*(p+q)/(n-pm);%AIC-matrix
    end
end

% Find the best-estimated model
[tmp,pe]  = min(AICM);                      %note,pe is a vector,at present
[minV,qe] = min(tmp);
pe        = pe(qe);
[G_Rss,G_Afa,Error] = Granger2_Model(x,qe,y,pe);
sigEE     = sqrt(G_Rss/(n-pm-pe-qe+1));