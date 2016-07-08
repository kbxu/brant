function brant_roi_mapping(jobman, h_con)

if isempty(jobman.rois)
    error('An ROI file is expected!')
else
    template_file = jobman.rois{1};
end

disp_legend = jobman.disp_legend;

roi_info_fn = jobman.roi_info{1};
disp_surface_ind = jobman.disp_surface;
surface_file = jobman.surface{1};
alpha_num = jobman.alpha;
% spin_angle = jobman.spin_angle;

roi_vec = jobman.roi_vec;
mode_display = jobman.mode_display;

rand_color_ind = jobman.random;
input_color_ind = jobman.input;
color_input_file = jobman.color_input{1};

if input_color_ind == 1
    if isempty(color_input_file)
        error('A *.txt file of color indices is expected!');
    else
        color_input = load(color_input_file);
        assert(size(color_input) >= 4);
        roi_ind = color_input(:, 1);
        rgb_color = color_input(:, 2:4);
    end
end

output_color = jobman.output_color;
outdir = jobman.out_dir{1};

N_nbr = 2;
[xx,yy,zz] = ndgrid(-1 * N_nbr:N_nbr);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= N_nbr;

uni_name_tag = 'ROI Mapping: Draw';
% uni_name_tag = ['ROI Mapping:console_handle:', num2str(h_con)];
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

set(h_fig, 'WindowButtonUpFcn', {@clickfn, h_fig});

% disp_surface_ind = 1;
if disp_surface_ind == 1
    [vertices_coord_org, faces] = load_surface_new(surface_file);
    h_brain = patch('Faces', faces, 'Vertices', vertices_coord_org, 'EdgeColor', 'none');
    material('shiny');
    shading('interp');
    set(h_brain, 'FaceColor', [0.95, 0.9, 0.9]);
    set(h_brain, 'FaceAlpha', alpha_num); 
    lighting('gouraud');
end
hold('on');

roi_show_msg = 0;
[rois_inds, rois_str, roi_tags, roi_hdr] = brant_get_rois({template_file}, [], roi_info_fn, roi_show_msg);
temp_org = [-1 * abs(roi_hdr.hist.srow_x(4)), -1 * abs(roi_hdr.hist.srow_y(4)), -1 * abs(roi_hdr.hist.srow_z(4))]; % RPI
pixdim = roi_hdr.dime.pixdim(2:4);

roi_uniq_vals = setdiff(roi_vec, roi_tags);
if ~isempty(roi_uniq_vals)
    roi_vec = intersect(roi_vec, roi_tags);
    warning(strcat(sprintf('Listed value are not found in template file:'), sprintf('\n%d', roi_uniq_vals(:))));
end

if ~isempty(roi_vec)
    num_roi_show = numel(roi_vec);
    if rand_color_ind == 1
        color_tmp = rand(num_roi_show, 3);
    elseif input_color_ind == 1
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
        h_roi(m) = draw_vol(mask_tmp, nhood, pixdim, temp_org, color_tmp(m, :));
    end

    if disp_legend == 1
        h_legend = legend(h_roi, rois_str(roi_vec_ind), 'Location', 'SouthEastOutside', 'Interpreter', 'none');
        set(h_legend, 'Box', 'off')
    end

    if output_color == 1
        A = [roi_vec', color_tmp];
        dlmwrite(fullfile(outdir, 'brant_random_color.txt'), A);
    end
end

switch(mode_display)
    case 'sagital left'
        view([-90, 0]); 
    case 'sagital right'
        view([90, 0]); 
    case 'axial up'
        view([0, 90]); 
    case 'axial down'
        view([180, -90]); 
    case 'coronal anterior'
        view([180, 0]); 
    case 'coronal posterior'
        view([0, 0]); 
end
    
daspect([1,1,1]);
camlight('right');
h_light = findobj(h_fig, 'type', 'light');
set(h_light, 'Position', campos);
lighting('gouraud');
axis('vis3d');
axis('off');

whitebg(gcf, [1 1 1]);
set(gcf, 'Color', [1 1 1], 'InvertHardcopy', 'off');
hold('off')


% if ~isempty(spin_angle)
%     view([90, 0]);
%     set(h_light, 'Position', campos);
%     for m = 0:spin_angle:360
%         camorbit(spin_angle, 0, 'camera');
%         set(h_light, 'Position', campos);
%         saveas(h_fig, fullfile(outdir, ['brant_roi_', num2str(m), '.png']));
%     end
% end

function h_brain = draw_vol(mask_tmp, nhood, pixdim, temp_org, color_tmp)

V_ero = imerode(mask_tmp, nhood);
V_edge = mask_tmp - V_ero;
[faces, vertices_coord] = isosurface(V_edge, .2);
vertices_coord = vertices_coord - 1;

scale_param = [1, 1, 1]; % y, x, z scale
vertices_coord_org(:,2) = (vertices_coord(:,1) * pixdim(2) + temp_org(2)) * scale_param(1);
vertices_coord_org(:,1) = (vertices_coord(:,2) * pixdim(1) + temp_org(1)) * scale_param(2);
vertices_coord_org(:,3) = (vertices_coord(:,3) * pixdim(3) + temp_org(3))* scale_param(3);

if ~isempty(color_tmp)
    h_brain = patch('Faces', faces, 'Vertices', vertices_coord_org, 'FaceColor', color_tmp, 'EdgeColor', 'none');
else
    h_brain = patch('Faces', faces, 'Vertices', vertices_coord_org, 'EdgeColor', 'none');
end

function clickfn(obj, evd, h_fig) %#ok<*INUSL>
h_light = findobj(h_fig, 'type', 'light');
set(h_light, 'Position', campos);

function close_win(obj, evd, h_disp)
try
    delete(h_disp);
end

function cancel_fun(obj, evd, h_disp)
h_con = get(obj, 'Parent');
delete(h_con);
try %#ok<*TRYNC>
    delete(h_disp);
end
