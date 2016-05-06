function brant_network_visual(jobman, h_con)

% mode = 'test';
% if strcmp(mode, 'test')
surface_fn = jobman.surface{1};
surf_alhpa = jobman.alpha;

if isempty(surface_fn)
    error('Please select surface file.')
end

if ~isempty(jobman.node_txt)
    num_node = size(jobman.node.x, 1);
    node_info = jobman.node;
    
    node_info.coords = [node_info.x, node_info.y, node_info.z];
    node_info.show_label = jobman.show_label;
    if isfield(node_info, 'label')
        for m = 1:num_node
            if isnan(node_info.label{m})
                node_info.label{m} = '';
            elseif ~isempty(node_info.label{m})
                node_info.label{m} = regexprep(node_info.label{m}, '[\s\W_]+', '\\_');
            end
        end
    else
        node_info.label = cell(num_node, 1);
        
        if node_info.show_label == 1
            node_info.show_label = 0;
            warning('No input label can be found!');
        end
    end
%     node_info.label = regexprep(node_info.label, '[\s\W_]+', '\\_');

    if ~isempty(jobman.node_size)
        if jobman.node_size > 0
            node_info.size = repmat(jobman.node_size, num_node, 1);
        else
            node_info.size = repmat(3, num_node, 1);
        end
    else
        node_info.size = jobman.node.size;  % repmat(3, num_node, 1);
    end

    if jobman.user_color == 1
        node_info.color = jobman.color_nodes;
    elseif jobman.same_color == 1
        node_info.color = repmat(jobman.color_same, num_node, 1);
    else
        module_str = node_info.module;
        module_ind = cellfun(@(x) find(strcmp(jobman.all_modules, x)), module_str);

        node_info.color = jobman.color_modules(module_ind, :);
    end
    
    
%     node_pth = fileparts(jobman.node_txt{1});
%     fid = fopen(fullfile(node_pth, 'node_color.txt'), 'wt');
%     fprintf(fid, '%-8s%-8s%-8s%-8s%-8s%-8s\n', 'x', 'y', 'z', 'r', 'g', 'b');
%     for m = 1:size(node_info.color, 1)
%         fprintf(fid, '%-8.2f%-8.2f%-8.2f%-8.2f%-8.2f%-8.2f\n', node_info.x(m), node_info.y(m), node_info.z(m), node_info.color(m, :));
%     end
%     fclose(fid);
else
    num_node = [];
    node_info = [];
end

if iscell(jobman.edge)
    if isempty(jobman.edge{1})
        jobman.edge = '';
    end
end

if isempty(jobman.edge)
    edge_info.edge = [];
else
    edge_info.edge = load(jobman.edge{1});
    edge_info.thres = jobman.edge_thr;
    edge_info.thickness = jobman.thickness;
    edge_info.adjust_edge_color = jobman.adjust_edge_color;
    edge_info.pos_color = jobman.pos_color;
    edge_info.neg_color = jobman.neg_color;
    
    edge_info.hide_node = jobman.hide_node;
    edge_info.edge_disp = jobman.edge_disp;
    edge_info.wei_rad = jobman.wei_rad;
    edge_info.wei_thr = jobman.wei_thr;
end

mode_display = jobman.mode_display;

surface_brain = surface_fn;

screen_size = get(0, 'MonitorPositions');
if screen_size(1, 3) == screen_size(1, 4)
    vis_height = 0.6*screen_size(1, 4);
    vis_length = vis_height;
else
    vis_height = 0.6*screen_size(1, 4);
    vis_length = 1.4*vis_height;
end

% h_view_new = findobj(0, 'Name', 'network visualization');

if isempty(h_con)
    pos_view_new = screen_size(1, 3) / 2;
else
    pos_view_new_tmp = get(h_con, 'pos');
    pos_view_new = pos_view_new_tmp(3);
end
x = (screen_size(1, 3)-vis_length-pos_view_new)/2;
y = (screen_size(1, 4)-vis_height)/2;
% set(h_view_new, 'Position', [x+vis_length+15, y+vis_height-pos_view_new(4), pos_view_new(3:4)]);
if vis_length < 0 || vis_height < 0
    pos_vis = [0, 0, 1024, 768] * 0.7 + [20, 20, 0, 0];
else
    pos_vis = [x, y, vis_length, vis_height];
end

h_figure = findobj(0, 'Name', 'brant:network visualization', 'Tag', 'surface');
if isempty(h_figure)
    h_figure = figure(...
        'IntegerHandle',    'off',...
        'Position',         pos_vis,...
        'Color',            [1 1 1],...
        'Name',             'brant:network visualization',...
        'UserData',         '',...
        'NumberTitle',      'off',...
        'Tag',              'surface',...
        'Units',            'pixels',...
        'Resize',           'off',...
        'Visible',          'on');
    ht = findall(h_figure, 'Type', 'uitoolbar');
    [X, map] = imread(fullfile(fileparts(which('brant')), 'brant_visual', 'help_gs.png'));
    [X1, map1] = imread(fullfile(fileparts(which('brant')), 'brant_visual', 'greencircleicon.gif'));
    icon1 = ind2rgb(X1, map1);
    %%%%%
    
    hpt = uipushtool(ht, 'CData',X,...
        'TooltipString','Toolbar push button',...
        'Tag', 'btn_rotate',...
        'ClickedCallback', {@rotate_cb, 1});
    hpt1 = uipushtool(ht, 'CData',icon1,...
        'TooltipString','Toolbar push button',...
        'Tag', 'btn_stop',...
        'ClickedCallback', {@rotate_cb, 0},...
        'Userdata', 0);
    
    h_tmp_all = findall(h_figure);
    h_tmp = h_tmp_all(cell2mat(arrayfun(@(x) strcmp('uitoggletool', get(x, 'type')), h_tmp_all, 'uniformoutput', false)));
    h_rot3d = h_tmp(cell2mat(arrayfun(@(x) strcmp('Rotate 3D', get(x, 'tooltip')), h_tmp, 'uniformoutput', false)));

    set(h_rot3d, 'OffCallback', @rot_cb_off);
else
    set(0, 'Currentfig', h_figure)
    figure(h_figure)
    h_child = get(h_figure, 'Children');
    delete(h_child)
    hpt = findall(0, 'Tag', 'btn_rotate');
    hpt1 = findall(0, 'Tag', 'btn_stop');
end

set(h_con, 'DeleteFcn', {@close_win, h_figure});

% load surface
[vertices_coord, faces] = load_surface_new(surface_brain);
[vertices_left, vertices_right] = splitVertices(vertices_coord);
limit_ver = round(size(vertices_coord, 1) / 2);
limit_fac = round(size(faces, 1) / 2);
faces_left = faces(1:limit_fac, :);
faces_right = faces(limit_fac+1:end, :);
faces_right = faces_right - ones(size(faces_right)) * limit_ver;

axis('vis3d');
set(hpt, 'Enable', 'on')
set(hpt1, 'Enable', 'on')

if ~isempty(node_info)
    node_ind_left = node_info.coords(:, 1) < 0;
    node_ind_right = node_info.coords(:, 1) > 0;
else
    node_ind_left = [];
    node_ind_right = [];
end



if strcmpi(mode_display, 'halves:left and right') == 0
    mode_brain = regexpi(mode_display, ':', 'split');
    switch mode_brain{1}
        case 'halves'
            switch mode_brain{2}
                case {'left lateral', 'left medial'}
                    node_ind = node_ind_left;
                    faces_tmp = faces_left;
                    vertices_tmp = vertices_left;
                case {'right lateral', 'right medial'}
                    node_ind = node_ind_right;
                    faces_tmp = faces_right;
                    vertices_tmp = vertices_right;
            end
            switch mode_brain{2}
                case {'left lateral', 'right medial'}
                    view_angle = [-90, 0];
                case {'left medial', 'right lateral'}
                    view_angle = [90, 0];
            end
        case 'whole brain'
            node_ind = true(num_node, 1);
            vertices_tmp = vertices_coord;
            faces_tmp = faces;
            switch mode_brain{2}
                case 'sagital left'
                    view_angle = [-90, 0];
                case 'sagital right'
                    view_angle = [90, 0];
                case 'axial'
                    view_angle = [0, 90];
                case 'coronal'
                    view_angle = [180, 0];
            end
    end
    draw_brain(faces_tmp, vertices_tmp, surf_alhpa, node_info, edge_info, view_angle, node_ind)
else
    set(hpt, 'Enable', 'off')
    set(hpt1, 'Enable', 'off')
    % left hemisphere lateral surface
    h_sub1 = subplot(2, 2, 1, 'Parent', h_figure);
    sub1_pos = get(h_sub1, 'Position');
    set(h_sub1, 'Position', [sub1_pos(1)+0.03, sub1_pos(2)-0.062, sub1_pos(3), sub1_pos(4)])
    draw_brain(faces_left, vertices_left, surf_alhpa, node_info, edge_info, [-90, 0], node_ind_left)
    % right hemisphere lateral surface
    h_sub2 = subplot(2, 2, 2, 'Parent', h_figure);
    sub2_pos = get(h_sub2, 'Position');
    set(h_sub2, 'Position', [sub2_pos(1)-0.07, sub2_pos(2)-0.062, sub2_pos(3), sub2_pos(4)])
    draw_brain(faces_right, vertices_right, surf_alhpa, node_info, edge_info, [90, 0], node_ind_right);
    
    % left hemisphere medial surface
    h_sub3 = subplot(2, 2, 3, 'Parent', h_figure);
    sub3_pos = get(h_sub3, 'Position');
    set(h_sub3, 'Position', [sub3_pos(1)+0.03, sub3_pos(2)+0.062, sub3_pos(3), sub3_pos(4)])
    draw_brain(faces_left, vertices_left, surf_alhpa, node_info, edge_info, [90, 0], node_ind_left)
    
    % right hemisphere medial surface
    h_sub4 = subplot(2, 2, 4, 'Parent', h_figure);
    sub4_pos = get(h_sub4, 'Position');
    set(h_sub4, 'Position', [sub4_pos(1)-0.07, sub4_pos(2)+0.062, sub4_pos(3), sub4_pos(4)])
    draw_brain(faces_right, vertices_right, surf_alhpa, node_info, edge_info, [-90, 0], node_ind_right)
    hold on
    h_axes = axes('Position', [0.05 0.05 0.9 0.8]);

    text('Position', [0.01 0.6], 'String', 'L', 'FontSize', 24);
    text('Position', [0.95, 0.6], 'String', 'R', 'FontSize', 24);
    set(h_axes, 'Visible', 'off')
end

% [~, fn, ~] = fileparts(jobman.edge{1});
% export_fig([fn, '_brain.png'], '-nocrop', '-transparent', '-r600');
% h_fig = gcf;
% h_light = findobj(h_fig, 'type', 'light');
% set(h_light, 'Position', campos);
% material('shiny')
% lighting('gouraud')

function rot_cb_off(obj, evd) %#ok<*INUSD>

rotate3d('off');
h_light = findobj(gcf, 'type', 'light');
set(h_light, 'Position', campos);

function rotate_cb(obj, evd, state) %#ok<*INUSL>
h_fig = gcf;
h_uis = get(obj, 'Parent');
h_stop = findobj(h_uis, 'Tag', 'btn_stop');
h_light = findobj(h_fig, 'type', 'light');
axis('vis3d');

if state == 1
    set(h_stop, 'Userdata', 0)
    btn_stop = 0;
    while btn_stop == 0
        camorbit(10, 0, 'data');
        set(h_light, 'Position', campos);
        drawnow
        btn_stop = get(h_stop, 'Userdata');
    end
    set(h_stop, 'Userdata', 0);
else
    set(h_stop, 'Userdata', 1);
end

function close_win(obj, evd, h_disp)
try %#ok<*TRYNC>
    delete(h_disp);
end
