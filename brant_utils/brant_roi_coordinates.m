function roi_info = brant_roi_coordinates(jobman)
% used by roi calculation and roi coordinates

brant_check_empty(jobman.template_img{1}, '\tAn ROI file is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');

is_label_ind = jobman.lab_c;
is_sep_ind = jobman.sep_c;
mask_fn = jobman.mask_in{1};
cs_thr = jobman.cs_thr;
tpl_fn = jobman.template_img{1};
tpl_info = jobman.template_info{1};
outdir = jobman.out_dir{1};

tol = 0.3;

if isfield(jobman, 'from_roi_calc')
    v_opt = jobman.from_roi_calc;
else
    v_opt = 0;
end

if is_sep_ind == 1
    tpl_old = load_untouch_nii_mod(tpl_fn);
    tpl_numbered = bwlabeln(tpl_old.img > 0.5);
    tpl_old.img = tpl_numbered;
    [pth, fn, ext] = fileparts(tpl_fn); %#ok<ASGLU>
    tpl_new = fullfile(outdir, ['tagged_', fn, ext]);
    save_untouch_nii_mod(tpl_old, tpl_new);
    
    jobman.template_img{1} = tpl_new;
    jobman.template_info{1} = '';
    jobman.lab_c = 1;
    jobman.sep_c = 0;
    brant_roi_coordinates(jobman);
    return;
end

if is_label_ind == 1
    
    if ~isempty(mask_fn)
        [xyz_hdr, xyz_ind, size_xyz] = brant_check_load_mask(mask_fn, tpl_fn, outdir);
        fprintf('\n\tThe brain mask will be applied for ROI masks.\n\n');
    else
        tpl_data = load_nii_mod(tpl_fn);
        xyz_hdr = tpl_data.hdr;
        xyz_ind = find(abs(tpl_data.img) > tol);
        size_xyz = size(tpl_data.img);
        fprintf('\n\tNo mask will be applied for ROI masks.\n\n');
    end
    
    [rois_inds, rois_str, rois_tag] = brant_get_rois({tpl_fn}, size_xyz, tpl_info, v_opt);
    
    % index number in rois_inds_new is the index of roi-voxel in mask_ind array
    mask_good_binary = zeros(size_xyz);
    mask_good_binary(xyz_ind) = 1:numel(xyz_ind);
    mask_good_binary_nzero = mask_good_binary ~= 0;
    rois_inds_new = cellfun(@(x) mask_good_binary(x & mask_good_binary_nzero), rois_inds, 'UniformOutput', false);
    
    num_vox_raw = cellfun(@(x) sum(x(:)), rois_inds);
    num_vox = cellfun(@numel, rois_inds_new);
    
    if v_opt == 1
        diary(fullfile(outdir, 'roi_history.txt'));
        diff_ind = find(num_vox_raw ~= num_vox);
        if any(diff_ind)
            fprintf('\n');
            arrayfun(@(x, y, z) fprintf('\tThe changed roi size (masked) marked as %s is %d (raw %d)\n', x{1}, y, z), rois_str(diff_ind), num_vox(diff_ind), num_vox_raw(diff_ind));
        end
    end
    
    % delete bad rois
    if cs_thr > 0
        bad_roi_ind = num_vox < cs_thr;
    else
        bad_roi_ind = num_vox == 0;
    end
        
    if v_opt == 1
        fprintf('\n\tROI size smaller than %d will be excluded!\n', cs_thr);
        arrayfun(@(x, y, z, k) fprintf('\tThe excluded roi''s (tag:%d, %s) voxelsize is %d (raw %d)\n', x, y{1}, z, k), rois_tag(bad_roi_ind), rois_str(bad_roi_ind), num_vox(bad_roi_ind), num_vox_raw(bad_roi_ind));
    end

    num_vox = num_vox(~bad_roi_ind);
    rois_str = rois_str(~bad_roi_ind);
    rois_tag = rois_tag(~bad_roi_ind);
    rois_inds_new = rois_inds_new(~bad_roi_ind);
    
    if v_opt == 1
        diary('off');
    end
    
    % output coordinates of ROIs
    XYZ = brant_get_XYZ(xyz_hdr);
    XYZ_mask = XYZ(xyz_ind, :);
    mask_coord = cellfun(@(x) mean(XYZ_mask(x(:), :), 1), rois_inds_new, 'UniformOutput', false);
    mask_coord_cell = num2cell(cat(1, mask_coord{:}));
    A = cat(1, {'x', 'y', 'z', 'label', 'vox_num', 'index'}, cat(2, mask_coord_cell, rois_str, num2cell([num_vox, double(rois_tag)])));
    brant_write_csv(fullfile(outdir, 'brant_roi_info.csv'), A);
    
    % output roi info
    roi_info.rois_str = rois_str;
    roi_info.rois_tag = rois_tag;
    roi_info.rois_inds_new = rois_inds_new;
end

if v_opt == 0
    fprintf('\tFinished!\n');
end