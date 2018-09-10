function brant_tsnr(jobman)

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

mask_fn = jobman.input_nifti.mask{1};
outdir = jobman.out_dir{1};
thres = jobman.thres;

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
[mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, outdir);

tsnr_ts_3d_mean = 0;
for m = 1:numel(nifti_list)
    
    [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m}); %#ok<ASGLU>
    brant_spm_check_orientations([mask_hdr, nii_hdr]);
    
    % do not use matrix operation (sometimes out of memory)
    tsnr_ts = mean(data_2d_mat, 1) ./ std(data_2d_mat, 0, 1);
    tsnr_ts_3d_mean = double(tsnr_ts_3d_mean) + tsnr_ts ./ numel(nifti_list);
    
    tsnr_ts_3d = nan(size_mask, 'single');
    tsnr_ts_3d(mask_ind) = tsnr_ts;
    
    filename = fullfile(outdir, ['TSNR_', subj_ids{m}, '.nii']);
    nii = make_nii(tsnr_ts_3d, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
    save_nii(nii, filename);

    fprintf('\t%s finished...\n', subj_ids{m});
end

if numel(subj_ids) > 1
    imgsInOrder = cellfun(@(x) fullfile(outdir, ['TSNR_', x, '.nii']), subj_ids, 'UniformOutput', false);
    brant_image_calc(imgsInOrder, 'mean_TSNR.nii', {outdir}, 'mean(X)', 1);
    
    brant_image_calc({fullfile(outdir, 'mean_TSNR.nii')}, sprintf('mean_TSNR_mask_thres%.1f.nii', thres), {outdir}, sprintf('i1>%.1f', thres), 0);
end

fprintf('\n\tAll finished.\n');