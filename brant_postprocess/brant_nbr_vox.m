function ind_out = brant_nbr_vox(mask_ind, nbr_type, size_volume, n_vox_slice, n_vox_vol)
%   mask_ind: one dimension indexes of mask points
%   nbr_type: must be one of 6,7,18,18,26,27
%   size_volume: size of volume
%   n_vox_slice: number of voxels in one slice
%   n_vox_vol: number of voxels in one volume
%   ind_out: 1-D indexes of the neighbour points

pts_shift_gross = [1,...
                   size_volume(1), n_vox_slice(1),...
                   size_volume(1) + 1, size_volume(1) - 1,...
                   n_vox_slice(1) + 1, n_vox_slice(1) - 1,...
                   n_vox_slice(1) + size_volume(1), n_vox_slice(1) - size_volume(1),...
                   n_vox_slice(1) + size_volume(1) + 1, n_vox_slice(1) - size_volume(1) + 1,...
                   n_vox_slice(1) + size_volume(1) - 1, n_vox_slice(1) - size_volume(1) - 1];

num_mask = numel(mask_ind);
vol_ind = zeros([n_vox_vol, 1], 'uint32');
vol_ind(mask_ind) = 1:num_mask;

switch(nbr_type)
    case {6, 7}
        ind_out = zeros(num_mask, 7, 'uint32');
        pts_shift = [0, pts_shift_gross(1:3), -1 * pts_shift_gross(1:3)];
        for n = 1:7
            ind_out(:, n) = vol_ind(mask_ind + pts_shift(n));
        end
    case {18, 19}
        ind_out = zeros(num_mask, 19, 'uint32');
        pts_shift = [0, pts_shift_gross(1:9), -1 * pts_shift_gross(1:9)];
        for n = 1:19
            ind_out(:, n) = vol_ind(mask_ind + pts_shift(n));
        end
    case {26, 27}
        ind_out = zeros(num_mask, 27, 'uint32');
        pts_shift = [0, pts_shift_gross(1:13), -1 * pts_shift_gross(1:13)];
        for n = 1:27
            ind_out(:, n) = vol_ind(mask_ind + pts_shift(n));
        end
    otherwise
        error('nbr_type must be one of 6,7,18,18,26,27');
end
