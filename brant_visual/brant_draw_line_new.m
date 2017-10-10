function edge_ind = brant_draw_line_new(edge_info, node_info, node_ind, node_coord)

edge_part = edge_info.edge(node_ind, node_ind);
node_coord_part = node_coord(node_ind, :);
module_part = node_info.module(node_ind);
color_part = node_info.color(node_ind, :);


thres_str = strrep(edge_info.thres, 'edge', 'edge_part');
edge_ind = eval(thres_str);

if all(edge_ind(:) == 0)
    fprintf('\tNo edge survived the threshold %s.\n', edge_info.thres);
    return
end

[node_1_ind, node_2_ind] = find(triu(edge_ind, 1));
node_ind_up = triu(edge_ind, 1) ~= 0;
% edge_thres = edge_part .* edge_ind;
edge_thres = edge_ind;
fc_strength = edge_thres(node_ind_up) .* edge_part(node_ind_up);

node_1 = node_coord_part(node_1_ind, :);
node_2 = node_coord_part(node_2_ind, :);

num_edge = numel(fc_strength);

% % hack starts
% fcInd = fc_strength;
% fc_strength = sign(fc_strength) .* ones(num_edge, 1);
% uniqFcColor = unique(fcInd);
% numColor = numel(uniqFcColor);
% clrEdge = rand(numColor, 3);
% % hack ends


interval = 20;
theta = (0:interval) / interval * 2 * pi;
theta(end) = 0;
n = arrayfun(@(x) x * edge_info.thickness * ones(50, 1), abs(fc_strength), 'UniformOutput', false);
edge_x = cellfun(@(x) x * cos(theta), n, 'UniformOutput', false);
edge_y = cellfun(@(x) x * sin(theta), n, 'UniformOutput', false);
len = arrayfun(@(x) norm(node_1(x, :) - node_2(x, :)), 1:num_edge);
edge_z = cellfun(@(x) (0:length(x)-1)'/(length(x)-1) * ones(1, length(theta)), n, 'UniformOutput', false);
cyl_stick = arrayfun(@(x) mesh(edge_x{x}, edge_y{x}, edge_z{x} * len(x)), 1:num_edge, 'UniformOutput', false);

unit_ver = repmat([0. 0, 1], num_edge, 1);
dot_ver = bsxfun(@dot, unit_ver', (node_1 - node_2)');
rot_angle = acos(dot_ver ./ (norm([0. 0, 1]) * len)) * 180 / pi;
rot_aix = bsxfun(@cross, unit_ver', (node_1 - node_2)');

arrayfun(@(x) rotate(cyl_stick{x}, rot_aix(:, x), rot_angle(x), [0 0 0]), 1:num_edge);
arrayfun(@(x) set(cyl_stick{x}, 'XData', get(cyl_stick{x}, 'XData') + node_2(x, 1)), 1:num_edge)
arrayfun(@(x) set(cyl_stick{x}, 'YData', get(cyl_stick{x}, 'YData') + node_2(x, 2)), 1:num_edge)
arrayfun(@(x) set(cyl_stick{x}, 'ZData', get(cyl_stick{x}, 'ZData') + node_2(x, 3)), 1:num_edge)

% % hack starts
% for m = 1:numColor
%     tmpInd = fcInd == uniqFcColor(m);
%     cellfun(@(x) set(x, 'FaceColor', clrEdge(m, :)), cyl_stick(tmpInd));
% end
% return;
% % hack ends


if (edge_info.adjust_edge_color == 1)
    fc_neg = fc_strength < 0;
    if any(fc_neg)
        cellfun(@(x) set(x, 'FaceColor', edge_info.neg_color), cyl_stick(fc_neg));
    end
    
    fc_pos = fc_strength > 0;
    if any(fc_pos)
        cellfun(@(x) set(x, 'FaceColor', edge_info.pos_color), cyl_stick(fc_pos));
    end
    
else
    node_mod_ind = cellfun(@strcmpi, module_part(node_1_ind), module_part(node_2_ind));
    
    inter_mod_ind = node_mod_ind == 0;
    if any(inter_mod_ind)
        cellfun(@(x) set(x, 'FaceColor', [0.7, 0.7, 0.7]), cyl_stick(inter_mod_ind));
    end
    
    intra_mod_ind = node_mod_ind == 1;
    if any(intra_mod_ind)
        edge_color_tmp = color_part(node_1_ind(intra_mod_ind), :);
        arrayfun(@(x, y) set(x{1}, 'FaceColor', edge_color_tmp(y, :)), cyl_stick(intra_mod_ind), 1:sum(intra_mod_ind));
    end
end


cellfun(@(x) set(x, 'EdgeColor', 'none'), cyl_stick);
cellfun(@(x) set(x, 'FaceAlpha', 1), cyl_stick);
cellfun(@(x) set(x, 'EdgeAlpha', 0), cyl_stick);
% lighting('phong');
