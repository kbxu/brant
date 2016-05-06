clear,clc
close all

H0=0.3;
sigma0=1;
N=256;

s=fGn_Davies(H0,sigma0,N);
s=s-mean(s);

%=======================================
% wname='db4';
% J=wmaxlev(N,wname);
% [H,sigma]=wls_exact(s,J,wname);

%========================================
% [H,sigmg]=fBm_based(s);
% 
% %=======================================
% 
% [b1,b2]  =  Truncated_Alpha(N);
% [H,sigma]=MPE0(s,N,b1,b2);
% %=======================================
% H=periodogram_SF(s,N);
% 
% %======================================
[H,sigma]=Whittle_estimator0(s,N);
%=============The end==================

  