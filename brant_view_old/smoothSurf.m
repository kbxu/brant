function vertices_intensity = smoothSurf(vertices_coor, vertices_intensity, volume_matrix)
image = zeros(size(volume_matrix));
image(sub2ind(size(image), round(vertices_coor(:, 1)), round(vertices_coor(:, 2)), round(vertices_coor(:, 3)))) = vertices_intensity;
[X, Y, Z] = meshgrid(1:size(image, 2), 1:size(image, 1), 1:size(image, 3));
vertices_intensity = interp3(X, Y, Z, image, vertices_coor(:, 2), vertices_coor(:, 1), vertices_coor(:, 3));