function t_mat = brant_multi_thres_t_ttest2(p_vec_L, p_vec_R, p_thr, mc_type, t_mat)
% one tail multiple correction for each side


[p_tmp_l, sts_l] = brant_MulCC(p_vec_L, p_thr, mc_type);
[p_tmp_r, sts_r] = brant_MulCC(p_vec_R, p_thr, mc_type);

p_mask_l = p_vec_L <= p_tmp_l;
p_mask_r = p_vec_R <= p_tmp_r;

t_mask = false(size(p_vec_L));
if (sts_l == 1)
    t_mask = t_mask | p_mask_l;
end

if (sts_r == 1)
    t_mask = t_mask | p_mask_r;
end

t_mat(~t_mask) = 0;