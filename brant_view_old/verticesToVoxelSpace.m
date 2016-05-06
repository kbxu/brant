function vertices_coor = verticesToVoxelSpace(vertices, trans_matrix)
% bring the vertices into the voxel space
vertices_coor = (trans_matrix \ [vertices ones(size(vertices, 1), 1)]')';
vertices_coor = vertices_coor(:, 1:3);

