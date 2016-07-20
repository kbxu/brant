function [rois_cell, rois_str, roi_tags, roi_hdr] = brant_get_rois(rois, size_mask, roi_info_fn, show_msg, varargin)
% if input many 3-D binary rois, use filename as roi strings
% if input tagged roi, use strings in roi info

if nargin == 5
    load_nifti_func = varargin{1};
else
    load_nifti_func = @load_nii;
end

% check and load roi files
roi_tags = 0;
if numel(rois) == 1
    roi_nii = load_nifti_func(rois{1});
    roi_tags = unique(roi_nii.img(isfinite(roi_nii.img) & (roi_nii.img ~= 0)));
    roi_hdr = roi_nii.hdr;
    
    if ~isempty(roi_info_fn)
        roi_info = importdata(roi_info_fn, '\n');
        roi_info_tmp = regexpi(roi_info, '[\s,]+', 'split');
        roi_ref_vals = cellfun(@(x) str2num(x{1}), roi_info_tmp); %#ok<ST2NM>
        roi_ref_strs = cellfun(@(x) x{2}, roi_info_tmp, 'UniformOutput', false);
    
        rois_ind_good = arrayfun(@(x) any(x == roi_ref_vals), roi_tags);
        if ~all(rois_ind_good)
            error([sprintf('The following labeled voxel in the volume do not have a reference in roi info file.\n'),...
                   sprintf('%d\n', roi_tags(rois_ind_good == 0))]);
        end
        
        rois_ind = arrayfun(@(x) find(x == roi_ref_vals), roi_tags);
        rois_str = roi_ref_strs(rois_ind);
    else
        rois_str = arrayfun(@(x) num2str(x, 'ROI_%03d'), roi_tags, 'UniformOutput', false);
    end

    rois_cell = arrayfun(@(x) roi_nii.img == x, roi_tags, 'UniformOutput', false);
    
    roi_size = roi_nii.hdr.dime.dim(2:4);
    roi_size_4d = roi_nii.hdr.dime.dim(5);
else
    roi_nii = cellfun(load_nifti_func, rois);
    roi_hdr = roi_nii(1).hdr;
%     rois_cell = arrayfun(@(x) find(x.img > 0.5), roi_nii, 'UniformOutput', false);
    rois_cell = arrayfun(@(x) x.img > 0.5, roi_nii, 'UniformOutput', false);
    
    roi_size = arrayfun(@(x) x.hdr.dime.dim(2:4), roi_nii, 'UniformOutput', false);
    roi_size_4d = cell2mat(arrayfun(@(x) x.hdr.dime.dim(5), roi_nii, 'UniformOutput', false));
    
    roi_size_chk = cell2mat(cellfun(@(x) any(x ~= roi_size{1}), roi_size, 'UniformOutput', false));
    if any(roi_size_4d > 1)
        error([sprintf('ROI files should have same sizes.\nThe sizes of listed roi files are different from %s\n', rois{1}),...
               sprintf('%s\n', rois{roi_size_chk})]);
    else
        roi_size = roi_size{1};
    end
    
    [pth, rois_str] = cellfun(@fileparts, rois, 'UniformOutput', false); %#ok<*ASGLU>
end

if any(roi_size_4d > 1)
    error(sprintf('\tROI should have 3 dimensions')); %#ok<*SPERR>
end

num_roi = numel(rois_cell);
uni_roi_ids = unique(rois_str);
if numel(uni_roi_ids) < num_roi
    num_same = cell2mat(cellfun(@(x) numel(find(strcmp(x, uni_roi_ids))), rois_str, 'UniformOutput', false));
    num_same_id = num_same > 1;
    error([sprintf('For roi identities, please use a different filename for each roi file!\n'),...
           sprintf('The following subject ids have more than one input.\n'),...
           sprintf('%s\n', rois_str{num_same_id})]);
end

if ~isempty(size_mask)
    if any(size_mask ~= roi_size)
        error('Size of brain mask is different from roi, please check!');
    end
end

if show_msg == 1
    num_vox = cellfun(@(x) numel(find(x)), rois_cell);
    arrayfun(@(x, y, z) fprintf('\tThe unmasked number of voxels marked as %s (%d) is %d\n', x{1}, y, z), rois_str, roi_tags, num_vox);
end
