function nor_prefix = brant_run_normalise(nor_infos, data_files, is4d_ind, par)
% run old normalise before SPM2012

file_dirs = brant_get_dirs_from_data(data_files, is4d_ind);

% file_est: file for estimation which by default is mean*.nii
file_est = brant_get_subjs2(file_dirs, 1, nor_infos.subj.filetype_src);

if ~isempty(nor_infos.subj.filetype_wt)
    file_wt = brant_get_subjs2(file_dirs, 1, nor_infos.subj.filetype_wt);
else
    file_wt = cell(numel(file_est), 1);
end

data_tmp = brant_file_pre(data_files, nor_infos.num_tps, is4d_ind, 'data_cell');

fprintf('\n*\tRunning normalise*\n');
if par == 0
    for m = 1:numel(data_tmp)
        loop_normalise(data_tmp{m}, file_est{m}, file_wt{m}, nor_infos, file_dirs{m});
    end
else
    parfor m = 1:numel(data_tmp)
        loop_normalise(data_tmp{m}, file_est{m}, file_wt{m}, nor_infos, file_dirs{m});
    end
end

nor_prefix = nor_infos.roptions.prefix;
fprintf('\n*\tNormalise finished!*\n');

function loop_normalise(data_tmp, file_est, file_wt, nor_infos, file_dirs)
fprintf('\n*\tRunning normalise for subject %s\t*\n', file_dirs);
nor_infos.subj.resample = data_tmp;
nor_infos.subj.source = file_est;
nor_infos.subj.wtsrc = file_wt;
% brant_spm_run_normalise_estwrite(outdirs, nor_infos);

spm_v = spm('ver');
if strcmpi(spm_v, 'SPM12')
    spm_run_normalise(nor_infos);
else
    spm_run_normalise_estwrite(nor_infos);
end
