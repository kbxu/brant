function sm_prefix = brant_run_smooth(sm_infos, data_files, is4d_ind, par)

data_tmp = brant_file_pre(data_files, sm_infos.num_tps, is4d_ind, 'data_cell');

fprintf('\n*\tRunning smooth\t*\n');
if par == 0
    for m = 1:numel(data_tmp)
        loop_smooth(data_tmp{m}, sm_infos);
    end
else
    parfor m = 1:numel(data_tmp)
        loop_smooth(data_tmp{m}, sm_infos);
    end
end

sm_prefix = sm_infos.prefix;
fprintf('\n*\tSmooth finished!*\n');


function loop_smooth(data_tmp, sm_infos)
sm_infos.data = data_tmp;
fprintf('\n*\tRunning smooth for subject %s\t*\n', fileparts(sm_infos.data{1}));
spm_run_smooth(sm_infos);
% brant_spm_run_smooth(outdirs, sm_infos);
