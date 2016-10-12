function brant_reslice_batch(jobman)

ref_file = jobman.ref{1};

if jobman.out_ind_del == 1
    brant_check_empty(jobman.out_dir_del{1}, '\tPlease specify an output directories!\n');
    outdir = jobman.out_dir_del{1};
else
    outdir = '';
end

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
rst_files = brant_reslice(ref_file, nifti_list, jobman.out_prefix, 4);

if jobman.out_ind_del == 1
    for m = 1:numel(subj_ids)
        fprintf('Moving files for %s...\n', subj_ids{m});
        outdir_subj = fullfile(outdir, subj_ids{m});
        if exist(outdir_subj, 'dir') ~= 7
            mkdir(outdir_subj);
        end
        
        if ispc == 1
            system(['move', 32, '"', rst_files{m}, '"', 32, '"', outdir_subj, '"']);
        else
            system(['mv', 32, '"', rst_files{m}, '"', 32, '"', outdir_subj, '"']);
        end
    end
end