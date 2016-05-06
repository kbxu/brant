function brant_statistics_vox(jobman)

% t-test2, unequal, right-tail
% T = tinv(1 - p, df)
% p = 1 - tinv(T, df)
jobman.spm = 1;

if jobman.spm == 1
    brant_spm_ttest2(jobman);
    return;
end

num_gps = numel(jobman.subj_infos.subjs);

if num_gps < 2
    error('\tNumber of input groups should be at lease 2!\n');
else
    fprintf('\tNumber of groups is %d\n', num_gps);
end

gp_ind_up = triu(ones(num_gps), 1);

[group_up_1, group_up_2] = find(gp_ind_up);

group_subjs_data = cell(num_gps, 1);
for m = 1:num_gps
    num_subjs(m) = numel(jobman.subj_infos.subjs{m});
    group_subjs_data{m} = zeros([jobman.subj_infos.size_mask, num_subjs(m)], 'single');
    
    fprintf('\tLoading data for subject %s\n', jobman.subj_infos.paths{m});
    for n = 1:num_subjs(m)
        tmp_data = load_nii(jobman.subj_infos.subjs{m}{n});
        group_subjs_data{m}(:, :, :, n) = tmp_data.img;
    end
end

for m = 1:numel(group_up_1)
    group_1_ind = group_up_1(m);
    group_2_ind = group_up_2(m);
    
    gp_cmp = [jobman.subj_infos.subjnames{group_1_ind}, '_gt_', jobman.subj_infos.subjnames{group_2_ind}];
    fprintf('\tRunning t-test2 for %s\n', gp_cmp);
	discrip = sprintf('SPM{%c_[%.1f]}', 'T', num_subjs(group_1_ind) + num_subjs(group_2_ind) - 2);

    [h, p, ci, stats] = ttest2(group_subjs_data{group_1_ind}, group_subjs_data{group_2_ind}, 'dim', 4, 'Tail', 'right', 'Vartype', 'unequal'); %#ok<ASGLU,NASGU>
    
    fn_tmp = fullfile(jobman.out_dir, [gp_cmp, '_P_value.nii']);
    nii = make_nii(p .* jobman.subj_infos.mask, jobman.subj_infos.mask_hdr.dime.pixdim(2:4), jobman.subj_infos.mask_hdr.hist.originator(1:3), 16, discrip); 
    save_nii(nii, fn_tmp);
    
    fn_tmp = fullfile(jobman.out_dir, [gp_cmp, '_T_value.nii']);
    nii = make_nii(stats.tstat .* jobman.subj_infos.mask, jobman.subj_infos.mask_hdr.dime.pixdim(2:4), jobman.subj_infos.mask_hdr.hist.originator(1:3), 16, discrip); 
    save_nii(nii, fn_tmp);
end

fprintf('\n\tt-test2 finished!\n');
