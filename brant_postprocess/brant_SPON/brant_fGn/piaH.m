function y=piaH(a,H,i)

l = length(a) - 1;
d = l + 1;
mat = zeros(d);
for q = 0:l 
     for r = 0:l
        z = a(q + 1) * a(r + 1) * abs(q - r + i)^(2 * H);
        mat(q + 1, r + 1) = -0.5 * z;
     end
end
y = sum(sum(mat));