function [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_files, mask_ind, outtype, subjname)
% internal function

% output cell or mat 2d
if ~isempty(subjname)
    fprintf('\tExtracting time serieses from subject %s\n', subjname);
end

if isempty(nifti_files)
    error('No input file matched!');    
end

[nii_2d, data_size, nii_hdr] = brant_load_nifti_mask(nifti_files, mask_ind);

data_tps = data_size(4);

if strcmp(outtype, 'mat')
    data_2d_mat = nii_2d;
elseif strcmp(outtype, 'cell')
    data_2d_mat = arrayfun(@(x) nii_2d(:, x), 1:size(nii_2d, 2), 'UniformOutput', false);
else
    error('Unknown type!');
end
