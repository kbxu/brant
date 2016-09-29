function brant_rm_tps(fn, n_del, out_fn)

if (exist(fn, 'file') == 2)
    fprintf('\tRemoving first %d time points for subject %s\n', n_del, fn);
    tot_tps = brant_get_nii_frame(fn);
    img_tmp = load_untouch_nii_mod(fn, n_del + 1:tot_tps);
    fn_path = fileparts(fn);
    save_untouch_nii(img_tmp, fullfile(fn_path, out_fn));
else
    error('%s file not exist!\n', fn);
end