function brant_tsnr(jobman)

outdir = jobman.out_dir{1};
if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end

mask_nii = load_nii(jobman.mask{1});
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_ind = find(mask_nii.img > 0.5);
% [mask_x, mask_y, mask_z] = ind2sub(size_mask, mask_ind);

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);

tsnr_ts_3d_mean = 0;
for m = 1:numel(nifti_list)
    
    [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m}); %#ok<ASGLU>
    brant_spm_check_orientations([mask_nii.hdr, nii_hdr]);
    
    % do not use matrix operation (sometimes out of memory)
    tsnr_ts = mean(data_2d_mat, 1) ./ std(data_2d_mat, 0, 1);
    tsnr_ts_3d_mean = double(tsnr_ts_3d_mean) + tsnr_ts ./ numel(nifti_list);
    
    tsnr_ts_3d = nan(size_mask, 'single');
    tsnr_ts_3d(mask_ind) = tsnr_ts;
    
    filename = fullfile(outdir, ['TSNR_', subj_ids{m}, '.nii']);
    nii = make_nii(tsnr_ts_3d, mask_nii.hdr.dime.pixdim(2:4), mask_nii.hdr.hist.originator(1:3)); 
    save_nii(nii, filename);

    fprintf('\t%s finished...\n', subj_ids{m});
end
fprintf('\n\tAll finished.\n');

tsnr_ts_3d = nan(size_mask, 'single');
tsnr_ts_3d(mask_ind) = tsnr_ts_3d_mean;
filename = fullfile(outdir, 'TSNR_mean.nii');
nii = make_nii(tsnr_ts_3d, mask_nii.hdr.dime.pixdim(2:4), mask_nii.hdr.hist.originator(1:3)); 
save_nii(nii, filename);
