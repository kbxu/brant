function nor_prefix = brant_run_normalise12(nor_infos, data_files, is4d_ind, par)
% run new normalise after SPM2012

file_dirs = brant_get_dirs_from_data(data_files, is4d_ind);

% file_est: file for estimation which by default is mean*.nii
file_est = brant_get_subjs2(file_dirs, 1, nor_infos.subj.filetype_src);
data_tmp = brant_file_pre(data_files, nor_infos.num_tps, is4d_ind, 'data_cell');


nor_infos.eoptions.tpm = {nor_infos.eoptions.tpm};

fprintf('\n*\tRunning normalise*\n');
if par == 0
    for m = 1:numel(data_tmp)
        loop_normalise(data_tmp{m}, file_est{m}, nor_infos, file_dirs{m});
    end
else
    parfor m = 1:numel(data_tmp)
        loop_normalise(data_tmp{m}, file_est{m}, nor_infos, file_dirs{m});
    end
end

nor_prefix = nor_infos.woptions.prefix;
fprintf('\n*\tNormalise finished!*\n');

function loop_normalise(data_tmp, file_est, nor_infos, file_dirs)
fprintf('\n*\tRunning normalise for subject %s\t*\n', file_dirs);
nor_infos.subj.resample = data_tmp;
nor_infos.subj.vol = {file_est};

spm_run_norm(nor_infos);
