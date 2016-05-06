function  [pL,pR,H0,alpha]   =  brant_truncated_alpha(N)
% This function is used to estimate the parameter of MPE in the case of
% truncated data 

% discard the INF value to refine the following caculation
% I = 50;
% H0 = H0([1:I-1 I+1:end]); 

POLY=7;
if mod(N,2)
    N=N-1;
end
H0 = 0.01:0.01:0.99;%Hurst exponent

% discard the INF value to refine the following caculation
% I = 50;
% H0 = H0([1:I-1 I+1:end]); 

L = length(H0);
j = -(N-1):N-1;
alpha = zeros(1,L);

f=1/N:1/N:(0.5-1/N);
% M=cos(2*pi*f'*j);
s=zeros(1,N/2-1);
for i = 1:L
    H = H0(i);
    c=(abs(j+1).^(2*H)+abs(j-1).^(2*H)-2*abs(j).^(2*H)).*(N-abs(j));
%    c=(abs(j+1).^(2*H)+abs(j-1).^(2*H)-2*abs(j).^(2*H));
    c=c/N;
    for p=1:N/2-1
        s(p)=sum(c.*cos(2*pi*f(p)*j));
    end
    s=s/2;
%     A=repmat(c,[N/2-1,1]);
%     s=sum(A.*M,2)/2;
    s=smooth(s);
    Y = log(s);X = [ones(N/2-1,1) log(f)'];
    B  =  regress(Y,X);
    alpha(i) = B(2);
end
portion=50;
pL = polyfit(H0(1:portion),alpha(1:portion),POLY);
pR = polyfit(H0(portion:L),alpha(portion:L),POLY);

% save alpha_N2_7 H0 alpha
% plot(H0,alpha)
%===========================The end==================================
