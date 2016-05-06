function [vertices_left, vertices_right, faces_left, faces_right, color_left, color_right] = splitt(vertices, faces, color)
% split vertices
[vertices_left, vertices_right] = splitVertices(vertices);

% split faces
limit_ver = round(size(vertices, 1) / 2);
limit_fac = round(size(faces, 1) / 2);
faces_left = faces(1:limit_fac, :);
faces_right = faces(limit_fac+1:end, :);
faces_right = faces_right - ones(size(faces_right)) * limit_ver;

% split color
[color_left, color_right] = splitVertices(color);
end