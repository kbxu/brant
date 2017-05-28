function brant_draw_rois(jobman)
% draw roi in standard space

aio_ind = jobman.aio;
mask_nii = load_nii_mod(jobman.mask{1}, 1);
[mask_XYZ, s_mat] = brant_get_XYZ(mask_nii.hdr); %#ok<ASGLU>
clear('mask_XYZ');
% mask_ind_all = mask_nii.img > 0.5;
mask_ind_all = mask_nii.img ~= 0;
mask_hdr = mask_nii.hdr;
size_mask = mask_hdr.dime.dim(2:4);
dim_mask = mask_hdr.dime.pixdim(2:4);

% mask_vox_size = abs(diag(V.mat));
mask_vox_size_diff = dim_mask(1:3) - dim_mask(1);
if any(mask_vox_size_diff > 0.001)
    error('Reference mask should be in a standard space where voxel size of x,y,z should be equal!');
end
mask_roi_ind = jobman.mask_roi;

if (jobman.cube == 1)
    radius_type = 'cube';
    sphere_ind = 0;
%     cube_ind = 1;
else
    radius_type = 'sphere';
    sphere_ind = 1;
%     cube_ind = 0;
end

if (jobman.voxel == 1)
    radius_mm = jobman.radius * dim_mask(1);
elseif (jobman.mm == 1)
    radius_mm = jobman.radius;
end

if (aio_ind == 0)
    outdir = fullfile(jobman.out_dir{1}, sprintf('ROIs_radius_%03d_mm_%s', radius_mm, radius_type));
else
    outdir = jobman.out_dir{1};
end

if (exist(outdir, 'dir') ~= 7)
    mkdir(outdir);
end

if (jobman.manual == 1)
    coords = jobman.coords;
    
    if (size(coords, 2) ~= 3)
        error('Input coordinates must have 3 columns!');
    end
    
    roi_nms_tmp = 1:size(coords, 1);
    roi_strs = arrayfun(@(x) num2str(x, 'ROI_%03d'), roi_nms_tmp', 'UniformOutput', false);
else
    if isempty(jobman.coords_file)
        error('An csv file is expected for the input!');
    end
    
    fprintf('\tParsing roi information from %s.\n', jobman.coords_file{1});
    node_info = brant_parse_node(jobman.coords_file{1});
    coords = [node_info.x, node_info.y, node_info.z];
    if ~all(arrayfun(@isnumeric, coords(:)))
        error('Numeric values are expected for x, y, z of coordinates!');
    end

    if isfield(node_info, 'label')
        roi_strs = node_info.label;
        uniq_str = unique(roi_strs);
        if numel(uniq_str) ~= numel(roi_strs)
            uniq_num = cellfun(@(x) numel(find(strcmpi(x, roi_strs))), uniq_str);
            error(['ROI labels are duplicated, please check!', sprintf('\n'), sprintf('%s\n', uniq_str{uniq_num > 1})]);
        end
    else
        roi_strs = arrayfun(@(x) num2str(x, 'ROI_%03d'), 1:size(coords, 1), 'UniformOutput', false)';
    end
end

s_mat = double(s_mat);
v_res = reshape(diag(s_mat(1:3, 1:3)), 1, 3);

num_coords = size(coords, 1);
temp_nii_aio = zeros(size_mask, 'double'); % all in one
roi_overlap = 0;


coords_bound_l = reshape(s_mat(1:3, 4), 1, 3);
coords_bound_u = coords_bound_l + v_res .* (size_mask - 1);

% get bounds for input coordinates, and enlarge the bounds before compute.
coords_low = bsxfun(@minus, coords, radius_mm + v_res);
coords_upper = bsxfun(@plus, coords, radius_mm + v_res);

% remove voxels outside bounding box
coords_bound_l_mul = repmat(coords_bound_l, num_coords, 1);
coords_low_bad = coords_low < coords_bound_l_mul;
if any(coords_low_bad(:))
    coords_low(coords_low_bad) = coords_bound_l_mul(coords_low_bad);
end

coords_bound_r_mul = repmat(coords_bound_u, num_coords, 1);
coords_upper_bad = coords_upper > coords_bound_r_mul;
if any(coords_upper_bad(:))
    coords_upper(coords_upper_bad) = coords_bound_r_mul(coords_upper_bad);
end

vox_ind_l = brant_mni2vox(coords_low, coords_bound_l, v_res);
vox_ind_u = brant_mni2vox(coords_upper, coords_bound_l, v_res);

for m = 1:num_coords
    fprintf('\tDrawing ROI %s of tag %d as %s with radius %.1f mm\n', roi_strs{m}, m, radius_type, radius_mm);
    
    [vox_x, vox_y, vox_z] = meshgrid(vox_ind_l(m, 1):vox_ind_u(m, 1),...
                                     vox_ind_l(m, 2):vox_ind_u(m, 2),...
                                     vox_ind_l(m, 3):vox_ind_u(m, 3));
    vox_inds_tmp = [vox_x(:), vox_y(:), vox_z(:)];
        
    temp_img = false(size_mask);
    coords_ind = brant_vox2mni(vox_inds_tmp, coords_bound_l, v_res);
    
    if (sphere_ind == 1)
        dist_ind = pdist2(coords(m, :), coords_ind) <= radius_mm;
        vox_inds_good = vox_inds_tmp(dist_ind, :);
    else
        cube_dist = abs(bsxfun(@minus, coords_ind, coords(m, :)));
        cube_dist_ind = sum(cube_dist <= radius_mm, 2) == 3;
        vox_inds_good = vox_inds_tmp(cube_dist_ind, :);
    end
    
    abs_ind = sub2ind(size_mask, vox_inds_good(:, 1),...
                                 vox_inds_good(:, 2),...
                                 vox_inds_good(:, 3));

    temp_img(abs_ind) = true;
        
    if (mask_roi_ind == 1)
        temp_img(~mask_ind_all) = false;
    end
    
    if ~any(temp_img(:))
        fid = fopen(fullfile(outdir, 'empty_rois.txt'), 'at');
        fprintf(fid, 'ROI_%03d %.1f,%.1f,%.1f was not drawn (0 voxels).\n', m, coords(m, :));
        fclose(fid);
        continue;
    end
    
    if (roi_overlap == 0)
        if any(temp_nii_aio(temp_img))
            roi_overlap = 1;
        end
    end
    temp_nii_aio(temp_img > 0.5) = m;

    if (aio_ind == 0)
        filename = fullfile(outdir, [roi_strs{m}, '.nii']);
        nii = make_nii(double(temp_img), mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
        save_nii(nii, filename);
    end
end

if (roi_overlap == 1)
    warning(sprintf('\n\tROI overlaped!\n\tPlease check the radius and coordinates!')); %#ok<SPWRN>
end

brant_write_csv(fullfile(outdir, sprintf('roi_info_%s_%d_rois.csv', radius_type, num_coords)), [num2cell(1:num_coords)', roi_strs]);

filename = fullfile(outdir, sprintf('brant_%d_%s_rois.nii', num_coords, radius_type));
nii = make_nii(temp_nii_aio, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
save_nii(nii, filename);

fprintf('\n\tFinished!\n');

function coords_ind = brant_vox2mni(vox_ind, coord_bound_l, v_res)
% coord_bound_l: the coordinate of the first voxel in the lower coner
% v_res: voxel resolution
% vox_ind: voxel index

coords_shift = bsxfun(@times, (vox_ind - 1), v_res);
coords_ind = bsxfun(@plus, coords_shift, coord_bound_l);


function vox_ind = brant_mni2vox(coords, coord_bound_l, v_res)
% coord_bound_l: the coordinate of the first voxel in the lower coner
% v_res: voxel resolution
% coords: input coordinates

vox_shift = bsxfun(@minus, coords, coord_bound_l);
vox_ind = ceil(bsxfun(@rdivide, vox_shift, v_res) + 1);