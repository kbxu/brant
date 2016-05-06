function vol_new = brant_thres_clustersize(vol_3d, cs_thr)

[vol_tmp, num_c] = bwlabeln(vol_3d, 18); % default is 18

vol_nums = 1:num_c;

vol_ind = arrayfun(@(x) vol_tmp == x, vol_nums, 'UniformOutput', false);
cs_size = cellfun(@(x) sum(x(:)), vol_ind);

cs_bad = cs_size < cs_thr;

if any(cs_bad)
    bad_nums = vol_nums(cs_bad);
    for m = 1:numel(bad_nums)
        vol_tmp(vol_ind{bad_nums(m)}) = 0;
    end
end

vol_new = vol_3d;
vol_new(vol_tmp == 0) = 0;
