function  am=dilatation(a, m)
% dilatation m times of filter a
la = length(a);
am = zeros(1, m * la - 1);
am(1:m:m*la-1) = a;

