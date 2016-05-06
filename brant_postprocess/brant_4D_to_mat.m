function [data_2d_mat, data_tps, mask_ind_new, nii_hdr] = brant_4D_to_mat(nifti_files, size_mask, mask_ind, outtype, subjname)

% output cell or mat 2d
if ~isempty(subjname)
    fprintf('\tExtracting time serieses from subject %s\n', subjname);
end

if isempty(nifti_files)
    error('No input file matched!');    
end

[nii_2d, data_size, nii_hdr] = brant_load_nifti_mask(nifti_files, mask_ind);

data_tps = data_size(4);

if any(size_mask ~= data_size(1:3))
    error('The image of subject %s and the mask have different volume sizes!', subjname);
end

data_sample = nii_2d(1, :);
mask_ind_good = isfinite(data_sample) & (data_sample ~= 0);
mask_ind_new = mask_ind(mask_ind_good);

data_2d_mat_tmp = nii_2d(:, mask_ind_good);

if strcmp(outtype, 'cell')
    data_2d_mat = arrayfun(@(x) data_2d_mat_tmp(:, x), 1:size(data_2d_mat_tmp, 2), 'UniformOutput', false);
end

% if strcmp(outtype, 'mat')
%     data_2d_mat = nii_2d(:, mask_ind_good);
% elseif strcmp(outtype, 'cell')
%     data_2d_mat = arrayfun(@(x) nii_2d(:, x), 1:numel(mask_ind_new), 'UniformOutput', false);
% else
%     error('Unknown type!');
% end
