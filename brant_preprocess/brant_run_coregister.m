function coreg_prefix = brant_run_coregister(coreg_infos, data_files, is4d_ind, par)

file_dirs = brant_get_dirs_from_data(data_files, is4d_ind);

file_ref = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_ref);
file_src = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_src);

fprintf('\n*\tDoing coregister*\n');
if par == 0
    for m = 1:numel(file_src)
        loop_coregister(file_src{m}, file_ref{m}, coreg_infos, file_dirs{m});
    end
else
    parfor m = 1:numel(file_src)
        loop_coregister(file_src{m}, file_ref{m}, coreg_infos, file_dirs{m});
    end
end

coreg_prefix = [];coreg_infos.roptions.prefix;
fprintf('\n*\tCoregister finished!*\n');

function loop_coregister(file_src, file_ref, coreg_infos, file_dirs)
fprintf('\n*\tDoing coregister for data in %s.\t*\n', file_dirs);
coreg_infos = rmfield(coreg_infos, 'subj');
coreg_infos.source = {file_src};
coreg_infos.ref = {file_ref};
coreg_infos.other = {''};


spm_v = spm('ver');
if strcmpi(spm_v, 'SPM12')
    spm_run_coreg(coreg_infos);
else
    spm_run_coreg_estwrite(coreg_infos);
end
