function brant_roi_mapping(jobman, h_con)

template_file = jobman.rois{1};

disp_legend = jobman.disp_legend;

roi_info_fn = jobman.roi_info{1};
disp_surface_ind = jobman.disp_surface;
surface_file = jobman.surface{1};
draw_param.alpha = jobman.alpha;

draw_param.material_type = jobman.material_type;
draw_param.lighting_type = jobman.lighting_type;
% draw_param.shading_type = jobman.shading_type;

roi_vec = jobman.roi_vec;
mode_display = jobman.mode_display;

rand_color_ind = jobman.random;
input_color_ind = jobman.input;
color_input_file = jobman.color_input{1};

if (input_color_ind == 1)
    if isempty(color_input_file)
        error('A *.txt file of color indices is expected!');
    else
        color_input = load(color_input_file);
        assert(size(color_input, 2) >= 4);
        roi_ind = color_input(:, 1);
        rgb_color = color_input(:, 2:4);
    end
end

output_color = jobman.output_color;
outdir = jobman.out_dir{1};

N_nbr = 2;
[xx,yy,zz] = ndgrid(-1 * N_nbr:N_nbr);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= N_nbr;

h_fig = brant_create_disp_fig(h_con, 'ROI Mapping: Draw');

if (disp_surface_ind == 1)
    brant_draw_surface(surface_file, mode_display, draw_param, []);
end

if isempty(template_file)
    return;
end

roi_show_msg = 0;
[rois_inds, rois_str, roi_tags, roi_hdr] = brant_get_rois({template_file}, [], roi_info_fn, roi_show_msg);
temp_org = -1 .* abs([roi_hdr.hist.srow_x(4), roi_hdr.hist.srow_y(4), roi_hdr.hist.srow_z(4)]); % RAS
pixdim = roi_hdr.dime.pixdim(2:4);

if isempty(roi_vec)
    % empty then draw all ROIs
    roi_vec = roi_tags;
end

roi_uniq_vals = setdiff(roi_vec, roi_tags);
if ~isempty(roi_uniq_vals)
    roi_vec = intersect(roi_vec, roi_tags);
    warning(strcat(sprintf('Listed value are not found in template file:'), sprintf('\n%d', roi_uniq_vals(:))));
end

if ~isempty(roi_vec)
    num_roi_show = numel(roi_vec);
    if (rand_color_ind == 1)
        color_tmp = rand(num_roi_show, 3);
    elseif (input_color_ind == 1)
        try
            roi_vec_in_color = arrayfun(@(x) find(x == roi_ind), roi_vec);
        catch
            error('Colors found in color index file are incomplete!');
        end
        color_tmp = rgb_color(roi_vec_in_color, :);
    end
    h_roi = zeros(num_roi_show, 1);
    roi_vec_ind = arrayfun(@(x) find(x == roi_tags), roi_vec);
    for m = 1:num_roi_show
        mask_tmp = smooth3(rois_inds{roi_vec_ind(m)});
        try
            h_roi(m) = draw_vol(mask_tmp, nhood, pixdim, temp_org, color_tmp(m, :), mode_display);
        catch
            error_str = sprintf(['----------------------------------------------------------------------\n',...
                                'ROI labeled with number %d is too small, surface cannot be created!\n',...
                                '----------------------------------------------------------------------\n'], m);
            error(error_str)
        end
    end

    if (disp_legend == 1)
        h_legend = legend(h_roi, rois_str(roi_vec_ind), 'Location', 'SouthEastOutside', 'Interpreter', 'none');
        pos = get(h_legend, 'Position');
        if strcmpi(mode_display, 'halves:left and right') == 1
            set(h_legend, 'Position', [0.45, 0.05, 0.1, pos(4)],...
                          'Box', 'off');
        else
            set(h_legend, 'Position', [0.85, 0.05, 0.1, pos(4)],...
                          'Box', 'off');
        end
    end

    if (output_color == 1)
        A = [roi_vec', color_tmp];
        dlmwrite(fullfile(outdir, 'brant_random_color.txt'), A);
    end
end

if (disp_surface_ind == 0)
    if (strcmpi(mode_display, 'halves:left and right') == 0)
        
        view_angle = brant_get_view_angle(mode_display);
        set_axes(gca, [], '', view_angle, draw_param);
        set(gca, 'XLim', [-70, 70],...
                 'YLim', [-100, 100],...
                 'ZLim', [-75, 75]);
    else
        sub_view_angle = [-90, 90, 60, -60];
        sub_tags = {'upper_l', 'upper_r', 'lower_l', 'lower_r'};
        sub_pos = [0, 0.5, 0.5, 0.46;...
                   0.5, 0.5, 0.5, 0.46;...
                   0, 0.02, 0.5, 0.46;...
                   0.5, 0.02, 0.5, 0.46];

        for m = 1:4
            h_sub = subplot(2, 2, m, 'Parent', gcf);
            set_axes(h_sub, sub_pos(m, :), sub_tags{m}, [sub_view_angle(m), 0], draw_param);
            set(h_sub, 'XLim', [-70, 70],...
                       'YLim', [-100, 100],...
                       'ZLim', [-75, 75]);
        end
    end
end

function set_axes(h_axes, pos, tag, angle, draw_param)

if ~isempty(pos)
    set(h_axes, 'Position', pos);
end

set(h_axes, 'Tag', tag);

axis('vis3d', 'tight', 'off');
daspect([1 1 1]);

view(angle);
h_light = camlight('right');
set(h_light, 'Position', campos, 'Tag', tag);

material(draw_param.material_type);
lighting(draw_param.lighting_type);
% shading(draw_param.shading_type);
            

function h_brain = draw_vol(mask_tmp, nhood, pixdim, temp_org, color_tmp, mode_display)

V_ero = imerode(mask_tmp, nhood);
V_edge = mask_tmp - V_ero;
[faces, vertices_coord] = isosurface(V_edge, .2);

if isempty(vertices_coord)
    [faces, vertices_coord] = isosurface(V_edge, .1);
end

vertices_coord = vertices_coord - 1;
scale_param = [1, 1, 1]; % y, x, z scale
vertices_coord = vertices_coord(:, [2, 1, 3]);
vertices_coord(:,1) = (vertices_coord(:,1) * pixdim(1) + temp_org(1)) * scale_param(1);
vertices_coord(:,2) = (vertices_coord(:,2) * pixdim(2) + temp_org(2)) * scale_param(2);
vertices_coord(:,3) = (vertices_coord(:,3) * pixdim(3) + temp_org(3))* scale_param(3);

if ~isempty(color_tmp)
    draw_args = {'FaceColor', color_tmp, 'EdgeColor', 'none'};
else
    draw_args = {'EdgeColor', 'none'};
end

if (strcmpi(mode_display, 'halves:left and right') == 0)
    center_shift = get(gca, 'Userdata');
    if isempty(center_shift)
        center_shift = [0, -23.9696, 8.6108]; % by default
    end
    vertices_coord_shift = bsxfun(@minus, vertices_coord, center_shift);
    hold('on');
    h_brain = patch('Faces', faces, 'Vertices', vertices_coord_shift, draw_args{:});
    set(gca, 'XLim', [-80, 80],...
             'YLim', [-100, 100],...
             'ZLim', [-75, 75]);
    hold('off');
else
    sub_tags = {'upper_l', 'upper_r', 'lower_l', 'lower_r'};
    for m = 1:4
        h_sub = findobj(gcf, 'type', 'axes', 'Tag', sub_tags{m});
        if isempty(h_sub)
            h_sub = subplot(2, 2, m, 'Parent', gcf);
        end
        set(gcf, 'CurrentAxes', h_sub);
        center_shift = get(gca, 'Userdata');
        if isempty(center_shift)
            center_shift = [0, -23.9696, 8.6108]; % by default
        end
        vertices_coord_shift = bsxfun(@minus, vertices_coord, center_shift);
        hold('on');
        h_brain = patch('Faces', faces, 'Vertices', vertices_coord_shift, draw_args{:});
        set(gca, 'XLim', [-80, 80],...
                 'YLim', [-100, 100],...
                 'ZLim', [-75, 75]);
        hold('off')
    end
end