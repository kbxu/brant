function [mask_ind_new, sts] = brant_check_mask(image_3d, mask_ind_old, subj_id)

mask_nan = isnan(image_3d(mask_ind_old));
mask_inf = isinf(image_3d(mask_ind_old));

mask_bad = mask_nan | mask_inf;
if any(mask_bad)
    sts = 1;
    mask_ind_new = mask_ind_old(~mask_bad);
    warning(sprintf('NaN values are found within the masked data for subject %s!\nNaN voxels will not be included in the calculation of mean value within the mask!', subj_id)); %#ok<*SPWRN>
else
    sts = 0;
    mask_ind_new = mask_ind_old;
end
