function realign_prefix = brant_run_realign(rea_infos, data_files, is4d_ind, par)


data_tmp = brant_file_pre(data_files, rea_infos.num_tps, is4d_ind, 'data_cell');
rea_infos.eoptions.weight = '';

fprintf('\n*\tRunning realignment\t*\n');
if par == 0
    for m = 1:numel(data_tmp)
        loop_realign(data_tmp(m), rea_infos);
    end
else
    parfor m = 1:numel(data_tmp)
        loop_realign(data_tmp(m), rea_infos);
    end
end

realign_prefix = rea_infos.roptions.prefix;

fprintf('\n*Realignment finished!*\n');

function loop_realign(data_tmp, rea_infos)

rea_infos.data = data_tmp;
fprintf('\n*\tRunning realignment for subject %s\t*\n', rea_infos.data{1}{1});
% spm_run_realign(rea_infos);
% brant_spm_run_realign_estwrite(outdirs, rea_infos);

spm_v = spm('ver');
if strcmpi(spm_v, 'SPM12')
    spm_run_realign(rea_infos);
else
    spm_run_realign_estwrite(rea_infos);
end
