function mean_tc = brant_extract_mean_tc(tc_masks, mask_type, src_imgs)

% masks -- could be mask tagged by positive numbers (chars) or a cell array of masks files or 3-D masks
% mask_type -- specify different types of masks
% src_imgs -- input volumes

if strcmpi(mask_type, 'template')
    if ischar(tc_masks)
        mask_tmp = load_nii(tc_masks);
        nums_tagged = setdiff(mask_tmp.img(:), 0);
    elseif isnumeric(tc_masks)
        nums_tagged = setdiff(tc_masks, 0);
    else
        error('Please either input a string of mask file or a 3-D matrix!');
    end
    
    num_masks = numel(nums_tagged);
    mask_ind = cell(num_masks, 1);
    for m = 1:num_masks
        mask_ind{m} = mask_tmp.img == nums_tagged(m);
    end
elseif strcmpi(mask_type, 'rois')
    
    if ischar(tc_masks) || isnumeric(tc_masks)
        tc_masks = {tc_masks};
    end

    if iscell(tc_masks)
        num_masks = numel(tc_masks);
        mask_ind = cell(num_masks, 1);
        if islogical(tc_masks{1})
            for m = 1:num_masks
                mask_ind{m} = tc_masks{m};
            end
        elseif isnumeric(tc_masks{1})
            for m = 1:num_masks
                mask_ind{m} = tc_masks{m} > 0.5;
            end
        else
            for m = 1:num_masks
                mask_tmp = load_nii(tc_masks{m});
                mask_ind{m} = mask_tmp.img > 0.5;
            end
        end
    else
        error('Please either input a string of mask file or an array of cells!')
    end
end

if iscell(src_imgs)
    num_subjs = numel(src_imgs);
    load_file_yes = 1;
elseif isnumeric(src_imgs)
    num_subjs = 1;
    vol_4d = src_imgs;
    load_file_yes = 0;
elseif ischar(src_imgs)
    num_subjs = 1;
    src_imgs_tmp = load_nii(src_imgs);
    vol_4d = src_imgs_tmp.img;
    load_file_yes = 0;
else
    error('Please either input a string of nifti file or an array of cells!');
end

mean_tc = cell(num_subjs, 1);
for m = 1:num_subjs
    if load_file_yes == 1
        src_imgs_tmp = load_nii(src_imgs{m});
        vol_4d = src_imgs_tmp.img;
    end
    
    num_tps = size(vol_4d, 4);
    mean_tc{m} = zeros(num_tps, num_masks);
    for n = 1:num_tps
        vol_tmp = squeeze(vol_4d(:, :, :, n));
        for o = 1:num_masks
            masked_vol_tmp = vol_tmp(mask_ind{o});
            masked_vol_ind = ~isnan(masked_vol_tmp); % inplicit mask
            mean_tc{m}(n, o) = mean(masked_vol_tmp(masked_vol_ind));
        end
    end
end
