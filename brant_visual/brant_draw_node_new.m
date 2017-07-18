function [h_node, h_text] = brant_draw_node_new(node_ind, node_coords, node_info, hide_ind)

node_color = node_info.color(node_ind, :);
r = node_info.size(node_ind);
coords_part = node_coords(node_ind, :);
label_part = node_info.label(node_ind);

[x_sph, y_sph, z_sph] = sphere(100);
num_node = size(coords_part, 1);

if hide_ind == 1
    node_idx = find(r > 0);    
else
    r(r == 0) = 3;
    node_idx = 1:num_node;
end

node_x = arrayfun(@(x) x_sph .* r(x) + coords_part(x, 1), node_idx, 'UniformOutput', false);
node_y = arrayfun(@(x) y_sph .* r(x) + coords_part(x, 2), node_idx, 'UniformOutput', false);
node_z = arrayfun(@(x) z_sph .* r(x) + coords_part(x, 3), node_idx, 'UniformOutput', false);
h_node = cellfun(@(x, y, z, o) mesh(x, y, z, 'DisplayName', node_info.module{o},...
                                             'Edgecolor', 'none',...
                                             'Facecolor', node_color(o, :),...
                                             'EdgeAlpha', 0),...
                               node_x, node_y, node_z, num2cell(node_idx), 'UniformOutput', false);

% arrayfun(@(x) set(node_mesh{x}, 'Facecolor', node_color(x, :)), 1:num_node);
% cellfun(@(x) set(x, 'EdgeAlpha', 0), node_mesh);

brain_halves_ind = 1;
select_view = 3;

if ((node_info.show_label == 1) && all(cellfun(@isempty, label_part) == 0))
    if ((brain_halves_ind == 1) && any(select_view == [2, 5])) || ((brain_halves_ind == 0) && any(select_view == [2, 4]))
        text_xyz = coords_part + [-2 - r, 2 + r, 2 + r];
    elseif (((brain_halves_ind == 1) && any(select_view == [3, 4]) || (brain_halves_ind == 0 && select_view == 3)))
        text_xyz = coords_part + [-2 - r, 2 - r, 2 + r]; % [1- r, r-r, r-r+300] in transverse view, change z increment 2 to 300 to see labels
    elseif ((brain_halves_ind == 0) && (select_view == 5))
        text_xyz = coords_part + [2 + r, -2 - r, 2 + r];
    else
        text_xyz = coords_part + [2 + r, -r, 3 + r];
    end
    %% oo
%     aa=load('size_raw.mat');bb=aa.size_raw(node_ind);node_idx=node_idx(bb>=5);
%     h_text = arrayfun(@(x) text(text_xyz(x, 1), text_xyz(x, 2), text_xyz(x, 3), label_part{x}, 'FontWeight', 'Bold', 'FontSize', 10), node_idx, 'UniformOutput', false);
    h_text = arrayfun(@(x) text(text_xyz(x, 1), text_xyz(x, 2), text_xyz(x, 3), label_part{x}, 'FontWeight', 'Bold'), node_idx, 'UniformOutput', false);
else
    h_text = [];
end  
    
% axis('tight');
% lighting('phong');
