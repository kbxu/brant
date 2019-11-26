function brant_reslice_batch(jobman)

ref_file = jobman.ref{1};

if jobman.out_ind_del == 1
    brant_check_empty(jobman.out_dir_del{1}, '\tPlease specify an output directories!\n');
    outdir = jobman.out_dir_del{1};
else
    outdir = '';
end

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
if jobman.input_nifti.is4d == 1
    rst_files = brant_reslice(ref_file, nifti_list, jobman.out_prefix, 4);
else
    rst_files = cellfun(@(x) brant_reslice(ref_file, x, jobman.out_prefix, 4), nifti_list, 'UniformOutput', false);
end

if jobman.out_ind_del == 1
    if ispc == 1, mv_func = 'move'; else, mv_func = 'mv'; end
    for m = 1:numel(subj_ids)
        fprintf('Moving files for %s...\n', subj_ids{m});
        outdir_subj = fullfile(outdir, subj_ids{m});
        if exist(outdir_subj, 'dir') ~= 7
            mkdir(outdir_subj);
        end
        
        if jobman.input_nifti.is4d == 1
            system([mv_func, 32, '"', rst_files{m}, '"', 32, '"', outdir_subj, '"']);
        else
            cellfun(@(x) system([mv_func, 32, '"', x, '"', 32, '"', outdir_subj, '"']), rst_files{m});
        end
    end
end