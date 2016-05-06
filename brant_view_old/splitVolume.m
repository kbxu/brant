function [volume_right, volume_left, xlimit] = splitVolume(volume_matrix)
xlimit = size(volume_matrix, 1) / 2;
volume_left = volume_matrix(1:ceil(xlimit), :, :);
volume_right = volume_matrix(ceil(xlimit) + 1:end, :, :);