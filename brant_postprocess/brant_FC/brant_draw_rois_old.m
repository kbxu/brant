function brant_draw_rois_old(jobman)
% draw roi in standard space

aio_ind = jobman.aio;
mask_nii = load_nii(jobman.mask{1});
[mask_XYZ, s_mat] = brant_get_XYZ(mask_nii.hdr);
mask_ind_all = mask_nii.img > 0.5;
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
    cube_ind = 1;
else
    radius_type = 'sphere';
    sphere_ind = 1;
    cube_ind = 0;
end

if (jobman.voxel == 1)
    radius_vox = fix(jobman.radius);
    radius_mm = jobman.radius * dim_mask(1);
elseif (jobman.mm == 1)
    radius_mm = jobman.radius;
    radius_vox = fix(jobman.radius / dim_mask(1));
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

v_mat_shift = reshape(s_mat(1:3, 4), 1, 3);
v_mat_cen = reshape(diag(s_mat(1:3, 1:3)), 1, 3);

num_coords = size(coords, 1);

vox_ind_tmp = (coords - repmat(v_mat_shift, num_coords, 1)) ./ repmat(v_mat_cen, num_coords, 1) - 1;
vox_ind = round(vox_ind_tmp);

temp_nii_aio = zeros(size_mask, 'double'); % all in one
roi_overlap = 0;

if (cube_ind == 1)
    vox_ind_cube_low = vox_ind - radius_vox;
    vox_ind_cube_up = vox_ind + radius_vox;
    vox_ind_cube_low(vox_ind_cube_low < 1) = 1;
    vox_ind_cube_up(vox_ind_cube_up(:, 1) > size_mask(1), 1) = size_mask(1);
    vox_ind_cube_up(vox_ind_cube_up(:, 2) > size_mask(2), 2) = size_mask(2);
    vox_ind_cube_up(vox_ind_cube_up(:, 3) > size_mask(3), 3) = size_mask(3);
    
    for m = 1:num_coords
        temp_nii = false(size_mask);
        temp_nii(vox_ind_cube_low(m, 1):vox_ind_cube_up(m, 1), vox_ind_cube_low(m, 2):vox_ind_cube_up(m, 2), vox_ind_cube_low(m, 3):vox_ind_cube_up(m, 3)) = true;
        if (mask_roi_ind == 1)
            temp_nii(~mask_ind_all) = false;
        end
        
        if (roi_overlap == 0)
            if any(temp_nii_aio(temp_nii))
                roi_overlap = 1;
            end
        end
        temp_nii_aio(temp_nii > 0.5) = m;
        
        if (aio_ind == 0)
            filename = fullfile(outdir, [roi_strs{m}, '.nii']);
            nii = make_nii(double(temp_nii), mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
            save_nii(nii, filename);
        end
    end
elseif (sphere_ind == 1)
    num_mask = size(mask_XYZ, 1);
    for m = 1:num_coords
        temp_nii = false(size_mask);
        mask_shift = abs(mask_XYZ - repmat(coords(m, :), num_mask, 1));
        dist_radius = sqrt(mask_shift(:, 1) .^2 + mask_shift(:, 2) .^2 + mask_shift(:, 3) .^2);
        
        mask_dist = dist_radius <= radius_mm;
        temp_nii(mask_dist) = true;
        if (mask_roi_ind == 1)
            temp_nii(~mask_ind_all) = false;
        end
        
        if (roi_overlap == 0)
            if any(temp_nii_aio(temp_nii))
                roi_overlap = 1;
            end
        end
        temp_nii_aio(temp_nii) = m;
        
        if (aio_ind == 0)
            filename = fullfile(outdir, [roi_strs{m}, '.nii']);
            nii = make_nii(double(temp_nii), mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
            save_nii(nii, filename);
        end
    end
end

if (roi_overlap == 1)
    warning('ROI overlaped in %s.nii!', num2str(num_coords, 'rois_%d'));
end

brant_write_csv(fullfile(outdir, sprintf('roi_info_%s_%d_rois.csv', radius_type, num_coords)), [num2cell(1:num_coords)', roi_strs]);

filename = fullfile(outdir, sprintf('brant_%d_%s_rois.nii', num_coords, radius_type));
nii = make_nii(temp_nii_aio, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
save_nii(nii, filename);

% if ~isempty(roi_strs{1})
%     save(fullfile(outdir, sprintf('all_%d_rois.mat', num_coords)), 'roi_strs', 'coords', 'radius_mm', 'radius_vox');
% end
fprintf('\n\tFinished!\n');
