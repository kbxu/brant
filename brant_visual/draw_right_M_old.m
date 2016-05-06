function draw_right_M(faces_right, vertices_right, jobman)
Brain_left_M = draw_surf(faces_right, vertices_right, jobman);
view(-90, 0)
hold on
% right hemisphere medial node
if ~isempty(jobman.node)
    [node_coord, label] = load_node(jobman.node);
    node_ind = find(node_coord(:, 1)>=0);
    node = node_coord(node_ind, :);
    for i = 1: length(node_ind)
        node_label{i} = label{node_ind(i)};
    end
    draw_node(node, node_label, jobman)
    
    % edge
    if ~isempty(jobman.edge)
        [sub_1, sub_2, edge_fc, index] = thre_line(jobman, node_coord);
        for i = 1:size(sub_1, 1)
            if node_coord(sub_1(i), 1) >= 0 && node_coord(sub_2(i), 1)>=0
                draw_line(jobman, edge_fc(index(i)), node_coord(sub_1(i), :), node_coord(sub_2(i), :), node_coord)
            end
        end
        hold off
    end
end
camlight left
axis off
axis tight