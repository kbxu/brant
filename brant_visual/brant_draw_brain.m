function brant_draw_brain(faces, vertices, surf_alpha, node_info, edge_info, view_ang, node_ind)

brant_draw_surf(faces, vertices, surf_alpha);
view(view_ang);
hold('on');

if ~isempty(node_info)
    if ~isempty(edge_info.edge) && edge_info.wei_rad == 1
        edge_part = edge_info.edge;
        thres_str = strrep(edge_info.thres, 'edge', 'edge_part');
        edge_ind = eval(thres_str);
        size_raw = sum(abs(edge_part .* edge_ind), 2);
        node_info.size = (size_raw / max(size_raw)) * 8;
        
        if edge_info.wei_thr > 0
            node_ind = size_raw >= edge_info.wei_thr & node_ind;
        end
    end
    [h_node, h_text] = brant_draw_node_new(node_ind, node_info.coords, node_info);
end

if ~isempty(edge_info.edge) && edge_info.edge_disp == 1
    edge_ind = brant_draw_line_new(edge_info, node_info, node_ind, node_info.coords);

    if edge_info.hide_node == 1
        node_ind_show = sum(abs(triu(edge_ind, 1)) + abs(triu(edge_ind, 1))') > 0;
    %     edge_ind = edge_ind - diag(diag(edge_ind));
    %     node_ind_show = sum(abs(edge_ind)) > 0;
        cellfun(@delete, h_node(node_ind_show == 0));
        if ~isempty(h_text)
            cellfun(@delete, h_text(node_ind_show == 0));
        end
    end
% edge_draw_tmp = edge_ind .* edge_info.edge;
% node_ind_up = triu(edge_ind, 1);
% [node_x_ind, node_y_ind] = find(node_ind_up);
% edge_draw = sign(edge_draw_tmp(node_ind_up));
% edge_strs = arrayfun(@edge_strs_output, edge_draw, 'UniformOutput', false);

% edge_pos = edge_draw > 0;
% fprintf('Positive connections:\n');
% cellfun(@(x, y) fprintf(['%-', num2str(length(strrep(x, '\_', '_'))),...
%         's -- %-', num2str(length(strrep(y, '\_', '_'))), 's\n'],...
%         strrep(x, '\_', '_'), strrep(y, '\_', '_')),...
%         node_info.label(node_x_ind(edge_pos)), node_info.label(node_y_ind(edge_pos)));
% 
%     
% edge_neg = edge_draw < 0;
% fprintf('Negative connections:\n');
% cellfun(@(x, y) fprintf(['%-', num2str(length(strrep(x, '\_', '_'))),...
%         's -- %-', num2str(length(strrep(y, '\_', '_'))), 's\n'],...
%         strrep(x, '\_', '_'), strrep(y, '\_', '_')),...
%         node_info.label(node_x_ind(edge_neg)), node_info.label(node_y_ind(edge_neg)));
end

% campos
h_light = camlight('right');
set(h_light, 'Position', campos);
axis('off');
axis('tight');
hold('off');