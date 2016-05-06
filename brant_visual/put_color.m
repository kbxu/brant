function color = put_color(volume_name, coord)
%%%%  coord is the surface vertices coordinates.
v = spm_vol(volume_name);
volume_matrix = spm_read_vols(v);
[x, y, z] = ind2sub(size(volume_matrix), find(volume_matrix == 19));
volume_coord = [x, y, z];
trans_matrix = v.mat;
if trans_matrix(1, 1)>0
    trans_matrix(1, :) = trans_matrix(1, :)*-1;
end

% transform the vertices to voxel space
vertices_coord = (inv(trans_matrix)*[coord, ones(size(coord, 1), 1)]')';
vertices_coord = vertices_coord(:, 1:3);
% split vertices_coord
limit_ver = round(size(vertices_coord, 1)/2);
vertices_left_coord = vertices_coord(1: limit_ver, :);
vertices_right_coord = vertices_coord(limit_ver+1:end, :);
% split volume
limit_vol = size(volume_matrix, 1)/2;
volume_right = volume_matrix(1: ceil(limit_vol), :, :);
volume_left = volume_matrix(floor(limit_vol)+1:end, :, :);
vertices_left_coord = vertices_left_coord - [ones(size(vertices_left_coord, 1), 1)*floor(limit_vol), ...
zeros(size(vertices_left_coord, 1), 2)];
% left hemisphere
left_multi_intensity = hemiIntersect(vertices_left_coord, volume_left);
% right hemisphere
right_multi_intensity = hemiIntersect(vertices_right_coord, volume_right);
data_type = 'continuous positive values';
vertices_intensity = projectIntersections(left_multi_intensity, right_multi_intensity, data_type);
color = ones(size(vertices_intensity, 1), 3)*0.95;
temp = find(vertices_intensity ~=0 );
color_diff = [1, 1, 0];                  %%%% color
color_temp = repmat(color_diff, [numel(temp), 1]);
color(temp, :) = color_temp;
