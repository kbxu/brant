function y=intsfwm(a,b,m,dt,H,K)
%该函数是计算给定区间[a,b]上真实的SDF值

h=b-a;
N=1;
while h>dt
    N=N*2;
    h=h/2;
end
   h=2*h;
   N=N/2;
f=a+((1:N)-1/2)*h;
j=-m+1:m-1;

Sf=zeros(1,N);
p=2*H+1;
temp=abs(m/(p-1)+0.5+p/(12*m))/(m^p)-p*(p+1)*(p+2)/(720*m^(p+3));
temp=2*temp;
for i=1:N
    Sf(i)=(sin(pi*f(i)))^2*(sum((abs(f(i)+j)).^(-p))+temp);
end
y=zeros(1,K);
for j=1:K
    y(j)=2*sum(1./Sf.*cos(2*pi*(j-1)*f))*h;
end
%===============================The end=====================