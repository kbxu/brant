function brant_draw_brain(node_info, edge_info)

       
hold('on');
if ~isempty(node_info)
    node_ind = true(size(node_info.x, 1), 1);
    if ~isempty(edge_info.edge) && edge_info.wei_rad == 1
        edge_part = edge_info.edge;
        thres_str = strrep(edge_info.thres, 'edge', 'edge_part');
        edge_ind = eval(thres_str);
        size_raw = sum(abs(edge_part .* edge_ind), 2);
        size_raw_scale_tmp = ((size_raw(size_raw ~= 0) - 1) / max(size_raw)) * 7 + 1;
        size_raw_scale = size_raw;
        size_raw_scale(size_raw ~= 0) = size_raw_scale_tmp;
        node_info.size = size_raw_scale;
        
        
        if edge_info.wei_thr > 0
            node_ind = size_raw >= edge_info.wei_thr & node_ind;
        end
    end
    [h_node, h_text] = brant_draw_node_new(node_ind, node_info.coords, node_info);

    if ~isempty(edge_info.edge) && edge_info.edge_disp == 1
        edge_ind = brant_draw_line_new(edge_info, node_info, node_ind, node_info.coords);

        if edge_info.hide_node == 1
            node_ind_show = sum(abs(triu(edge_ind, 1)) + abs(triu(edge_ind, 1))') > 0;
            cellfun(@delete, h_node(node_ind_show == 0));
            if ~isempty(h_text)
                cellfun(@delete, h_text(node_ind_show == 0));
            end
        end
    end    
    lighting('phong');
end
hold('off');
