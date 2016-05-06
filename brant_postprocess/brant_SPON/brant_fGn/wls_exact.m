function [H,sigma,B1]=wls_exact(G,J,wname,S)
%该程序是利用精确的SDF实现小波最大似然估计分形噪声的指数参数及其方差
% ==========================第一步=====================================
if size(G,1)==1
    G=G';
end
N=length(G);
% J=wmaxlev(N,wname);
% ==========================第二步=====================================
if nargin<4
    X=[ones(N,1) (1:N)'];
    Y=G;
else
    S=reshape(S,N,1);
    X=[ones(N,1) S];%design matrix
    Y=G+S;
end
B0=regress(Y,X);
% ==========================第三步=====================================
dwtmode('ppd','nodisp');
[Yw,L]=wavedec(Y,J,wname);
dX1=wavedec(X(:,1),J,wname);
dX2=wavedec(X(:,2),J,wname);
Xw=[dX1 dX2];
% ==========================第四步=====================================
j0=J:-1:1;

L1=fix(2.^(-j0)*N); L1=[L1(1) L1];L1=L1';
L2=L(1:end-1);
dL=L2-L1;
d1=floor(dL/2);

pos=zeros(1,J+1);
pos(1)=1;
for i=2:J+1
    pos(i)=pos(i-1)+L(i-1);
end

ind=[];
for i=1:J+1
    ind=[ind (pos(i)+d1(i)):(pos(i)+d1(i)+L1(i)-1)];
end

L=[L1; N];
Xw=Xw(ind,:);
Yw=Yw(ind,:);
N1=sum(L(1:end-1));
% 下面用黄金分割的办法求 H
% 不妨设 H 包含在区间 [0,1]中

g=0.618;
N0=100; %精确计算SDF时的截断N0
dt=0.005;
dB=1;
while dB>0.01
ma=-0.99999;
mb=0.99999;
u=mb-g*(mb-ma);
T=mb+ma-u;
delta=1;
dec=Yw-Xw*B0;
S_dd=zeros(1,N1);

bool=0;%当区间端点右移时，取值为1，否则为0
loop=1;%记录循环次数

while(abs(delta)>0.001)     
%======================================================================
if ~bool || loop==1
    
   CH1=4*gamma(u+2)*sin(pi*(1+u)/2)/(2*pi)^(u+2);
   for i=1:J
       j1=-j0(i);
       temp=intSDFc(2^(j1-1),2^j1,N0,dt,(1+u)/2); 
       temp=2^(-j1+1)*temp;
       if i==1
           ta=L(i)+1;
           tb=L(i)+L(i+1);
       else
           ta=tb+1;
           tb=tb+L(i+1);
       end
       S_dd(ta:tb)=temp;
   end

      temp=intSDFc(0,2^(-J-1),N0,dt,(1+u)/2); 
      temp=2^(J+1)*temp;
      S_dd(1:L(1))=temp; 
      S_dd=S_dd*CH1;
      S_dd1=S_dd';
     
     sigma2_hat1=sum(dec.^2./S_dd1)/N1;
       
    fu=-1/2*((N1*log(2*pi*sigma2_hat1))+sum(log(abs(S_dd1))))...
    -1/2*N1;
    S_dd(:)=zeros(1,N1);
end
%===================================================================
if bool || loop==1
    
   CH2=4*gamma(T+2)*sin(pi*(1+T)/2)/(2*pi)^(T+2);
   for i=1:J
       j1=-j0(i);
       temp=intSDFc(2^(j1-1),2^j1,N0,dt,(1+T)/2); 
       temp=2^(-j1+1)*temp;
       if i==1
           ta=L(i)+1;
           tb=L(i)+L(i+1);
       else
           ta=tb+1;
           tb=tb+L(i+1);
       end
       S_dd(ta:tb)=temp;
   end
      temp=intSDFc(0,2^(-J-1),N0,dt,(1+T)/2); 
      temp=2^(J+1)*temp;
      S_dd(1:L(1))=temp;  
      S_dd=S_dd*CH2;
      S_dd2=S_dd';
   
     sigma2_hat2=sum(dec.^2./S_dd2)/N1;
       
     fT=-1/2*((N1*log(2*pi*sigma2_hat2))+sum(log(abs(S_dd2))))...
     -1/2*N1;
    S_dd(:)=zeros(1,N1);
end
%========================================================================
    if fT>fu
        ma=u; u=T;
        T=ma+g*(mb-ma);
        bool=1;
        fu=fT;
    else
        mb=T;  T=u;
        u=mb-g*(mb-ma);
        bool=0;
        fT=fu;
    end
   delta=T-u;
   loop=loop+1;
end
if fu>fT
    Ds=diag(1./S_dd1);
    B1=(Xw'*Ds*Xw)\(Xw'*Ds*Yw);
else
    Ds=diag(1./S_dd2);
    B1=(Xw'*Ds*Xw)\(Xw'*Ds*Yw);
end
    dB1=norm(B1-B0,1);
    if dB1==dB
        break;
    else
        dB=dB1;
    end
%     B0,B1
    B0=B1;
end
% ==========================第五步=====================================
if fu>fT
    H=(u+1)/2;
    sigma=sqrt(sigma2_hat1);
else
    H=(T+1)/2;
    sigma=sqrt(sigma2_hat2);
end
% ==========================The end=====================================