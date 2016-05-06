function [vertices_intensity] = volumeSurfaceIntersect(volume_matrix, vertices_coor)
round_vertices_coor = floor(vertices_coor);
vert_ind = sub2ind(size(volume_matrix), round_vertices_coor(:, 1), round_vertices_coor(:, 2), round_vertices_coor(:, 3));
vertices_intensity = volume_matrix(vert_ind);
