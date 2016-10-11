function brant_reslice_batch(jobman)

ref_file = jobman.ref{1};

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);

if jobman.input_nifti.is4d == 1
    tps_tps = cellfun(@brant_get_nii_frame, nifti_list);
else
    tps_tps = cellfun(@numel, nifti_list);
end

src_file = brant_file_pre(nifti_list, tps_tps, jobman.input_nifti.is4d, 'data_cell');

rst_files = brant_reslice(ref_file, src_file, jobman.out_prefix, jobman.input_nifti.is4d);