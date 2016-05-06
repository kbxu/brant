function [G_Rss,sigEE,qe,qz,pe,G_Afa,Error]=G3_AIC(z,x,Max_q,y,Max_p)
% Determine order of model y=ay+bx+cz+e by AIC Function (Akaike information
% criterion).
% Input:
%   x,y     times series,both are vectors nx1
%   z       times series,matrix nxm
%   Max_q   a positive integer,the max order of x,z
%   Max_p   a positive integer,the max order of y
% Usage:
%   [G_Rss,sigEE,qe,qz,pe,G_Afa,Error]=G3_AIC(z,x,Max_q,y,Max_p) returns "G_Rss"
%   represents the variance of error,while the mean of y is zero,"sigEE" is 
%   the maximized value of the likelihood function for the estimated model,
%   "qe","qz","pe" is the order of the model,for x,z and y respectively,and "G_Afa"
%   is the coefficient of model,"Error" is the error of model.
% Revised by: Hu Yong,Jan,2011

n = length(y);
m = size(z,2);
AICM = zeros(Max_p,Max_q,Max_q);
for p = 1:Max_p
    for q = 1:Max_q
        for s = 1:Max_q
           pm    = max([p,q,s]);
           G_Rss = Granger3_Model(z,s,x,q,y,p);
           Sigma = sqrt(G_Rss/(n-pm-p-q-s*m+1));
           AICM(p,q,s) = log(Sigma)+2*(p+q+s*m)/(n-pm);
        end
    end
end

% Find the best-estimated model
[minA,pe,qe,qz]     = minMatrix3(AICM);
[G_Rss,G_Afa,Error] = Granger3_Model(z,qz,x,qe,y,pe);
sigEE = sqrt(G_Rss/(n-pm-pe-qe-qz*m+1));

% ##### Subfunction #####
function [minA,p,q,z] = minMatrix3(A)
% Finding the min-value in 3-dim matrix A,
% and the correspoding coordinate.
minA = min(A(:));
for z = 1:size(A,3)
    [p,q] = find(A(:,:,z) == minA);
    if ~isempty(p)
        break;
    end
end
%%%