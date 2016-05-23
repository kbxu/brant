function st_prefix = brant_run_slicetiming(st_infos, data_files, is4d_ind, par)

if sum(size(st_infos.slice_order) > 1) > 1
    error('The input format of slice order is wrong, please check your input parameters.');
end


TR = st_infos.tr;
nslice = length(st_infos.slice_order);
TA = TR - TR / nslice;
timing(1) = TA / (nslice - 1);
timing(2) = TR - TA;
slice_order = st_infos.slice_order;
refslice = st_infos.refslice;
prefix = st_infos.prefix;

data_mat = brant_file_pre(data_files, st_infos.num_tps, is4d_ind, 'data_matrix');

if par == 0
    for m = 1:numel(data_files)
        spm_slice_timing(data_mat{m}, slice_order, refslice, timing, prefix);
    end
else
    parfor m = 1:numel(data_files)
        spm_slice_timing(data_mat{m}, slice_order, refslice, timing, prefix);
    end
end

st_prefix = prefix;

fprintf('\nSlice Timing Finished!\n');
