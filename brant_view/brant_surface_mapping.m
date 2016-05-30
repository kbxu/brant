function brant_surface_mapping(jobman, h_con)

if isempty(jobman.vol_map{1})
    error('A volume of nifti format is expected!');
else
    vol_file = jobman.vol_map{1};
end

mode_disp = jobman.mode_display;

surface_file = jobman.surface{1};
draw_param.material_type = jobman.material_type;
draw_param.lighting_type = jobman.lighting_type;
draw_param.shading_type = jobman.shading_type;
draw_param.colormap_type_pos = jobman.color_type_pos;
draw_param.colormap_type_neg = jobman.color_type_neg;
draw_param.alpha_num = jobman.alpha;
% draw_param.smooth = jobman.smooth;
draw_param.discrete = jobman.discrete;
draw_param.zero_color = jobman.zero_color;
vol_exp = jobman.vol_thr;

assert(numel(draw_param.zero_color) == 3);

% vol_thr = jobman.vol_thr;

draw_param.colorbar_ind = jobman.colorbar;

% spin_angle = '';
% spin_angle = jobman.spin_angle;
% outdir = jobman.out_dir{1};

[vertices_coord, faces] = load_surface_new(surface_file);
disp_type = strsplit(mode_disp, ':');
% split faces
if strcmpi(disp_type{1}, 'whole brain') ~= 1
    vert_left_ind = vertices_coord(:, 1) < 0;
    vert_left = vertices_coord(vert_left_ind, :);
    
    vert_right_ind = ~vert_left_ind;
    vert_right = vertices_coord(vert_right_ind, :);
    
    faces_tmp = faces;
    faces_tmp(faces_tmp > find(vert_left_ind, 1, 'last' )) = NaN;
    faces_left_ind = ~isnan(sum(faces_tmp, 2));
    faces_left = faces(faces_left_ind, :);
%     faces_right = faces(~faces_left_ind, :);
    
    faces_tmp = faces;
    faces_tmp(faces_tmp < find(vert_right_ind, 1, 'first' )) = NaN;
    faces_right_ind = ~isnan(sum(faces_tmp, 2));
    faces_right = faces(~faces_right_ind, :);
end

if ~isempty(vol_file)
    mask_nii = load_nii(vol_file);
    s_mat = [mask_nii.hdr.hist.srow_x; mask_nii.hdr.hist.srow_y; mask_nii.hdr.hist.srow_z];
    if s_mat(1, 1) < 0
        s_mat(1, :) = s_mat(1, :) * -1;
    end

    vol_3d = mask_nii.img;
    
    if ~isempty(vol_exp)
        thres_str = strrep(vol_exp, 'vol', 'vol_3d');
        vol_3d_mask = eval(thres_str);
        vol_3d(~vol_3d_mask) = NaN;
    end
    
    good_vol = isfinite(vol_3d) & vol_3d ~= 0;
    min_vol = min(vol_3d(good_vol));
    max_vol = max(vol_3d(good_vol));
else
    min_vol = [];
    max_vol = [];
    s_mat = [];
    vol_3d = [];
end

% uni_name_tag = ['Surface Mapping:console_handle:', num2str(h_con)];
uni_name_tag = 'Surface Mapping: Draw';
h_fig = findobj(0, 'Name', uni_name_tag);
if ~isempty(h_fig)
    h_axes = findobj(h_fig, 'Type', 'axes');
    
    if ~isempty(h_axes)
        delete(h_axes);
    end
    set(0, 'CurrentFigure', h_fig);
    figure(h_fig);
else
    h_fig = figure('Name', uni_name_tag, 'Position', [200, 200, 800, 600]);
end

if ~isempty(h_con)
    set(h_con, 'DeleteFcn', {@close_win, h_fig});
    h_cancel = findobj(h_con, 'Style', 'pushbutton', 'String', 'cancel');
    set(h_cancel, 'ButtonDownFcn', {@cancel_fun, h_fig});
end

set(h_fig, 'WindowButtonUpFcn', {@clickfn, h_fig}, 'Color', [1 1 1], 'InvertHardcopy', 'off');

switch(disp_type{2})
    case 'left and right'
        
%         spin_angle = [];
        
        hold('on');
        h = subplot(2, 2, 1);
        draw_brain(h_fig, thres_str, faces_left, vert_left, s_mat, vol_3d, draw_param, 'left_above', [-90, 0])
        set(h, 'Unit', 'pixel', 'Pos', [130, 300, 300, 250]);
        set(h, 'Unit', 'normalised');
        
        h = subplot(2, 2, 2);
        draw_brain(h_fig, thres_str, faces_right, vert_right, s_mat, vol_3d, draw_param, 'right_above', [90, 0])
        set(h, 'Unit', 'pixel', 'Pos', [380, 300, 300, 250]);
        set(h, 'Unit', 'normalised');
        
        h = subplot(2, 2, 3);
        draw_brain(h_fig, thres_str, faces_left, vert_left, s_mat, vol_3d, draw_param, 'left_below', [90, 0])
        set(h, 'Unit', 'pixel', 'Pos', [130, 80, 300, 250]);
        set(h, 'Unit', 'normalised');
        
        h = subplot(2, 2, 4);
        draw_brain(h_fig, thres_str, faces_right, vert_right, s_mat, vol_3d, draw_param, 'right_below', [-90, 0])
        set(h, 'Unit', 'pixel', 'Pos', [380, 80, 300, 250]);
        set(h, 'Unit', 'normalised');
        
        hold('off');
        
    case 'left medial'
        draw_brain(h_fig, thres_str, faces_left, vert_left, s_mat, vol_3d, draw_param, disp_type{2}, [90, 0]);
    case 'left lateral'
        draw_brain(h_fig, thres_str, faces_left, vert_left, s_mat, vol_3d, draw_param, disp_type{2}, [-90, 0]);
    case 'right medial'
        draw_brain(h_fig, thres_str, faces_right, vert_right, s_mat, vol_3d, draw_param, disp_type{2}, [-90, 0]);
    case 'right lateral'
        draw_brain(h_fig, thres_str, faces_right, vert_right, s_mat, vol_3d, draw_param, disp_type{2}, [90, 0]);
    case 'sagital left'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [-90, 0]);
    case 'sagital right'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [90, 0]);
    case 'axial up'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [0, 90]);
    case 'axial down'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [180, -90]);
    case 'coronal anterior'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [180, 0]);
    case 'coronal posterior'
        draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, vol_3d, draw_param, disp_type{2}, [0, 0]);
end

% if colorbar_ind == 1
%     
%     set(h_fig, 'Unit', 'pixel', 'PaperPositionMode', 'auto');
%     set(0, 'CurrentFigure', h_fig);
% 
%     cbar_h = colorbar('Location', 'SouthOutside');
%     set(cbar_h, 'Position', [0.35, 0.07, 0.3, 0.025]);
% 
%     color_bar_limits = get(cbar_h, 'XTick');
%     min_vol_str = num2str(fix(double(min(min_vol, 0)) * 100) / 100);
%     max_vol_str = num2str(fix(double(max_vol) * 100) / 100);
%     set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), color_bar_limits(end)]);
%     
% %     min_abs = min(abs([min_vol, max_vol]));
% %     max_abs = max(abs([min_vol, max_vol]));
% % 
% %     min_pc = single(min_abs) / single(max_abs);
% 
% %     if draw_param.discrete == 1
% %         set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), color_bar_limits(end)]);
% %     else
% %         len_cbr = get(cbar_h, 'TickLength');
% %         if min_vol < 0 && max_vol > 0
% %             if min_pc > len_cbr && min_pc < (1 - len_cbr)
% %                 set(cbar_h, 'XTickLabel', {min_vol_str; '0'; max_vol_str}, 'XTick', [color_bar_limits(1), single(min_vol) / single(max_vol + min_vol), color_bar_limits(2)])
% %             else
% %                 set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), color_bar_limits(2)])
% %             end
% %         elseif min_vol > 0
% %             if min_pc > len_cbr && min_pc < (1 - len_cbr)
% %                 set(cbar_h, 'XTickLabel', {'0'; min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), single(min_vol) / single(max_vol), color_bar_limits(2)])
% %             else
% %                 set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [single(min_vol) / single(max_vol), color_bar_limits(2)])
% %             end
% %         elseif max_vol < 0
% %             if min_pc > len_cbr && min_pc < (1 - len_cbr)
% %                 set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str; '0'}, 'XTick', [color_bar_limits(1), abs(single(max_vol) / single(min_vol)), color_bar_limits(2)])
% %             else
% %                 set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), abs(single(max_vol) / single(min_vol))])
% %             end
% %         elseif min_vol == 0 || max_vol == 0
% %             set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), color_bar_limits(2)]);
% %         end
% % 
% %     end
% end

function draw_brain(h_fig, thres_str, faces, vertices_coord, s_mat, volume_3d, draw_param, light_tag, view_angle)

if ~isempty(s_mat)
    
    volume_3d(~isfinite(volume_3d)) = 0;
  
    num_coords = size(vertices_coord, 1);
    trans_mat = s_mat;
    trans_mat(:, 4) = s_mat(:, 4) - diag(s_mat);
    vox_ind_tmp = [trans_mat; 0, 0, 0, 1] \ [vertices_coord, ones(num_coords, 1)]';

    % find out vertices from surface exeeding bounding box of the current
    % volume
    size_vol = size(volume_3d);
    
    vox_ind = int16(vox_ind_tmp(1:3, :))';
    bad_ind = false;
    for m = 1:3
        bad_ind = bad_ind | (vox_ind(:, m) < 1 | vox_ind(:, m) > size_vol(m));
    end
    if any(bad_ind)
        vox_ind_tmp2 = vox_ind(~bad_ind, 1:3);
        color_tmp_1 = arrayfun(@(x) volume_3d(vox_ind_tmp2(x, 1), vox_ind_tmp2(x, 2), vox_ind_tmp2(x, 3)), 1:size(vox_ind_tmp2, 1));
        color_tmp = zeros(size(vox_ind, 1), 1);
        color_tmp(~bad_ind) = color_tmp_1;
    else
        color_tmp = arrayfun(@(x) volume_3d(vox_ind(x, 1), vox_ind(x, 2), vox_ind(x, 3)), 1:size(vox_ind, 1));
    end
    
    
    uniq_vol = setdiff(unique(volume_3d(:)), 0);
    num_color_vert = numel(uniq_vol);
    color_N = min(128, num_color_vert);
    
    if num_color_vert == 0
        warning('No voxel survived the threshold!');
        return;
    end
    
    color_fun_pos = str2func(draw_param.colormap_type_pos);
    color_fun_neg = str2func(draw_param.colormap_type_neg);
    
    vert_color = zeros(size(vertices_coord, 1), 3);
    vert_color(:, 1) = draw_param.zero_color(1);
    vert_color(:, 2) = draw_param.zero_color(2);
    vert_color(:, 3) = draw_param.zero_color(3);
    
    if color_N == 1 || draw_param.discrete == 1
        
        % discrete values
        color_N = num_color_vert;
        color_map_new = lines(color_N);
        for n = 1:num_color_vert
            color_ind = color_tmp == uniq_vol(n);
            vert_color(color_ind, 1) = color_map_new(n, 1);
            vert_color(color_ind, 2) = color_map_new(n, 2);
            vert_color(color_ind, 3) = color_map_new(n, 3);
        end
    else
        % continuous values
        c_map_pos = color_fun_pos(color_N);
        c_map_neg = color_fun_neg(color_N);
        max_abs = max(abs(uniq_vol));
        norm_int = ceil(abs(color_tmp) / max_abs * color_N);
        
        color_pos = color_tmp > 0;
        color_neg = color_tmp < 0;
        
        vert_color(color_pos, :) = c_map_pos(norm_int(color_pos), :);
        vert_color(color_neg, :) = c_map_neg(norm_int(color_neg), :);
        
        warning('off', 'MATLAB:colon:operandsNotRealScalar');
        min_norm_neg = min(norm_int(color_neg));
        max_norm_neg = max(norm_int(color_neg));
        min_norm_pos = min(norm_int(color_pos));
        max_norm_pos = max(norm_int(color_pos));
        zero_ind = any(color_tmp == 0);
        if zero_ind == 1
            color_map_new = [c_map_neg(1:max(norm_int(color_neg)), :); draw_param.zero_color; c_map_pos(1:max(norm_int(color_pos)), :)];
        else
            color_map_new = [c_map_neg(1:max(norm_int(color_neg)), :); c_map_pos(1:max(norm_int(color_pos)), :)];
        end
        
        len_colormap = size(color_map_new, 1);
        min_norm_neg_abs = min_norm_neg;
        max_norm_neg_abs = max_norm_neg;
        min_norm_pos_abs = numel(max_norm_neg) + min_norm_pos + zero_ind;
        max_norm_pos_abs = numel(max_norm_neg) + max_norm_pos + zero_ind;
    end
    colormap(color_map_new);
    
    brain = patch('Faces', faces, 'Vertices', vertices_coord, 'FaceVertexCData', vert_color);
else
    brain = patch('Faces', faces, 'Vertices', vertices_coord, 'Edgecolor', 'none');
end

material(draw_param.material_type);
shading(draw_param.shading_type);
if isempty(s_mat)
    set(brain, 'FaceColor', [0.95, 0.9, 0.9]);
end
set(brain, 'FaceAlpha', draw_param.alpha_num); 
lighting(draw_param.lighting_type);
daspect([1 1 1]);
axis('vis3d');
axis('off');
set(gca, 'Tag', light_tag);
view(view_angle);

h_light = camlight('right');
set(h_light, 'Position', campos, 'Tag', light_tag);

if draw_param.colorbar_ind == 1
    set(h_fig, 'Unit', 'pixel', 'PaperPositionMode', 'auto');
    set(0, 'CurrentFigure', h_fig);

    cbar_h = colorbar('Location', 'SouthOutside');
    set(cbar_h, 'Position', [0.35, 0.07, 0.3, 0.03], 'FontSize', 14);

    color_bar_limits = get(cbar_h, 'XTick');
    color_bar_len = color_bar_limits(end) - color_bar_limits(1);
    
    min_vol_str = num2str(fix(double(min(uniq_vol)) * 100) / 100);
    max_vol_str = num2str(fix(double(max(uniq_vol)) * 100) / 100);
    
    if color_N == 1 || draw_param.discrete == 1 || (max(uniq_vol) > 0 && min(uniq_vol) < 0)
        set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), color_bar_limits(end)]);
    elseif max(uniq_vol) < 0
        set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [color_bar_limits(1), (max_norm_neg_abs / len_colormap) * color_bar_len + color_bar_limits(1)]);
    elseif min(uniq_vol) > 0
        set(cbar_h, 'XTickLabel', {min_vol_str; max_vol_str}, 'XTick', [(min_norm_pos_abs / len_colormap) * color_bar_len + color_bar_limits(1), color_bar_limits(end)]);
    end
end


function clickfn(obj, evd, h_fig) %#ok<*INUSL>

sub_pos = get(gca, 'Tag');
h_light = findobj(h_fig, 'Type', 'light', 'Tag', sub_pos);
set(h_light, 'Position', campos);

function close_win(obj, evd, h_disp)
try %#ok<*TRYNC>
    delete(h_disp);
end

function cancel_fun(obj, evd, h_disp)
h_con = get(obj, 'Parent');
delete(h_con);
try
    delete(h_disp);
end
