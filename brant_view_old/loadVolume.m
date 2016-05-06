function [volume_coor, volume_matrix, trans_matrix, volume_name, value_range, sts] = loadVolume()



% load volume
% volume_name = spm_select(1, 'image');
[volume_name_tmp, sts] = cfg_getfile(1, '^.*\.(nii|img)$');

volume_name = volume_name_tmp{1};

if sts ~= 1
    volume_coor = [];
    volume_matrix = [];
    trans_matrix = [];
    volume_name = [];
    value_range = [];
    return;
end

% load volume using load_nii
volume_nii = load_nii(volume_name);
volume_matrix = volume_nii.img;
trans_matrix = [volume_nii.hdr.hist.srow_x; volume_nii.hdr.hist.srow_y; volume_nii.hdr.hist.srow_z];
if trans_matrix(1, 1) < 0
    trans_matrix(1, :) = trans_matrix(1, :) * -1;
end
trans_matrix(:, end) = trans_matrix(:, end) - diag(trans_matrix);
trans_matrix = [trans_matrix; 0, 0, 0, 1];

% volume_vol = spm_vol(volume_name);
% volume_matrix = spm_read_vols(volume_vol);

% compute the volume's voxel coordinates
[x, y, z] = ind2sub(size(volume_matrix), find(volume_matrix ~= 0));
volume_coor = [x y z];

% find image transformation matrix (MNI to voxel space)
% trans_matrix = volume_vol.mat;
% if trans_matrix(1, 1) < 0
%     trans_matrix(1, :) = trans_matrix(1, :) * (-1);
% end
    
% process volume name
[pth_tmp, volume_name] = fileparts(volume_name);
volume_name = regexprep(volume_name, '.nii$', '', 'ignorecase');
% ind_back_slash = find(volume_name == '\');
% last_back_slash = ind_back_slash(end);
% volume_name = volume_name(last_back_slash + 1:length(volume_name) - 2);

% find value range
value_range = [0 0];
value_range(1) = min(volume_matrix(:));
value_range(2) = max(volume_matrix(:));

