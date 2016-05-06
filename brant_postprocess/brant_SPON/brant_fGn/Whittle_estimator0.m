function [H,sigma]=Whittle_estimator0(S,L)
%本函数是实现 Whittle's estimator ，估计分数高斯噪声（fGn）的指数 H 和方差sigma2
%S 和 L 分别是输入的fGn及其长度

switch nargin
    case 1
        N=length(S);
        G=reshape(S,N,1);
    case 2
        N=L;
        G=reshape(S,N,1);
    otherwise
        error('Too many input arguments.');
end

%用黄金分割的办法求 H 的最大似然估计值
H1=0.001;
H2=0.999;
g=0.618;

u=H2-g*(H2-H1);
T=H1+H2-u;
delta=T-u;

bool=0;loop=1;
m=20;dt=0.001;
while(delta>=0.001)
    
  if ~bool || loop==1
    CH1=gamma(2*u+1)*sin(pi*u)/((2*pi)^(2*u+1));
%     K1=intsfw(eps,0.5,m,dt,u,N);
    K1=intsfwm(eps,0.5,m,dt,u,N);
    D1=toeplitz(K1,K1');
    sigma2_hat1=G'*D1*G/(4*N*CH1);
%     fu=-N/2*(log(abs(4*sigma2_hat1))+log(CH1)+...
%         2*intsfc(eps,0.5,m,dt,u));
     fu=-N/2*(log(4*sigma2_hat1*CH1)+...
        2*intsfc(eps,0.5,m,dt,u));
  end
  
  if bool || loop==1
    CH2=gamma(2*T+1)*sin(pi*T)/((2*pi)^(2*T+1));
%     K2=intsfw(eps,0.5,m,dt,T,N);
    K2=intsfwm(eps,0.5,m,dt,T,N);
    D2=toeplitz(K2,K2');
    sigma2_hat2=G'*D2*G/(4*N*CH2);
%     fT=-N/2*(log(abs(4*sigma2_hat2))+log(CH2)+...
%         2*intsfc(eps,0.5,m,dt,T));
    fT=-N/2*(log(4*sigma2_hat2*CH2)+...
        2*intsfc(eps,0.5,m,dt,T));
  end
 
    if fT>fu
        H1=u;
        u=T;
        T=H1+g*(H2-H1);
        bool=1;
        fu=fT;
    else
        H2=T;    
        T=u;
        u=H2-g*(H2-H1);
       bool=0;
       fT=fu;
    end   
    delta=T-u;
    loop=loop+1;
end
% H=(H1+H2)/2;
% sigma2=abs((sigma2_hat1+sigma2_hat2)/2);
if fu>fT
    H=u;
    sigma=sqrt(sigma2_hat1);
else
    H=T;
    sigma=sqrt(sigma2_hat2);
end