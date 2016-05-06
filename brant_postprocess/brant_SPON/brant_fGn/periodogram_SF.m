function [H,f,Sf,P] = periodogram_SF(s,N)
%该函数用来估计分形噪声序列的Husrt 指数
% N = length(s);

if mod(N,2)~= 0
    error('The length of the data must be an even number!');
end

temp = fftshift(abs(fft(s)));
% Sf = temp(N/2+1:N);
Sf = temp(N/2+2:N).^2/N;
Sf = smooth(Sf)';%smoothing improve the rusults

f = linspace(-0.5,0.5,N);
% f = f(N/2+1:N);
f = f(N/2+2:N);

% X = [ones(N/2,1) log(f)'];
X = [ones(N/2-1,1) log(f)'];
Y = log(Sf);

B = regress(Y',X);

H = 0.5-B(2)/2;

% if H<0
%     alpha = 0.68;
%     H = 0.5-B(2)/2/alpha;
% end

P = [exp(B(1)) B(2)];
%========================The end===========================