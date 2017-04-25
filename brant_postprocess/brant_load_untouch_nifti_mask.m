function [nii_2d, nii_size, nii_hdr] = brant_load_untouch_nifti_mask(nifti_files, mask_ind)
% nifti_files format: 4-d data stored as string, 
% 3-d data stored in cell array

if ischar(nifti_files)
    nifti_files = {nifti_files};
    num_files = 1;
elseif iscell(nifti_files)
    num_files = numel(nifti_files);
end

if num_files == 1
% if ~iscell(nifti_files) % should be one 4-D file
    nii = load_untouch_nii_mod(nifti_files{1});
    nii_hdr = nii.hdr;
    nii_size = nii.hdr.dime.dim(2:5);
    
    nii_2d_tmp = shiftdim(nii.img, 3);
    nii_2d = reshape(nii_2d_tmp, nii_size(4), []);
    if ~isempty(mask_ind)
        nii_2d = nii_2d(:, mask_ind);
    end
else    
    for m = 1:num_files
        nii_tmp = load_untouch_nii_mod(nifti_files{m});
%         nii_tmp.img = nii_tmp.img / nanmean(nii_tmp.img(:)); % only for PET
        if m == 1
            nii_hdr = nii_tmp.hdr;
            nii_size = nii_tmp.hdr.dime.dim(2:4);
            nii_size(4) = num_files;
                
            if isempty(mask_ind)
                nii_2d = zeros([num_files, prod(nii_size(1:3))]);
            else
                nii_2d = zeros([num_files, numel(mask_ind)]);
            end
        end
        
        if isempty(mask_ind)
            nii_2d(m, :) = reshape(nii_tmp.img, 1, []);
        else
            nii_2d(m, :) = nii_tmp.img(mask_ind);
        end
    end
end

if ((isa(nii_2d, 'double') == 0) && (isa(nii_2d, 'single') == 0))
    nii_2d = single(nii_2d);
end
