function brant_sd(jobman)
% short-distant degree

bn_path = fullfile(fileparts(which('brant')), 'brant_postprocess', 'brant_FC');

if jobman.nm_pos == 1
    rec_str = '';
else
    rec_str = [32, '-rec', 32, num2str(jobman.nm_pos - 1), 32];
end

if (jobman.gpu == 1) && (jobman.cpu == 1)
    mode_str = 'all';
elseif jobman.gpu == 1
    mode_str = 'gpu';
elseif jobman.cpu == 1
    mode_str = 'cpu';
else
    mode_str = 'matlab';
end

if ~strcmpi(mode_str, 'matlab')
    pwd_tmp = pwd;
    cd(bn_path);
    [stat, cmd_out] = system(['start cmd.exe /C BN.exe', 32, '-in', 32, '"', jobman.src_dir, '"', 32,...
                                                               rec_str,...
                                                               '-out', 32, '"', jobman.out_dir, '"', 32,...
                                                               '-filereg', 32, jobman.filetype, 32,...
                                                               '-coef sd', 32,...
                                                               '-thres_mm', 32, jobman.thres_dist, 32,...
                                                               '-thres_corr', 32, jobman.thres_corr, 32,...
                                                               '-mask', 32, '"', jobman.mask_fn, '"', 32,...
                                                               '-mode', 32, mode_str, 32,...
                                                               '-gpub', 32, num2str(jobman.gpub), 32,...
                                                               '-cpub', 32, num2str(jobman.cpub), 32,...
                                                               ]); %#ok<*ASGLU>
    disp(cmd_out);
    cd(pwd_tmp);
else
    brant_sd_matlab(jobman.mask_fn, subj_vols, jobman.thres_corr, jobman.thres_dist, jobman.out_dir);
end
