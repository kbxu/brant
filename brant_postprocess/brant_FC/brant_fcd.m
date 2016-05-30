function brant_fcd(jobman)

outdir = jobman.out_dir{1};
mask_fn = jobman.mask{1};
bn_path = fileparts(which(mfilename));
ba_full = fullfile(bn_path, 'BN.exe');

is4d_ind = jobman.input_nifti.is4d;
if is4d_ind == 0 || ispc == 0
    error('Current C++ excutable only works on 4-D data.');
end
nifti_list = brant_get_subjs(jobman.input_nifti);
nmpos = jobman.input_nifti.nm_pos;

mask_tmp = load_nii(mask_fn);
new_mask_fn = fullfile(outdir, 'brant_mask_for_fcd.nii');
save_nii(mask_tmp, new_mask_fn);

text_out = fullfile(outdir, 'fcd_subject_list.txt');
fid = fopen(text_out, 'wt');
cellfun(@(x) fprintf(fid, '%s\n', x), nifti_list);
fclose(fid);

if jobman.cpu == 1
    mode_str = '-mode cpu -cpub 256';
else
    mode_str = '-mode gpu -gpub 256';
end

outdir = regexprep(outdir, '[\/\\]+$', '');

if ispc == 1
    fprintf('\n\tRunning FCD in new command windows...\n');
    cmd_str = sprintf('"%s" -infile "%s" -coef fcd -thres_corr 0.6 -mask "%s" -nmpos %d -out "%s" %s',...
                    ba_full, text_out, new_mask_fn, nmpos, outdir, mode_str);
    system(['start', 32, '"brant fcd" cmd.exe /K', 32, cmd_str]);
else
    error('Not supported platform!');
end
