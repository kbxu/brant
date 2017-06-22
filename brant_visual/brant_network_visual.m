function brant_network_visual(jobman, h_con)

surface_fn = jobman.surface{1};
% surf_alpha = jobman.alpha;
draw_param.material_type = 'dull';
draw_param.lighting_type = 'gouraud';
draw_param.shading_type = 'interp';
draw_param.alpha = jobman.alpha;

if isempty(surface_fn)
    error('Please select surface file.')
end

if ~isempty(jobman.node_txt{1})
    num_node = size(jobman.node.x, 1);
    node_info = jobman.node;
    
    node_info.coords = [node_info.x, node_info.y, node_info.z];
    node_info.show_label = jobman.show_label;
    if isfield(node_info, 'label')
        for m = 1:num_node
            if isnan(node_info.label{m})
                node_info.label{m} = '';
            elseif ~isempty(node_info.label{m})
                node_info.label{m} = regexprep(node_info.label{m}, '[\s\W_]+', '\/');
            end
        end
    else
        node_info.label = cell(num_node, 1);
        
        if (node_info.show_label == 1)
            node_info.show_label = 0;
            warning('No input label can be found!');
        end
    end
%     node_info.label = regexprep(node_info.label, '[\s\W_]+', '\\_');

    if ~isempty(jobman.node_size)
        if (jobman.node_size > 0)
            node_info.size = repmat(jobman.node_size, num_node, 1);
        else
            node_info.size = repmat(3, num_node, 1);
        end
    else
        node_info.size = jobman.node.size;  % repmat(3, num_node, 1);
    end

    if (jobman.user_color == 1)
        node_info.color = jobman.color_nodes;
    elseif (jobman.same_color == 1)
        node_info.color = repmat(jobman.color_same, num_node, 1);
    else
        module_str = node_info.module;
        module_ind = cellfun(@(x) find(strcmp(jobman.all_modules, x)), module_str);

        node_info.color = jobman.color_modules(module_ind, :);
    end
else
    node_info = [];
end

if isempty(jobman.edge{1})
    edge_info.edge = [];
    edge_info.hide_node = 0;
else
    edge_info.edge = load(jobman.edge{1});
    if isequal(edge_info.edge, edge_info.edge') == 0
        error('Edge matrix is not symmetric, please check!')
    end
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

brant_create_disp_fig(h_con, 'brant:network visualization');

brant_draw_surface(surface_brain, mode_display, draw_param, []);

if ~isempty(node_info)
    if (strcmpi(mode_display, 'halves:left and right') == 0)
        center_shift = get(gca, 'Userdata');
        node_info.coords = bsxfun(@minus, node_info.coords, center_shift);
        node_info.x = node_info.x - center_shift(1);
        node_info.y = node_info.y - center_shift(2);
        node_info.z = node_info.z - center_shift(3);
        brant_draw_brain(node_info, edge_info);
        set(gca, 'XLim', [-70, 70],...
                 'YLim', [-100, 100],...
                 'ZLim', [-75, 75]);
    else
        sub_tags = {'upper_l', 'upper_r', 'lower_l', 'lower_r'};
        coord_org = node_info.coords;
        for m = 1:4
            h_sub = findobj(gcf, 'Tag', sub_tags{m}, 'type', 'axes');
            set(gcf, 'CurrentAxes', h_sub);
            set(gca, 'XLim', [-70, 70],...
                     'YLim', [-100, 100],...
                     'ZLim', [-75, 75]);
            center_shift = get(gca, 'Userdata');
            node_info.coords = bsxfun(@minus, coord_org, center_shift);
            node_info.x = node_info.coords(:, 1);
            node_info.y = node_info.coords(:, 2);
            node_info.z = node_info.coords(:, 3);
            brant_draw_brain(node_info, edge_info);
        end
    end
end