function [PCorr,qe,pe,qe3,qz3,pe3] = partial_Granger(x,y,Max_p,z,Max_q)
% Computing the partial granger causality x-->y|z
% Input:
%   x,y     times series,both are a nx1 vector
%   Max_q   the order of x by regressive
%   z       times series,a nxm vector
%   Max_p   the order of y by autoregressive
% Usage:
%   [Fxy,F0,Attribution] = Granger(x,Max_q,y,Max_p) returns xxx
%
% See also G3_AIC,G2_AIC,LOG,VAR
% Revised by: Hu Yong,Jan,2011

% display('***Causality model:y=ay+cz+e***   y--pe  z--qe');
[G_RssXY,sigEE,qe,pe,G_Afa,Error] = G2_AIC(z,Max_q,y,Max_p);

% display('***Causality model:y=ay+bx+cz+e***   y--pe3  x--qe3 z--qz3');
[G_Rss3,sigEE3,qe3,qz3,pe3,G_Afa3,Error3] = G3_AIC(z,x,Max_q,y,Max_p);

PCorr=log(var(Error)/var(Error3));

% [G_RssXY,sigEE,qe,pe,G_Afa,ErrorX]=G2_AIC(z,Max_q,x,Max_p);
% [G_RssXY,sigEE,qe,pe,G_Afa,ErrorY]=G2_AIC(z,Max_q,y,Max_p);
% [Rss,sigE,qe,Afa,ErrorX]=AIC_Regressive(x,z,Max_q);
% [Rss,sigE,qe,Afa,ErrorY]=AIC_Regressive(y,z,Max_q);