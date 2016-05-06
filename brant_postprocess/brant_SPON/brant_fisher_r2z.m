function z_val = brant_fisher_r2z(r)
if  r==1
           r = 0.99;
elseif abs(r)>1
    error('The range for r is -1 to 1\n');
else
    %%% do nothing
end
z_val = 0.5*log((1+r)./(1-r));
% if size(z_val,1)>=2
