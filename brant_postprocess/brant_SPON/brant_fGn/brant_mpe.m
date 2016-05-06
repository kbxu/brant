function [H,sigma,f,Sf] = brant_mpe(s,N,pL,pR,H0,alpha,trend,ind)
%该函数用来估计分形噪声序列的Husrt 指数
% N  =  length(s);

if nargin<7
    trend=0;
    ind=1;
end

if mod(N,2)
    N=N-1;
    s=s(1:N);
%     error('The length of the data must be an even number!');
end

temp  =  fftshift(abs(fft(s)));
% Sf  =  temp(N/2+2:N);
Sf  =  temp(N/2+2:N);
Sf = Sf.^2/N;
Sf  =  smooth(Sf)';%smoothing improve the rusults
% 
f0  =  linspace(-0.5,0.5,N);
% % f  =  f(N/2+2:N);
% f  =  f0(N/2+2:N);
f = 1/N:1/N:(0.5-1/N);

% X  =  [ones(N/2,1) log(f)'];
X  =  [ones(N/2-1,1) log(f)'];
Y  =  log(Sf);

% trunc=floor(N/10);
trunc=ind;
if trend
    X=X(trunc:end,:);
    Y=Y(trunc:end);
end

B  =  regress(Y',X);

k = B(2);
% H=interp1(alpha,H0,k,'spline');
% b1 = -0.6283;b2 = -0.1;

L=length(H0);
bool=(alpha(1)>alpha(L));

bool1=0;portion=50;
if bool
    if k>alpha(portion)
        pv=[pL(1:end-1) pL(end)-k];
        if pv(end)<0
            H=0;
        else
            bool1=1;
            a=0;b=H0(portion);
        end
    else
        pv=[pR(1:end-1) pR(end)-k];
        if sum(pv)>0
            H=1;
        else
            bool1=1;
            a=H0(portion);b=1;
        end
    end
else
    if k<alpha(portion)
        pv=[pL(1:end-1) pL(end)-k];
        if pv(end)>0
            H=0;
        else     
            bool1=1;
            a=0;b=H0(portion);
        end
    else
        pv=[pR(1:end-1) pR(end)-k];
        if sum(pv)<0
            H=1;
        else
            bool1=1;
            a=H0(portion);b=1;
        end
    end
end

if bool1
    fa=polyval(pv,a);
    fb=polyval(pv,b);
end
while bool1
      tp=(a+b)/2;ftp=polyval(pv,tp);
      if fa*ftp>0
           a=tp;fa=ftp;
      else
           b=tp;fb=ftp;
      end
      if abs(b-a)<0.0001
          H=(a+b)/2;
          break;
      end
 end


f = f0(N/2+1:N);
% sigma = 2*(sum(y(2:end-1))+(y(1)+y(end))/2)*(f0(2)-f0(1));
% sigma = sqrt(sigma);

Sf=temp(N/2+1:N);
Sf=smooth(Sf)';
sigma = 2*(sum(Sf(2:end-1))+(Sf(1)+Sf(end))/2)*(f0(2)-f0(1));
sigma = sqrt(sigma);

% plot(f,Sf,'b',f1,y,'r')
%===================The end===============================
