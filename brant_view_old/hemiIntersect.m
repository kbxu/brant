function multi_intensity = hemiIntersect(half_vertices, half_volume)
% vertices' mean
mean_ver = mean(half_vertices);
% we want to have a zero-mean surface
zm_vertices = matMinusRowVec(half_vertices, mean_ver);

ratio = [1, 0.98, 0.96, 0.94, 0.92, 0.9];

multi_intensity = zeros(size(half_vertices, 1), length(ratio));
for i = 1:length(ratio)
    % resize the surface
    resized_vertices = zm_vertices * ratio(i);
    % add back the mean to go back to the voxel space
    vertices = matPlusRowVec(resized_vertices, mean_ver);
    % compute the intersection of the volume and the surface defined by the
    % vertices
    multi_intensity(:, i) = volumeSurfaceIntersect(half_volume, vertices);
end
