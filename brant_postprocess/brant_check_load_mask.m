function [mask_hdr, mask_ind, size_mask, mask_new] = brant_check_load_mask(mask_raw, sample_raw, outdir)
% check, reslice using nearest neighbour and load mask
% use load_nii_mod to be concordance with save_nii_mod outside the function

[pth, mask_fn_raw, ext] = fileparts(mask_raw);

if ~(exist(fullfile(outdir, [mask_fn_raw, ext]), 'file') == 2)
    brant_copyfile(mask_raw, outdir);
end

mask_fn = fullfile(outdir, [mask_fn_raw, ext]);

fprintf('Mask has been copied from %s to %s.\n', mask_raw, mask_fn);

% use only the first sample
sample_fn = brant_get_sample(sample_raw, outdir);

% check mask with sample
mask_nii = load_nii_mod(mask_fn, 1);
sample_nii = load_nii_mod(sample_fn, 1);
sts = brant_spm_check_orientations([mask_nii.hdr, sample_nii.hdr]);

if (sts == false)
    res_prefix = 'resliced_';
    brant_reslice(sample_fn, mask_fn, res_prefix);
    mask_new = fullfile(outdir, [res_prefix, mask_fn_raw, ext]);
    mask_nii = load_nii_mod(mask_new);
else
    mask_new = mask_fn;
end

% would induce uncertinty, for each sample, the output mask will be
% slightly different
% good_sample_ind = isfinite(sample_nii.img) & (sample_nii.img ~= 0);
% if ~all(good_sample_ind(:))
%     mask_nii.img(~good_sample_ind) = 0;
%     res_prefix = 'nozero_';
%     [pth, mask_fn_raw, ext] = fileparts(mask_new);
%     mask_new = fullfile(outdir, [res_prefix, mask_fn_raw, ext]);
%     save_nii(mask_nii, mask_new);
% end

mask_hdr = mask_nii.hdr;
mask_ind = find(mask_nii.img > 0.5);
size_mask = mask_nii.hdr.dime.dim(2:4);




function sample_out = brant_get_sample(sample_raw, outdir)
% sample fn could be either multiple 3D files or one 4D file
if iscell(sample_raw)
    sample_out = sample_raw{1};
else
    sample_out = sample_raw;
end

if strcmpi(sample_out(end-2:end), '.gz')
    [pth, fn, ext] = fileparts(sample_out); %#ok<*ASGLU>
    tmp_ref = load_untouch_nii_mod(sample_out, 1);
    sample_out = fullfile(outdir, ['first_vol_', fn]);
    save_untouch_nii_mod(tmp_ref, sample_out);
end