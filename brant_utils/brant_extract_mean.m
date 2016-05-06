function brant_extract_mean(jobman)

% jobman.mask = {'D:\SZ_Anatomy_Index\aal_mask_3mm_mod.nii'};
outdir = jobman.out_dir{1};
if exist(outdir, 'dir') ~= 7, mkdir(outdir); end

matrix_ind = 0;
volume_ind = 0;
if jobman.matrix == 1
    matrix_ind = 1;
    fc_file = jobman.corr_mat{1};
else
    volume_ind = 1;
    rois = jobman.rois;
    roi_info = jobman.roi_info{1};
    mask_fn = jobman.mask{1};
end

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

if matrix_ind == 1
    data_2d_mat = load(fc_file, 'corr_z_tot');
    data_2d_mat = shiftdim(data_2d_mat.corr_z_tot(:, :, subj_ind), 2);
    corr_ind = triu(true(size(data_2d_mat, 2)), 1);
    data_2d_mat = data_2d_mat(:, corr_ind);
%     num_roi = size(data_2d_mat, 2);
elseif volume_ind == 1
    
    show_msg = 1;
    [rois_inds, rois_str] = brant_get_rois(rois, size_mask, roi_info, show_msg);
%     num_roi = numel(rois_str);
    mask_good_binary = zeros(size_mask);
    mask_good_binary(mask_ind) = 1:numel(mask_ind);
    mask_good_bin_nonzero = mask_good_binary ~= 0;
    rois_inds_new = cellfun(@(x) mask_good_binary(x & mask_good_bin_nonzero), rois_inds, 'UniformOutput', false);
    
    num_vox_raw = cellfun(@(x) sum(x(:)), rois_inds);
    num_vox = cellfun(@numel, rois_inds_new);
    
    diff_ind = find(num_vox_raw ~= num_vox);
    if any(diff_ind)
        fprintf('\n');
        arrayfun(@(x, y, z) fprintf('\tThe changed roi size (masked) marked as %s is %d (raw %d)\n', x{1}, y, z), rois_str(diff_ind), num_vox(diff_ind), num_vox_raw(diff_ind));
    end
    
    rois_str_out = rois_str;
    
    fprintf('\tLoading data...\n');
    data_2d_mat = brant_4D_to_mat_new(nifti_list, mask_ind, 'mat', '');
    fprintf('\tFinished loading data...\n');
else
    error('Unknown input!');
end

if volume_ind == 1
    ts_rois_tmp = cellfun(@(x) mean(data_2d_mat(:, x), 2), rois_inds_new, 'UniformOutput', false);
    ts_rois = cat(2, ts_rois_tmp{:});
    
    tbl = [['Name', rois_str_out']; subj_ids_org, num2cell(ts_rois)];
    xlswrite(fullfile(outdir, 'brant_mean_value.xlsx'), tbl, 'volume');
else
    fc_strs = arrayfun(@(x) num2str(x, 'fc%05d'), 1:size(data_2d_mat, 2), 'UniformOutput', false);
    tbl = [['Name', fc_strs]; subj_ids_org, num2cell(single(data_2d_mat))]; %#ok<NASGU>
    save(fullfile(outdir, 'brant_mean_value.mat'), 'tbl');
    
%     xlswrite(fullfile(outdir, 'brant_mean_value.xlsx'), tbl, 'mat');
end

fprintf('\tFinished.\n');