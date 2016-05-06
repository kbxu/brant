function [vertices_left, vertices_right] = splitVertices(vertices)
limit_ver = round(size(vertices, 1) / 2);
vertices_left = vertices(1:limit_ver, :);
vertices_right = vertices(limit_ver+1:end, :);