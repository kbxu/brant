function stat_out = brant_stat_raw(data_2d_raw, grp_stat, filter_est, data_infos, fil_inds, reg_good_subj, test_ind, out_info, varargin)

% stat_out(ooo, m).constrast_str = test_fn;
% stat_out(ooo, m).stat_val = stat_val;
% stat_out(ooo, m).df_stu = df_stu;
% stat_out(ooo, m).stat_info = stat_info;
stat_out = [];
% stat_out = struct('constrast_str', {}, 'stat_val',...
%                   {}, 'df_stu', {}, 'stat_info');

if nargin == 9
    paired_t_idx = varargin{1};
else
    paired_t_idx = []; 
end


student_t_ind = test_ind.student_t_ind;
ranksum_ind = test_ind.ranksum_ind;

one_samp_ind = test_ind.one_samp_ind;
two_samp_ind = test_ind.two_samp_ind;
paired_t_ind = test_ind.paired_t_ind;

subj_ids = data_infos(:, 1);
tbl_groups = unique(data_infos(:, 2));
% if (paired_t_ind == 1)
%     subj_ids = data_infos(2:end, :);
%     tbl_groups = unique(data_infos(1, :));
% else
%     subj_ids = data_infos(:, 1);
%     tbl_groups = unique(data_infos(:, 2));
% end

% % mean centering covariates
% raw_reg_good_subj = reg_good_subj;
% if ~isempty(raw_reg_good_subj)
%     mean_reg = mean(raw_reg_good_subj, 1);
%     reg_good_subj = bsxfun(@minus, raw_reg_good_subj, mean_reg);
% end
num_fil = numel(fil_inds);

% check group information for one same t test
if (one_samp_ind == 1)
    
    group_est_one = unique(parse_strs(grp_stat, 'group', 1));
    
    for ooo = 1:num_fil
        
        fil_tmp = fil_inds{ooo};
        group_inds = fil_tmp & cellfun(@(x) any(strcmpi(group_est_one, x)), data_infos(:, 2));
%         corr_2d_tmp = data_2d_raw(group_inds, :);

        for m = 1:numel(group_est_one)

            group_ind = fil_tmp & strcmpi(group_est_one{m}, data_infos(:, 2));
            subjs = data_infos(group_ind, :);
            
            if ~isempty(reg_good_subj)
                % mean centering covariates
                reg_tmp = reg_good_subj(group_ind, :);
                reg_good_subj_nm = bsxfun(@minus, reg_tmp, mean(reg_tmp, 1));
                                
                grp_reg_m = [ones(sum(group_ind), 1), reg_good_subj_nm];
                glm_beta = grp_reg_m \ data_2d_raw(group_ind, :);
                data_mat_2d = data_2d_raw(group_ind, :) - grp_reg_m(:, 2:end) * glm_beta(2:end, :);
            else
                grp_reg_m = [];
                data_mat_2d = data_2d_raw(group_ind, :);
            end
            
            
            if (student_t_ind == 1)
                if isempty(filter_est)
                    fprintf('\tRunning one sample t-test for %s\n', group_est_one{m});
                else
                    fprintf('\tRunning one sample t-test for %s of %s\n', group_est_one{m}, filter_est{ooo});
                end
                try
                    [h_vec_R, p_vec_R, ci, ttest_rst_stat] = ttest(data_mat_2d, 0, 'Alpha', out_info.thr, 'Tail', 'right');
%                     [o1, o2, ci, o3] = ttest(data_mat_2d, 0, 'Alpha', out_info.thr, 'Tail', 'both');
                catch
                    [h_vec_R, p_vec_R, ci, ttest_rst_stat] = ttest(data_mat_2d, 0, out_info.thr, 'right');
%                     [o1, o2, ci, o3] = ttest(data_mat_2d, 0, out_info.thr, 'right');
                end
            end
            
            stat_val = ttest_rst_stat.tstat;
            
%             if out_info.save_rst == 1
            df_stu = sum(group_ind) - 1;
            test_str = 'ttest';
            if isempty(filter_est)
                test_fn = sprintf('%s_%s', test_str, group_est_one{m});
            else
                test_fn = sprintf('%s_%s_%s', test_str, filter_est{ooo}, group_est_one{m});
            end

            fprintf('\n\tUncorrected p threshold is %g\n', out_info.thr);
            
            switch(out_info.data_type)
                case 'stat volume'
                    contr_str = sprintf('SPM{T_[%.1f]} - Contrast: %s', df_stu, group_est_one{m});
                    save_results_vox(out_info.outdir, out_info.out_prefix, out_info.size_mask, out_info.mask_ind, stat_val,...
                                     test_fn, out_info.mask_hdr, contr_str, out_info.multi_use, out_info.thr, p_vec_R, df_stu);
                case 'stat matrix'
                    save_results_mat(out_info.outdir, out_info.out_prefix, out_info.mat_size, out_info.sym_ind, '', stat_val, out_info.corr_ind,...
                                     test_fn, out_info.multi_use, out_info.thr, p_vec_R, group_est_one{m}, df_stu, subjs);
                case 'stat matrix - voxel to voxel'
                    out_fn_unc = fullfile(out_info.outdir, [out_info.out_prefix, sprintf('%s.mat', test_fn)]);
                    df = df_stu;
                    t_vec = stat_val;
                    save(out_fn_unc, 'group_est', 'p_vec_R', 't_vec', 'df', 'subjs', '-v7.3');
                otherwise
                    error('Unknown command!');
            end
        end
        clear('corr_2d_tmp');
    end
end

% check group information for two same t test
if (two_samp_ind == 1) || (paired_t_ind == 1)
    
    diary(fullfile(out_info.outdir, 'ttest2_diary.txt'));
    all_ttest2_grps = regexp(grp_stat, '[;,]', 'split');
    ttest2_groups_miss = setdiff(all_ttest2_grps, tbl_groups);
    if ~isempty(ttest2_groups_miss)
        error([sprintf('Groups listed in the table not found for two sample t-test information.\n'),...
               sprintf('%s\n', ttest2_groups_miss{:})]);
    end

    grp_csts = regexp(grp_stat, ';', 'split');
    ttest2_groups = cellfun(@(x) regexp(x, ',', 'split'), grp_csts, 'UniformOutput', false);
    if any(cellfun(@numel, ttest2_groups) ~= 2)
        error('There should be two groups for each contrast!');
    end
    
    num_csts = numel(grp_csts);
    num_grp_all = cell(num_csts, 1);
    cen_strs = cell(num_csts, 1);
    for ooo = 1:num_csts
        num_grp_all{ooo} = zeros(num_fil, 2);
        cen_strs{ooo} = cell(num_fil, 1);
    end
    
    contrs = {'gt', 'st', 'diff'};
    contrs_tail = {'right', 'left', 'both'};
    
    if ~isempty(reg_good_subj)
        grp_info_all = cell(num_fil, 1);
        regs_info_all = cell(num_fil, 1);
    end
    
    % find data index that needed in the two sample test
    for ooo = 1:num_fil
        
        fil_tmp = fil_inds{ooo};
        if ~any(fil_tmp)
            continue;
        end
        for m = 1:num_csts
            
            group_est = ttest2_groups{m};
            
%             if (paired_t_ind == 1)
%                 group_inds = true(size(subj_ids, 1), 1) & fil_tmp;
%                 grp_ind_tmp = cellfun(@(x) find(strcmpi(group_est, x)), data_infos(1, :));
%                 corr_2d_tmp = arrayfun(@(x) cat(2, data_2d_raw{group_inds, x})', grp_ind_tmp, 'UniformOutput', false);
%                 subj_ids_grp = subj_ids(group_inds, grp_ind_tmp);
%                 
%                 subjs = subj_ids(group_inds, :);
%                 num_grp1 = size(subjs, 1);
%                 num_grp2 = size(subjs, 1);
%             else
            group_inds = cellfun(@(x) any(strcmpi(group_est, x)), data_infos(:, 2));
            group_inds = group_inds & fil_tmp;
            subj_ids_grp = subj_ids(group_inds);
            corr_2d_tmp = data_2d_raw(group_inds, :);
            subjs = data_infos(group_inds, :);
            
            if (paired_t_ind == 1)
                %sort data if it's paired-t test
                paired_t_idx_fil = paired_t_idx(group_inds);                
                grp_1_idx = paired_t_idx_fil(strcmpi(group_est{1}, subjs(:, 2)));
                grp_2_idx = paired_t_idx_fil(strcmpi(group_est{2}, subjs(:, 2)));
                if any(sort(grp_1_idx) ~= sort(grp_2_idx))...
                       || (numel(unique(grp_1_idx)) ~= numel(grp_1_idx))...
                       || (numel(unique(grp_2_idx)) ~= numel(grp_2_idx))
                    error('Please check the index of paired_t_idx');
                end
                
                group_raw = subjs(:, 2);
                subj_ids_grp = sort_for_paired_t(subj_ids_grp, group_est, group_raw, paired_t_idx);
                subjs = sort_for_paired_t(subjs, group_est, group_raw, paired_t_idx);
                corr_2d_tmp = sort_for_paired_t(corr_2d_tmp, group_est, group_raw, paired_t_idx);
                           
                if ~isempty(reg_good_subj)
                    reg_tmp = sort_for_paired_t(reg_good_subj(group_inds, :), group_est, group_raw, paired_t_idx);
                else
                    reg_tmp = [];
                end
            else
                if ~isempty(reg_good_subj)
                    reg_tmp = reg_good_subj(group_inds, :);
                else
                    reg_tmp = [];
                end
            end
            
            % new group index
            group_inds_1 = strcmpi(group_est{1}, subjs(:, 2));
            group_inds_2 = strcmpi(group_est{2}, subjs(:, 2));

            num_grp1 = sum(group_inds_1);
            num_grp2 = sum(group_inds_2);
%             end

            if ~isempty(reg_tmp)
                % mean centering covariates
                fprintf('\n\tRegressing out covariates...\n');
                reg_good_subj_nm = bsxfun(@minus, reg_tmp, mean(reg_tmp, 1));

                grp_reg_m = [ones(sum(group_inds), 1), reg_good_subj_nm];
                glm_beta = grp_reg_m \ corr_2d_tmp;
                data_mat_2d = corr_2d_tmp - grp_reg_m(:, 2:end) * glm_beta(2:end, :);
                
%                 % test distribution normalization
%                 data_mat_2d = bsxfun(@minus, data_mat_2d, mean(data_mat_2d, 2));
%                 data_mat_2d = bsxfun(@rdivide, data_mat_2d, std(data_mat_2d, 0, 2));                
            else
                grp_reg_m = [];
                data_mat_2d = corr_2d_tmp;
            end
            
            clear('corr_2d_tmp');
           
            if ~isempty(reg_tmp) && (paired_t_ind == 0)
                grp_info_all{ooo} = subjs;
                regs_info_all{ooo} = reg_tmp;
                
                test_strs = cell(size(reg_tmp, 2), 1);
                p_reg = zeros(size(reg_tmp, 2), 1);
                for n = 1:size(reg_tmp, 2)
                    tmp = regs_info_all{ooo}(:, n);
                    if numel(unique(tmp)) > 2
                        test_strs{n} = 'ttest2';
                        try
                            [h_tmp, p_reg(n)] = ttest2(tmp(group_inds_1), tmp(group_inds_2), 'tail', 'both');
                        catch
                            [h_tmp, p_reg(n)] = ttest2(tmp(group_inds_1), tmp(group_inds_2), 0.05, 'both');
                        end
                    else
                        test_strs{n} = 'crosstab';
                        [tbl_tmp, chi2_tmp, p_reg(n)] = crosstab(tmp, group_inds_2);
                    end
                end
                
                p_strs = arrayfun(@num2str, p_reg, 'UniformOutput', false);%cellstr(num2str(p_reg));
                reg_stat_info = [['covariates'; out_info.reg_nm'], ['test_type'; test_strs], ['pval'; p_strs]];
            else
                reg_stat_info = '';
            end
            
            num_grp_all{m}(ooo, :) = [num_grp1, num_grp2];
            fprintf('\tThe number of subjects of %s is %d\n\tNumber of subjects of %s is %d\n',...
                                        group_est{1}, num_grp1,...
                                        group_est{2}, num_grp2);
            
            if (num_grp1 == 0) || (num_grp2 == 0)
                warning(sprintf('Insufficient subjects of group %s which will be skipped!', grp_csts{m})); %#ok<*SPWRN>
                continue;
            end
            
            if ~isempty(reg_tmp)
                reg_info = arrayfun(@num2str, reg_tmp, 'UniformOutput', false);%cellstr(num2str(reg_good_subj(group_inds, :)));
                reg_title = ['subject', out_info.reg_nm];
                subj_infos = [subj_ids_grp, reg_info];
            else
                subj_infos = subj_ids_grp;
                reg_title = 'subject';
            end
                
            if (paired_t_ind == 1)
                brant_print_cell([tbl_groups'; [subjs(group_inds_1, 1), subjs(group_inds_2, 1)]]);
            else
                if isempty(filter_est)
                    fprintf('\n\t%d subjects of group %s:\n', num_grp1, group_est{1});
                    brant_print_cell([reg_title; subj_infos(group_inds_1, :)]);
                    fprintf('\n\t%d subjects of group %s:\n', num_grp2, group_est{2});
                    brant_print_cell([reg_title; subj_infos(group_inds_2, :)]);
                else
                    fprintf('\n\t%d subjects of group %s for filter %s:\n', num_grp1, group_est{1}, filter_est{ooo});
                    brant_print_cell([reg_title; subj_infos(group_inds_1, :)]);
                    fprintf('\n\t%d subjects of group %s for filter %s:\n', num_grp2, group_est{2}, filter_est{ooo});
                    brant_print_cell([reg_title; subj_infos(group_inds_2, :)]);
                end
            end
            
            if ~isempty(reg_stat_info)
                fprintf('\tDemography statistics for covariates...\n');
                brant_print_cell(reg_stat_info);
            end
            
            clear('stat_info');
            
            stat_info.mean_grp_1_vec = mean(data_mat_2d(group_inds_1, :), 1);
            stat_info.mean_grp_2_vec = mean(data_mat_2d(group_inds_2, :), 1);
            stat_info.std_grp_1_vec = std(data_mat_2d(group_inds_1, :), [], 1);
            stat_info.std_grp_2_vec = std(data_mat_2d(group_inds_2, :), [], 1);
            stat_info.num_grp_1 = sum(group_inds_1);
            stat_info.num_grp_2 = sum(group_inds_2);
            
            if (student_t_ind == 1)
                if (paired_t_ind == 1)
                    if isempty(filter_est)
                        fprintf('\tRunning paired t-test for %s\n', grp_csts{m});
                    else
                        fprintf('\tRunning paired t-test for %s of %s\n', grp_csts{m}, filter_est{ooo});
                    end
                    
                    try
                        [h_vec_R, p_vec_R, oo, paired_t_stat] = ttest(data_mat_2d(group_inds_1, :), data_mat_2d(group_inds_2, :), 'Tail', 'right', 'Alpha', out_info.thr); %#ok<*ASGLU>
                    catch
                        [h_vec_R, p_vec_R, oo, paired_t_stat] = ttest(data_mat_2d(group_inds_1, :), data_mat_2d(group_inds_2, :), out_info.thr, 'right'); %#ok<*ASGLU>
                    end
                    stat_val = paired_t_stat.tstat;
                    df_stu = num_grp1 - 1;
                    test_str = 'paired_t';
                    contr_str = sprintf('SPM{T_[%.1f]} - Contrast: %s_vs_%s', df_stu, group_est{1}, group_est{2});
                else
                    if isempty(filter_est)
                        fprintf('\tRunning two sample t-test for %s\n', grp_csts{m});
                    else
                        fprintf('\tRunning two sample t-test for %s of %s\n', grp_csts{m}, filter_est{ooo});
                    end
                
                    try
                        [h_vec_R, p_vec_R, oo, ttest2_rst_stat] = ttest2(data_mat_2d(group_inds_1, :), data_mat_2d(group_inds_2, :), 'Tail', 'right', 'Alpha', out_info.thr); %#ok<*ASGLU>
                    catch
                        [h_vec_R, p_vec_R, oo, ttest2_rst_stat] = ttest2(data_mat_2d(group_inds_1, :), data_mat_2d(group_inds_2, :), out_info.thr, 'right'); %#ok<*ASGLU>
                    end
                    stat_val = ttest2_rst_stat.tstat;
                    df_stu = num_grp1 + num_grp2 - 2;
                    test_str = 'ttest2';
                    contr_str = sprintf('SPM{T_[%.1f]} - Contrast: %s_vs_%s', df_stu, group_est{1}, group_est{2});
                end
            end
            
            if (ranksum_ind == 1)
                if isempty(filter_est)
                    fprintf('\n\tRunning two sample ranksum test for %s\n', grp_csts{m});
                else
                    fprintf('\n\tRunning two sample ranksum test for %s of %s\n', grp_csts{m}, filter_est{ooo});
                end
                num_vox = size(data_mat_2d, 2);
                [p_vec_R, h_vec_R, ranksum_rst_stat] = arrayfun(@(x) ranksum(data_mat_2d(group_inds_1, x), data_mat_2d(group_inds_2, x), 'alpha', out_info.thr), 1:num_vox); %#ok<*ASGLU>
                stat_val = arrayfun(@(x) x.zval, ranksum_rst_stat);
                test_str = 'ranksum';
                contr_str = sprintf('SPM{Z_[1]} - Contrast: %s_vs_%s', group_est{1}, group_est{2});
            end
            
            
            if isempty(filter_est)
                test_fn = sprintf('%s_%s_vs_%s', test_str, group_est{1}, group_est{2});
            else
                test_fn = sprintf('%s_%s_%s_vs_%s', test_str, filter_est{ooo}, group_est{1}, group_est{2});
            end

            fprintf('\n\tUncorrected p threshold is %g\n', out_info.thr);
            
            switch(out_info.data_type)
                case 'stat volume'
                    save_results_vox(out_info.outdir, out_info.out_prefix, out_info.size_mask, out_info.mask_ind, stat_val,...
                                     test_fn, out_info.mask_hdr, contr_str, out_info.multi_use, out_info.thr, p_vec_R, df_stu);
                case 'stat matrix'
                    stat_out(ooo, m).constrast_str = test_fn;
                    if ~isempty(filter_est)
                        stat_out(ooo, m).filter = filter_est{ooo};
                    end
                    stat_out(ooo, m).stat_info = stat_info;
                    save_results_mat(out_info.outdir, out_info.out_prefix, out_info.mat_size, out_info.sym_ind, '', stat_val, out_info.corr_ind,...
                                     test_fn, out_info.multi_use, out_info.thr, p_vec_R, group_est, df_stu, subjs);
                case 'stat matrix - voxel to voxel'
                    out_fn_unc = fullfile(out_info.outdir, [out_info.out_prefix, sprintf('%s.mat', test_fn)]);
                    df = df_stu;
                    t_vec = stat_val;
                    save(out_fn_unc, 'group_est', 'p_vec_R', 't_vec', 'df', 'subjs', '-v7.3');
                case 'stat network'
                    stat_out(ooo, m).constrast_str = test_fn; %#ok<*AGROW>
                    stat_out(ooo, m).stat_val = stat_val;
                    stat_out(ooo, m).df_stu = df_stu;
                    stat_out(ooo, m).stat_info = stat_info;
                    stat_out(ooo, m).p_vec_R = p_vec_R;
                    stat_out(ooo, m).group_est = group_est;
                otherwise
                    error('Unknown command!');
            end
            
            cen_strs{m}{ooo} = test_fn;
        end
    end
    
    if (strcmpi(out_info.data_type, 'stat matrix - voxel to voxel') == 1)
        out_file = fullfile(out_info.outdir, 'output_fns.mat');
        if exist(out_file, 'file') ~= 2
            save(out_file, 'cen_strs');
        end
    else
        if strcmpi(out_info.data_type, 'stat matrix') == 1
            save(fullfile(out_info.outdir, [out_info.out_prefix, 'group_stat.mat']), 'stat_out');
        end
        if ((numel(ttest2_groups) == 1) && (strcmpi(out_info.data_type, 'stat network') == 0)) 
            for m = 1:num_csts
                A = [[{'center'}, {'group1'}, {'group2'}]; [cen_strs{m}, num2cell(num_grp_all{m})]];
                save(fullfile(out_info.outdir, [out_info.out_prefix, 'group_info.mat']), 'A');
                
                out_csv = fullfile(out_info.outdir, [out_info.out_prefix, strrep(grp_csts{m}, ',', '_'), '_group_info.csv']);
                brant_write_csv(out_csv, A);
            end
        end
    end
    diary('off');
end

function [sorted_arr, sorted_group] = sort_for_paired_t(data_arr, group_con, group, paired_t_idx)
% return sorted arrays that stacked over groups

grp_inds = cellfun(@(x) strcmpi(x, group), group_con, 'UniformOutput', false);
data_arr_tmp = cellfun(@(x) data_arr(x, :), grp_inds, 'UniformOutput', false);
paired_t_idx_tmp = cellfun(@(x) paired_t_idx(x, :), grp_inds, 'UniformOutput', false);
[pt_idx, sort_idx] = cellfun(@sort, paired_t_idx_tmp, 'UniformOutput', false);

sorted_arr = [data_arr_tmp{1}(sort_idx{1}, :); data_arr_tmp{2}(sort_idx{2}, :)];

if nargout == 2
    group_tmp = cellfun(@(x) group(x, :), grp_inds, 'UniformOutput', false);
    sorted_group = [group_tmp{1}(sort_idx{1}, :); group_tmp{2}(sort_idx{2}, :)];
end

function save_results_vox(outdir, out_prefix, size_mask, mask_ind_new, stat_val, test_fn, mask_hdr, contr_str, multi_use, thr, p_vec_R, df_stu)

contrs = {'gt', 'st', 'diff'};
contrs_tail = {'right', 'left', 'both'};
    
stat_val(~isfinite(stat_val)) = 0;
result_3d_nor = zeros(size_mask, 'double');
result_3d_nor(mask_ind_new) = stat_val;
out_fn_unc = [out_prefix, test_fn, '.nii'];
nii = make_nii(result_3d_nor, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3));
nii.hdr.hist.descrip = contr_str;
save_nii(nii, fullfile(outdir, out_fn_unc));


if ~isempty(multi_use)

    p_vec_L = 1 - p_vec_R;

    for n = 1:numel(multi_use)
        stat_val_thres = brant_multi_thres_t_ttest2(p_vec_L, p_vec_R, thr, multi_use{n}, stat_val);
        if any(stat_val_thres ~= 0)
            result_3d_mul = zeros(size_mask, 'double');
            result_3d_mul(mask_ind_new) = stat_val_thres;

            out_fn = [out_prefix, sprintf('%s_%s_%s.nii', multi_use{n}, num2str(thr, '%.3f'), test_fn)];
            nii = make_nii(result_3d_mul, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3));
            nii.hdr.hist.descrip = contr_str;
            save_nii(nii, fullfile(outdir, out_fn));
        end
    end
end

function save_results_mat(outdir, out_prefix, mat_size, sym_ind, rois_tag, stat_val, corr_ind, test_fn, multi_use, thr, p_vec_R, group_est, df, subjs) %#ok<INUSD,INUSL>

contrs = {'gt', 'st', 'diff'};
contrs_tail = {'right', 'left', 'both'};

% num_rois = numel(rois_str);
t_rst = zeros(mat_size, 'double');
t_rst_vec = stat_val;
t_rst(corr_ind) = t_rst_vec;
if (sym_ind == 1)
    t_rst = t_rst + t_rst';
end

p_rst_unc = cell(numel(contrs), 1);
h_rst_unc = cell(numel(contrs), 1);
tail_rst = cell(numel(contrs), 1);

p_vec_L = 1 - p_vec_R;
for n_contr = 1:numel(contrs)

    switch(contrs{n_contr})
        case 'gt'
            p_vec = p_vec_R;
        case 'st'
            p_vec = p_vec_L;
        case 'diff'
            p_vec = 2 * min([p_vec_R; p_vec_L]);
        otherwise
            error('unknown input!');
    end

    p_rst_unc{n_contr} = zeros(mat_size, 'double');
    p_rst_unc{n_contr}(corr_ind) = p_vec;
    if (sym_ind == 1)
        p_rst_unc{n_contr} = p_rst_unc{n_contr} + p_rst_unc{n_contr}'; %#ok<*NASGU>
    end

%     h_rst_unc{n_contr} = ((p_rst_unc{n_contr} < thr) & (p_rst_unc{n_contr} > 0)) .* sign(t_rst);
    h_rst_unc{n_contr} = (p_rst_unc{n_contr} < thr); % & (p_rst_unc{n_contr} > 0); due to accuracy loss, p could be 0
    tail_rst{n_contr} = contrs_tail{n_contr};
end

out_fn_unc = fullfile(outdir, [out_prefix, sprintf('%s.mat', test_fn)]);
save(out_fn_unc, 'group_est', 'tail_rst', 'p_rst_unc', 'h_rst_unc', 't_rst', 'df', 'subjs');

dlmwrite(fullfile(outdir, [out_prefix, sprintf('%s_pval_right_unc.txt', test_fn)]), p_rst_unc{1}); % group1 > group2
dlmwrite(fullfile(outdir, [out_prefix, sprintf('%s_pval_left_unc.txt', test_fn)]), p_rst_unc{2}); % group1 < group2
dlmwrite(fullfile(outdir, [out_prefix, sprintf('%s_tval.txt', test_fn)]), t_rst);
dlmwrite(fullfile(outdir, [out_prefix, sprintf('%s_h_unc.txt', test_fn)]), h_rst_unc{1} - h_rst_unc{2});
clear('p_rst_unc', 'h_rst_unc', 't_rst');

if ~isempty(multi_use)
    stat_val_thres = [];

    for n = 1:numel(multi_use)
        t_mat_thres_tmp = brant_multi_thres_t_ttest2(p_vec_L, p_vec_R, thr, multi_use{n}, t_rst_vec);

        if any(t_mat_thres_tmp ~= 0)
            t_mat_thres_mat = zeros(mat_size, 'double');
            t_mat_thres_mat(corr_ind) = t_mat_thres_tmp;
            if (sym_ind == 1)
                t_mat_thres_mat = t_mat_thres_mat + t_mat_thres_mat';
            end

            h_rst.(multi_use{n}) = sign(t_mat_thres_mat);
        else
            h_rst.(multi_use{n}) = [];
        end
    end
    save(out_fn_unc, 'h_rst', '-append');

    for n = 1:numel(multi_use)
        if ~isempty(h_rst.(multi_use{n}))
            dlmwrite(fullfile(outdir, [out_prefix, sprintf('%s_h_%s.txt', test_fn, multi_use{n})]), h_rst.(multi_use{n}));
        end
    end
end

function brant_print_cell(cell_data)
% the first row must be a column of titles
num_row = size(cell_data, 1);
num_col = size(cell_data, 2);
width_col = zeros(num_col, 1);

print_format = '\t';
for m = 1:num_col
    max_tmp = max(cellfun(@length, cell_data(:, m)));
    width_col(m) = ceil(max_tmp / 7) * 7;
    if (rem(max_tmp, 7) == 0)
        width_col(m) = width_col(m) + 7;
    end
    print_format = [print_format, '%-', num2str(width_col(m)), 's'];
end

print_format = [print_format, '\n'];

for m = 1:num_row
    fprintf(print_format, cell_data{m, :});
end

fprintf('\n');
