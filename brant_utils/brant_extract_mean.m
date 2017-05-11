function brant_extract_mean(jobman)
% mask to mask correlation matrix index

outdir = jobman.out_dir{1};
if exist(outdir, 'dir') ~= 7, mkdir(outdir); end

matrix_ind = 0;
volume_ind = 0;
roi_index = jobman.roi_index{1};
roi_info = jobman.roi_info{1};
if jobman.matrix == 1
    matrix_ind = 1;
    if isempty(jobman.corr_mask{1})
        corr_mask = true;
    else
        corr_mask = load(jobman.corr_mask{1}) ~= 0;
    end
else
    volume_ind = 1;
    rois = jobman.rois;
    mask_fn = jobman.input_nifti.mask{1};
end

if volume_ind == 1
    jobman.input_nifti.single_3d = 1;
    [nifti_list, subj_ids_org_tmp] = brant_get_subjs(jobman.input_nifti);
    
    [unused1, unused2, unused3, rois_resliced] = brant_check_load_mask(rois{1}, nifti_list{1}, outdir); %#ok<ASGLU>
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, outdir); %#ok<ASGLU>
elseif matrix_ind == 1
    node_out = brant_parse_node(roi_info);
    rois_str = node_out.label;
%     roi_mat = importdata(roi_info, '\n');
%     roi_info_tmp = regexpi(roi_mat, '[\s,]+', 'split');
%     rois_str = cellfun(@(x) x{2}, roi_info_tmp, 'UniformOutput', false);
    [mat_list, subj_ids_org_tmp] = brant_get_subjs(jobman.input_matrix);
else
    error('Unknown input!');
end

% subj_ids_org = strrep(subj_ids_org_tmp, jobman.subj_prefix, '');
subj_ids_org = brant_rm_strs(subj_ids_org_tmp, jobman.subj_prefix);

if matrix_ind == 1
    [data_2d_mat, corr_ind] = brant_load_matrices_to_2d(mat_list, jobman.sym_ind, 0, corr_mask);
elseif volume_ind == 1
    
    show_msg = 1;
    [rois_inds, rois_str] = brant_get_rois({rois_resliced}, size_mask, roi_index, show_msg);
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
    ts_rois_tmp = cellfun(@(x) nanmean(data_2d_mat(:, x), 2), rois_inds_new, 'UniformOutput', false);
    ts_rois = cat(2, ts_rois_tmp{:});
    
    tbl = [['Name', rois_str_out']; subj_ids_org, num2cell(ts_rois)];
    brant_write_csv(fullfile(outdir, 'brant_mean_roi.csv'), tbl);
else
    [x, y] = find(corr_ind);
    fc_strs = cellfun(@(x, y) [x, '--', y], rois_str(x), rois_str(y), 'UniformOutput', false);
    dlmwrite(fullfile(outdir, 'corr_ind.csv'), corr_ind);
    
    data_size = size(data_2d_mat);
    % write to a matrix file and *.mat file
    if jobman.ASCII == 1
        dlmwrite(fullfile(outdir, 'brant_fc_value_numbers_ascii.txt'), data_2d_mat);
        info_readme = 'Extracted matrix is arranged as subjs (rows) x FCs (columns). Use ''load'' command to load text matrix. Please refer to loaded parameters ''subj_ids_org'' and ''fc_strs'''; %#ok<NASGU>
    else
        brant_save_mat_bin(fullfile(outdir, 'brant_fc_value_numbers_bin.bin'), single(data_2d_mat), 'single');
%         fid = fopen(fullfile(outdir, 'brant_fc_value_numbers_bin.txt'), 'wt');
%         fwrite(fid, single(data_2d_mat), 'single');
%         fclose(fid);
        data_size_str = sprintf('%d,',data_size(:));
        fprintf('\tSaving matrix finished! You can load the data with\n\tdata_mat = brant_load_mat_bin(''%s'', [%s], ''single'');\n', fullfile(outdir, 'brant_fc_value_numbers_bin.bin'), data_size_str(1:end-1));
        fprintf('\n\tSubject ids and ROI information were stored in\n\t%s\n\n', fullfile(outdir, 'brant_fc_matrix_info.mat'));
        info_readme = 'Extracted matrix is arranged as subjs (rows) x FCs (columns). Use ''brant_load_mat_bin'' command to load text matrix. Please refer to loaded parameters ''subj_ids_org'' and ''fc_strs'''; %#ok<NASGU>
    end
    save(fullfile(outdir, 'brant_fc_matrix_info.mat'), 'subj_ids_org', 'fc_strs', 'info_readme', 'data_size', 'rois_str');
    
%     % write a full/large csv file
%     tbl = [['Name', fc_strs']; subj_ids_org, num2cell(single(data_2d_mat))];
%     brant_write_csv(fullfile(outdir, 'brant_fc_value.csv'), tbl);
end

fprintf('\tFinished.\n');
