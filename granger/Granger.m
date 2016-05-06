function [Fxy,F0,Attribution] = Granger(x,Max_q,y,Max_p)
% Computing the Granger causality "x-->y"
% Input:
%   x,y     times series,both are a nx1 vector
%   Max_q   the order of x by regressive
%   Max_p   the order of y by autoregressive
% Usage:
%   [Fxy,F0,Attribution] = Granger(x,Max_q,y,Max_p) returns xxx
%
% See also G1_AIC,G2_AIC,F_Afa,FINV
% Revised by: Hu Yong,Jan,2011

n = length(y);
% display('***AR model:y=ay+e***');
RssY = G1_AIC(y,Max_p);          %[Rss,sigE,peY,Afa] = G_AIC1(y,Max_p);

% display('***Causality model:y=ay+bx+e***   y--pe  x--qe');
[G_RssXY,sigEE,qe,pe] = G2_AIC(x,Max_q,y,Max_p);

% Attribution=2*log2(sigE/sigEE)
Attribution = RssY/G_RssXY-1;
Fxy         = Attribution*(n-pe-qe-1)/pe;
afa0        = 0.05;
F0          = finv(1-afa0,pe,n-pe-qe-1) - 0.001;
%the same as F0=F_Afa(pe,n-pe-qe-1,afa0);