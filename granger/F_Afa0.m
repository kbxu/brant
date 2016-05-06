function F0 = F_Afa0(n1,n2,afa0)
% fcdf is F cumulative distribution function
if nargin < 3
    afa0 = 0.05;
end
F0 = 0.0;
xc = 0.0;
yc = 0.0;
while yc < 1-afa0
  xc = xc+0.01;
  yc = fcdf(xc,n1,n2);%返回自由度为n1，n2的F累计分布函数，在xc处的值
end
F0 = xc-0.01;