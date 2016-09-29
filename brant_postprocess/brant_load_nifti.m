function [nii_4d, nii_size] = brant_load_nifti(nifti_files, is4d_ind)


if is4d_ind == 1
    nii = load_nii(nifti_files);
    nii_4d = nii.img;
    nii_size = nii.hdr.dime.dim(2:5);
else
    nii_hdr = load_nii_hdr(nifti_files{1});
	num_tps = numel(nifti_files);
    nii_size = [nii_hdr.dime.dim(2:4), num_tps];
    
    nii_4d = zeros(nii_size, 'single');
    for m = 1:num_tps
        nii_tmp = load_nii(nifti_files{m});
        nii_4d(:, :, :, m) = nii_tmp.img;
    end
end

if ((isa(nii_4d, 'double') == 0) && (isa(nii_4d, 'single') == 0))
    nii_4d = single(nii_4d);
end
