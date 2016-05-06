function [Hols,Cols]=VaPkolST(fGn,a,k,M)
% ---------------------------------------------------------------------------
% Input : 
%     fbm : data modelled by a fractional
% Brownian motion.
%     k : power of discrete variations
%     a : filter
%     M : maximum number of dilatations of a
%     llplot : =1 ---> a log-log-plot is done
%
% Output :
%     Hest, Cest : estimation of the self-similarity parameter, H
%                  and the scale coefficient by a simple linear
%                  regression of
%                  log( S_n(k,a?m) ) on log( m ) for m=1,...,M
%                  where a?m is the conv a, dilated m times and
%                  S_n(k,a?m) is the k-th absolute empirical
%                   moment of discrete variations of fractional
%                  Brownian motion
%     LN : vector of log( S_n(k,a?m) )
%     bias : bias brought by the non-linearity of the
%          logarithm function
%
% Example : VaPkolST( fBm=circFBM(500,0.6), k=2, a=c(1,-1),
% M=5, llplot=1 )
%
% See : piaH ---> calculates the covariance function of
% discrete variations of fBm
%
% ---------------------------------------------------------------------------
% Coeurjolly 06/2000
%
% Reference : Coeurjolly, Estimating the parameters of a fractional
% Brownian motion by discrete variations
% of its sample paths,submitted for publication, 1999
%
% -------------------------------------------------------------------------
% estimation of H by a simple linear regression
% ---------------------------------------------
%a=[-0.2304  0.7148 -0.6309 -0.0280  0.1870  0.0308   -0.0329   -0.0106];

if nargin<2
    k=2;M=5;
    a=[-0.4830    0.8365   -0.2241   -0.1294];
end

N=length(fGn);
fBm=fGn;
for i=2:N
    fBm(i)=fBm(i)+fBm(i-1);
end
fBm=fBm-fBm(1);
la = length(a);
SNkam = zeros(1, M);
Vam = conv(fBm, a);
Vam = Vam(la:end-la+1);
SNkam(1) = mean(abs(Vam).^k);
for m = 2:M
    am = dilatation(a, m);lam = m * la - 1;
    Vam = conv(fBm, am);
    Vam = Vam(lam:end-lam+1);
    SNkam(m) = mean(abs(Vam).^k);
end

LN = log(SNkam);
m = 1:M;
Reg = regress(LN',[ones(M,1) log(m)']);
Hols = Reg(2)/k ;%
% ----------------------------------------------------
% calculus of the bias brought by non-linearity of log
% ----------------------------------------------------
% mean.eps = zeros(1, M);
% for m = 1:M   % approximation by expansion of psi(z)-log(z)
%    z = 0.5 * (N - m * (la - 1));
%    mean.eps(m) = -1/2/z - 1/12/z^2 + 1/120/z^4 - 1/252/z^6;
% end
% m = 1:M;
% A = log(m) - mean(log(m));
% norm.A = as.vector(t(A) *A);
% bias = - t(A) %*% mean.eps/2/norm.A %
% % -----------------------------------
% % estimation of the scale coefficient
% % -----------------------------------

pia0 = piaH(a, Hols, 0);

Cest=exp(mean((LN-2*Hols*log(m))-log(pia0)));
Cols=sqrt(Cest);
% Cols = N^Hols*1/sqrt(pia0) * exp(thetaols/k); %
% % ------------
