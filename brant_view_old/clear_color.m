function [color, color_on] = clear_color(size_vertices_1, bg_grey)
color = ones(size_vertices_1, 3) * bg_grey;
color_on = zeros(size_vertices_1, 1);