function t_mat = brant_multi_thres_t(p_vec_L, p_vec_R, p_thr, mc_type, t_mat)
% one tail multiple correction for each side


[p_tmp_l, sts_l] = brant_MulCC(p_vec_L, p_thr, mc_type);
[p_tmp_r, sts_r] = brant_MulCC(p_vec_R, p_thr, mc_type);

if all([sts_l, sts_r] ~= -1)
    t_thr_l = spm_invNcdf(p_tmp_l);
    t_thr_r = -1 * spm_invNcdf(p_tmp_r);
    t_mask = t_mat > t_thr_r | t_mat < t_thr_l;
elseif sts_l ~= -1
    t_thr_l = spm_invNcdf(p_tmp_l);
    t_mask = t_mat < t_thr_l;
elseif sts_r ~= -1
    t_thr_r = -1 * spm_invNcdf(p_tmp_r);
    t_mask = t_mat > t_thr_r;
else
    t_mat = [];
    return;
end

t_mat(~t_mask) = 0;
