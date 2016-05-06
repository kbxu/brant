function Noise=fGn_Davies(H,sigma,L)
%该函数是利用 CEM 方法模拟产生长度为 N 的分数高斯噪声
%H----- 噪声频谱指数
%sigma -----噪声的均方差
%L-------数据长度

N=L-1;
k=0:N;
% K=sqrt(2*N-2);%K 为傅立叶变换的常数因子

rGH=sigma^2*(abs(k+1).^(2*H)-2*abs(k).^(2*H)+abs(k-1).^(2*H))/2;
s=[rGH rGH(N:-1:2)];

% k=0:2*N-1;
% n=k;
% WN=exp(-j*2*pi/(2*N));
% nk=n'*k;
% WNnk=WN.^nk;
% S1=s*WNnk;
S=fft(s);
% S=real(S);
% S=(2*N)*ifft(s);


tempX=[normrnd(0,sqrt(2),1,1) normrnd(0,1,1,N-1) normrnd(0,sqrt(2),1,1)];
tempY=[0 normrnd(0,1,1,N-1) 0];
tempZ=tempX+j*tempY;
Z=[tempZ conj(tempZ(N:-1:2))];

X=N^(1/2)*ifft(Z.*(S.^(1/2)));
Noise=X(1:L);