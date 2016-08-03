function tar_strs = brant_rm_strs(src_strs, rm_strs)
% spliting filename removal using , or ;
% rm_strs: _corr_z;_corr_r could be remove _corr_z and _corr_r from the
% source string if detected

fn_rmv = regexp(rm_strs, '[,;]', 'split');
tar_strs = src_strs;
for m = 1:numel(fn_rmv)
    tar_strs = strrep(tar_strs, fn_rmv{m}, '');
end