function [left_multi_intensity, right_multi_intensity] = multiIntersect(volume_matrix, vertices_coor)

% split two hemispheres
[vertices_left, vertices_right] = splitVertices(vertices_coor);
[volume_right, volume_left, xlimit] = splitVolume(volume_matrix);
vertices_left = vertices_left - [ones(size(vertices_left, 1), 1) * floor(xlimit), zeros(size(vertices_left, 1), 2)];

% left hemisphere
left_multi_intensity = hemiIntersect(vertices_left, volume_left);
% right hemisphere
right_multi_intensity = hemiIntersect(vertices_right, volume_right);