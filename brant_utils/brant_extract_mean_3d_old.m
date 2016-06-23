function brant_extract_mean_3d(jobman)

out_dir = jobman.out_dir{1};
if exist(out_dir, 'dir') ~= 7
    mkdir(out_dir);
end

if isempty(jobman.regressors_tbl)
    error('A table of subject infomation is expected!');
end

matrix_ind = 0;
volume_ind = 0;
if jobman.matrix == 1
    matrix_ind = 1;
    fc_file = jobman.corr_mat{1};
else
    volume_ind = 1;
    rois = jobman.rois;
    roi_info = jobman.roi_info{1};
    mask_fn = jobman.input_nifti.mask{1};
end

discard_bad_ind = jobman.discard_bad_subj;
grp_regr_strs = jobman.regr_strs;
corr_scores_strs = jobman.corr_scores;
regressors_tbl = jobman.regressors_tbl{1};
grp_filter = jobman.grp_filter;
grp_est = jobman.groups;
nan_ourliers_ind = 0; % jobman.nan_outliers;


out_prefix = jobman.out_prefix;


% if numel(rois) > 1 || isempty(jobman.roi_info{1})
%     roi_info = '';
% else
%     try
%         roi_info = importdata(jobman.roi_info{1}, '\n');    
%     catch err
%         warning('roi info file should be a txt file with its first two columns be the roi values and roi names!');
%         rethrow(err);
%     end
% end
    
if volume_ind == 1
    jobman.input_nifti.single_3d = 1;
    [nifti_list, subj_ids_org_tmp] = brant_get_subjs(jobman.input_nifti);
    subj_ids_org = strrep(subj_ids_org_tmp, jobman.subj_prefix, '');

    % mask roi files
    mask_nii = load_nii(mask_fn);
    size_mask = mask_nii.hdr.dime.dim(2:4);
    mask_bin = mask_nii.img > 0.5;
    mask_ind = find(mask_bin);
elseif matrix_ind == 1
    tmp = load(fc_file, 'subj_ids');
    subj_ids_org = tmp.subj_ids;
else
    error('Unknown input!');
end

group_est = parse_strs(grp_est, 'group', 1);
filter_est = parse_strs(grp_filter, 'filter', 0);
reg_est = parse_strs(grp_regr_strs, 'regressors', 0);
score_est = parse_strs(corr_scores_strs, 'regressors', 0);

[data_infos, subj_ind, fil_inds, reg_good_subj, corr_good_subj] = parse_subj_info2(regressors_tbl, subj_ids_org, group_est, filter_est, reg_est, score_est, discard_bad_ind);


if matrix_ind == 1
    data_2d_mat = load(fc_file, 'corr_z_tot');
    data_2d_mat = shiftdim(data_2d_mat.corr_z_tot(:, :, subj_ind), 2);
    corr_ind = triu(true(size(data_2d_mat, 2)), 1);
    data_2d_mat = data_2d_mat(:, corr_ind);
    num_roi = size(data_2d_mat, 2);
elseif volume_ind == 1
    data_2d_mat = brant_4D_to_mat_new(nifti_list(subj_ind), mask_ind, 'mat', '');
%     [data_2d_mat, data_tps, mask_ind_new] = brant_4D_to_mat(nifti_list(subj_ind), size_mask, mask_ind, 'mat', ''); %#ok<*ASGLU>

    show_msg = 1;
    [rois_inds, rois_str] = brant_get_rois(rois, size_mask, roi_info, show_msg);
    num_roi = numel(rois_str);
    mask_good_binary = zeros(size_mask);
    mask_good_binary(mask_ind) = 1:numel(mask_ind);
    mask_good_binary_zero = mask_good_binary == 0;
    rois_inds_new = cellfun(@(x) mask_good_binary(x & (~mask_good_binary_zero)), rois_inds, 'UniformOutput', false);
    num_vox = cellfun(@numel, rois_inds_new);
    arrayfun(@(x, y) fprintf('\tThe masked number of voxels marked as %s is %d\n', x{1}, y), rois_str, num_vox);
%     roi_infos = cellstr(strcat('The masked number of voxels marked as', 32, cell2mat(rois_str), 32, 'is', 32, num2str(num_vox)));
%     fprintf('\t%s\n', roi_infos{:});

    if isempty(roi_info)
        rois_str_out = cellfun(@(x) ['ROI_', x], rois_str, 'UniformOutput', false);
    else
        rois_str_out = rois_str;
    end

    rois_grp_strs_tmp = cellfun(@(x) strcat(rois_str_out, '_', x), group_est, 'UniformOutput', false);
    rois_grp_strs = cat(1, rois_grp_strs_tmp{:});

else
    error('Unknown input!');
end

subj_ids = data_infos(:, 1);


num_grp = numel(group_est);
group_inds_org = cellfun(@(x) any(strcmpi(group_est, x)), data_infos(:, 2));
num_fil = numel(fil_inds);
data_subjs = cell(num_fil, 1);
subj_strs = cell(num_fil, 1);
grp_strs = cell(num_fil, 1);

if ~isempty(corr_good_subj)
    corr_scores_r_out = cell(num_fil, 1);
    corr_scores_p_out = cell(num_fil, 1);
    corr_grp_strs_out = cell(num_fil, 1);
    scores_clinic = cell(num_fil, 1);
    reg_mat = cell(num_fil, 1);
end

if isempty(filter_est)
    filter_est{1} = 'Sheet1';
end

if ~isempty(reg_est)
    reg_subj_all = cell(num_fil, 1);
end

corr_type = 'Pearson';
corr_rows = 'pairwise';
for ooo = 1:num_fil

    fprintf('\tExtracting for %s\n', filter_est{ooo});
        
    group_inds = group_inds_org & fil_inds{ooo};
    subj_ids_grp = subj_ids(group_inds);

    if ~isempty(reg_good_subj)
        reg_info = cellstr(num2str(reg_good_subj(group_inds, :)));
        
        if ~isempty(corr_good_subj)
            corr_info = cellstr(num2str(corr_good_subj(group_inds, :)));
            subj_infos = strcat(subj_ids_grp, '   Regressors:', reg_info, '  Score:', corr_info);
        else
            subj_infos = strcat(subj_ids_grp, '   Regressors:', reg_info);
        end
    else
        subj_infos = subj_ids_grp;
    end
    
    if ~isempty(reg_good_subj)
        reg_grp = reg_good_subj(group_inds, :);
        reg_subj_all{ooo} = reg_grp;
    end
    
    corr_2d_raw = data_2d_mat(group_inds, :);
    
    if volume_ind == 1
        ts_rois_tmp = cellfun(@(x) mean(corr_2d_raw(:, x), 2), rois_inds_new, 'UniformOutput', false);
        ts_rois = cat(2, ts_rois_tmp{:});
    else
        ts_rois = corr_2d_raw;
    end
    
    if nan_ourliers_ind == 1
        ts_rois = exc_outlier(ts_rois);
    end
    
    subjs = data_infos(group_inds, :);
    
    group_inds_sub = cellfun(@(x) strcmpi(x, subjs(:, 2)), group_est, 'UniformOutput', false);
    num_subjs = cellfun(@sum, group_inds_sub);
    
    if ~isempty(corr_good_subj)
        corr_score_grp = corr_good_subj(group_inds, :);
    end
    
    corr_scores_r_out{ooo} = [];
    corr_scores_p_out{ooo} = [];
    corr_grp_strs_out{ooo} = [];
    
    scores_clinic{ooo} = cell(num_grp, 1);
    grp_strs{ooo} = cell(num_grp, 1);
    subj_strs{ooo} = cell(num_grp, 1);
    data_subjs{ooo} = cell(num_grp, 1);
    for n = 1:num_grp
        fprintf('\n\t%d subjects of group %s for filter %s:\n', num_subjs(n), group_est{n}, filter_est{ooo});
        fprintf('\t%s\n', subj_infos{group_inds_sub{n}});
        
        scores_tmp = corr_score_grp(group_inds_sub{n}, :);
        ts_rois_tmp = ts_rois(group_inds_sub{n}, :);
        if ~isempty(reg_good_subj)
            reg_tmp = reg_grp(group_inds_sub{n}, :);
        end
        
        if ~isempty(corr_good_subj)
            if ~isempty(reg_good_subj)
                [corr_scores_r_tmp, corr_scores_p_tmp] = partialcorr(scores_tmp, ts_rois_tmp, reg_tmp,...
                                                       'Type', corr_type, 'Rows', corr_rows);
            else
                [corr_scores_r_tmp, corr_scores_p_tmp] = corr(scores_tmp, ts_rois_tmp,...
                                                       'Type', corr_type, 'Rows', corr_rows);
            end
            
            if matrix_ind == 1
                corr_scores_r_out{ooo}{n} = corr_scores_r_tmp(corr_ind);
                corr_scores_p_out{ooo}{n} = corr_scores_p_tmp(corr_ind);
                corr_grp_strs_out{ooo}{n} = group_est{n};
            else
                % results of correlation
                corr_scores_r_out{ooo} = [corr_scores_r_out{ooo}; corr_scores_r_tmp'];
                corr_scores_p_out{ooo} = [corr_scores_p_out{ooo}; corr_scores_p_tmp'];
                corr_grp_strs_out{ooo} = [corr_grp_strs_out{ooo}; repmat(group_est(n), [num_roi, 1])];
            end
        end
        
        if ~isempty(reg_good_subj)
            reg_mat{ooo}{n} = reg_tmp;
        end
        scores_clinic{ooo}{n} = scores_tmp;
        data_subjs{ooo}{n} = ts_rois_tmp;
        subj_strs{ooo}{n} = subjs(group_inds_sub{n}, 1);
        grp_strs{ooo}{n} = subjs(group_inds_sub{n}, 2);
    end
end

if matrix_ind == 1
    corr_out_fn_tmp = fullfile(out_dir, [out_prefix, 'corr_coef']);
    save([corr_out_fn_tmp, '.mat'], 'corr_scores_r_out', 'corr_scores_p_out', 'corr_grp_strs_out', 'subj_strs');
elseif volume_ind == 1
    fprintf('\tWriting xls file...\n');
    if ~isempty(corr_good_subj)
        for ooo = 1:num_fil
            xls_info_corr{ooo} = [['rho'; rois_grp_strs; 'p'; rois_grp_strs],...
                                 [score_est; num2cell(corr_scores_r_out{ooo}); score_est; num2cell(corr_scores_p_out{ooo})]];
        end
        corr_out_fn_tmp = fullfile(out_dir, [out_prefix, 'corr_coef']);
        save([corr_out_fn_tmp, '.mat'], 'xls_info_corr', 'filter_est', 'corr_type', 'corr_rows');

        for ooo = 1:num_fil
            try
                corr_out_fn = [corr_out_fn_tmp, '.xlsx'];
                xlswrite(corr_out_fn, xls_info_corr{ooo}, filter_est{ooo});
            catch
                warning('Failed to create xls file!');
            end
        end
    end

    mean_vals_subj = cell(num_fil, 1);
    for ooo = 1:num_fil
        grp_strs_tmp = cat(1, grp_strs{ooo}{:});
        subj_strs_tmp = cat(1, subj_strs{ooo}{:});
        data_subjs_tmp = cat(1, data_subjs{ooo}{:});
        scores_clinic_tmp = cat(1, scores_clinic{ooo}{:});

        mean_vals_subj{ooo} = [[{'groups'}, {'id'}]; [grp_strs_tmp, subj_strs_tmp]];
        if ~isempty(reg_est)
            mean_vals_subj{ooo} = [mean_vals_subj{ooo}, [reg_est; num2cell(reg_subj_all{ooo})]];
        end
        if ~isempty(score_est)
            mean_vals_subj{ooo} = [mean_vals_subj{ooo}, [score_est; num2cell(scores_clinic_tmp)]];
        end
        mean_vals_subj{ooo} = [mean_vals_subj{ooo}, [rois_str_out'; num2cell(data_subjs_tmp)]];
    end

    mean_out_fn_tmp = fullfile(out_dir, [out_prefix, 'mean_value']);
    save([mean_out_fn_tmp, '.mat'], 'filter_est', 'mean_vals_subj');
    try
        fn_mean = [mean_out_fn_tmp, '.xlsx'];
        for ooo = 1:num_fil
            xlswrite(fn_mean, mean_vals_subj{ooo}, filter_est{ooo});
        end
    catch
        warning('Failed to create xls file!');
    end
else
    error('Unknown input!');
end

fprintf('\tFinished.\n');


function ts_rois = exc_outlier(ts_rois)

num_roi = size(ts_rois, 2);
for n = 1:num_roi
    tmp = ts_rois(:, n);
    bad_ind = 1;
    while any(bad_ind)
        if numel(bad_ind) == 1
            bad_ind = [];
        end
        tmp(bad_ind) = NaN;
        non_nan = ~isnan(tmp);

        mean_tmp = mean(tmp(non_nan));
        std_tmp = std(tmp(non_nan));

        bad_ind = abs(tmp - mean_tmp) > 3 * std_tmp;
    end
    ts_rois(:, n) = tmp;
end
