function brant_draw_brain(node_info, edge_info)

hold('on');
if ~isempty(node_info)
    node_ind = true(size(node_info.x, 1), 1);
    if ~isempty(edge_info.edge)
        edge_part = edge_info.edge;
        edge_part(logical(eye(size(edge_part, 1)))) = 0;
        thres_str = strrep(edge_info.thres, 'edge', 'edge_part');
        edge_ind = eval(thres_str);
        
        size_raw = sum(abs(edge_part .* edge_ind), 2);
%         save('size_raw.mat', 'size_raw'); % oo
        if edge_info.wei_rad == 1
%             size_raw_scale_tmp = size_raw(size_raw ~= 0);
            size_raw_scale_tmp = ((size_raw(size_raw ~= 0) - 1) / max(size_raw)) * 7 + 3; %  ((size_raw(size_raw ~= 0) - 1) / max(size_raw)) * 7 + 3;
            size_raw_scale = size_raw;
            size_raw_scale(size_raw ~= 0) = size_raw_scale_tmp;
            node_info.size = size_raw_scale;
%             node_ind = (size_raw_scale >= edge_info.wei_thr) & node_ind;
        else
            node_info.size(size_raw == 0) = 0;
        end
        
        if (edge_info.wei_thr > 0)
            node_ind = (size_raw >= edge_info.wei_thr) & node_ind;
        end
    end
    brant_draw_node_new(node_ind, node_info.coords, node_info, edge_info.hide_node);

    if ((~isempty(edge_info.edge)) && (edge_info.edge_disp == 1))
        brant_draw_line_new(edge_info, node_info, node_ind, node_info.coords);
    end    
    lighting('phong');
end
hold('off');
