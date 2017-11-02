function brant_preprocess_jobman(jobman, h_fig)

%% use diary
process_ind = cellfun(@(x) jobman.ind.(x), jobman.pref.order);
working_dir = jobman.subj.out.dir;

if any(process_ind)
    if ~isempty(h_fig)
        string_disp = brant_update_pre_disp;
        try
            time_now = ceil(clock);
            fn = fullfile(working_dir, ['brant_log', sprintf('_%d', time_now), '.txt']);
            fid = fopen(fn, 'wt');
            fprintf(fid, '%s\n', string_disp{:});
            fclose(fid);
        catch
            warning('on');
            warning('Error creating log file at %s!', pwd);
        end
    
        h_filetype = findobj(h_fig, 'Tag', 'filetype_text');
    else
        h_filetype = [];
    end
%     set(h_run_btn, 'Enable', 'off');
%     brant_preprocess_jobman(jobman, h_filetype, h_fig);
%     set(h_run_btn, 'Enable', 'on');
else
    return;
end

%%
process_ind = cellfun(@(x) jobman.ind.(x), jobman.pref.order);

if any(process_ind)
    processes_curr = jobman.pref.order(process_ind > 0.5);
    %     run_data = brant_prep_run(jobman, processes_curr);
    for m = 1:numel(processes_curr)
        run_data.(processes_curr{m}) = jobman.(processes_curr{m});
    end
    %     run_data = jobmna.
    
    if (jobman.pref.dirs_in_text == 1)
        dirs = jobman.subj.text.dirs;
    else
        dirs = jobman.subj.spm.dirs;
    end
    
    if isempty(dirs)
        error('No directory has been selected!');
    end
    
    if isempty(jobman.subj.out.dir)
        error('Working directory must be selected!');
    end
    
    working_dir = jobman.subj.out.dir;
    
    if (jobman.subj.out.selected == 1)
        
        data_input_tmp.dirs = dirs;
        data_input_tmp.nm_pos = jobman.subj.out.nmpos;
        data_input_tmp.filetype = jobman.subj.filetype;
        [nifti_list_tmp, subj_ids] = brant_get_subjs(data_input_tmp);
        
        try
            data_input_tmp.filetype = jobman.denoise.motion.filetype; % rp*.txt bt default
            [nifti_list_rp, subj_ids_tmp] = brant_get_subjs(data_input_tmp);
        catch
            nifti_list_rp = '';
        end
        
        try
            data_input_tmp.filetype = jobman.normalise.subj.filetype_src; % 'mean*.nii';
            [nifti_list_mean, subj_ids_tmp] = brant_get_subjs(data_input_tmp);
        catch
            nifti_list_mean = '';
        end
        
        output_dirs = cellfun(@(x) fullfile(jobman.subj.out.dir, x), subj_ids, 'UniformOutput', false);
        [old_pth, fn] = cellfun(@fileparts, nifti_list_tmp, 'UniformOutput', false);
        nifti_list_tmp_mat = cellfun(@(x, y) fullfile(x, y, '.mat'), old_pth, fn, 'UniformOutput', false);
        for m = 1:numel(output_dirs)
            if (exist(output_dirs{m}, 'dir') ~= 7)
                mkdir(output_dirs{m});
                fprintf('Copy %s to %s.\n', nifti_list_tmp{m}, output_dirs{m});
                brant_copyfile(nifti_list_tmp{m}, output_dirs{m});
            end
        end
        if all(cellfun(@exist, nifti_list_tmp_mat))
            for m = 1:numel(output_dirs)
                fprintf('Copy %s to %s.\n', nifti_list_tmp_mat{m}, output_dirs{m});
                brant_copyfile(nifti_list_tmp_mat{m}, output_dirs{m});
            end
        end
        
        if (ismember('realign', processes_curr) == 0)
            if any(strcmpi(processes_curr, 'denoise'))
                if all(cellfun(@exist, nifti_list_rp))
                    cellfun(@brant_copyfile, nifti_list_rp, output_dirs);
                end
            end
            
            % copy mean*.nii files for normalise
            if (any(strcmpi(processes_curr, 'normalise')) || any(strcmpi(processes_curr, 'normalise12')))
                if all(cellfun(@exist, nifti_list_mean))
                    fprintf('Copying source files...\n');
                    cellfun(@brant_copyfile, nifti_list_mean, output_dirs);
                end
            end
        end
    else
        output_dirs = cell(numel(dirs), 1);
    end
    
    if strcmp(jobman.pref.parallel, 'on')
        par_on = 1;
        try
            if isempty(gcp('nocreate'))
                par_info = parcluster('local');
                parpool(par_info, jobman.pref.parallel_workers);
            end
        catch
            if (matlabpool('size') == 0)
                matlabpool('open', jobman.pref.parallel_workers);
            end
        end
    else
        par_on = 0;
    end
    
    data_input.dirs = dirs;
    data_input.nm_pos = jobman.subj.out.nmpos;
    data_input.is4d = jobman.subj.is4d;
    if (jobman.subj.out.selected == 1)
        data_input.dirs = output_dirs;
    end
    spm('defaults', 'FMRI');
    
    for m = 1:numel(processes_curr)
        
        clear('split_prefix');
        split_prefix = brant_parse_filetype(jobman.subj.filetype);
        
        for mm = 1:numel(split_prefix)
            
            data_input.filetype = split_prefix{mm};
            data_input.check_tps_ind = 0;
            [nifti_list, subj_ids] = brant_get_subjs(data_input);
            
            run_data.subjs.filetype = data_input.filetype;
            run_data.subjs.files = nifti_list;
            
            
            % check the timepoints for each subject
            num_niis = brant_check_tps(data_input.is4d, processes_curr{m}, nifti_list, working_dir);
            run_data.(processes_curr{m}).num_tps = num_niis;
            %
            
            fprintf('\n\tCurrent indexing filetype: %s\n', run_data.subjs.filetype);
            
            switch(processes_curr{m})
                case 'denoise'
                    end_prefix = brant_run_denoise(working_dir, run_data.(processes_curr{m}), run_data.subjs.files, subj_ids, data_input.is4d, output_dirs, jobman.subj.out.nmpos);
                otherwise
                    end_prefix = feval(['brant_run_', processes_curr{m}], run_data.(processes_curr{m}), run_data.subjs.files, data_input.is4d, par_on);
                    if strcmpi(processes_curr{m}, 'coregister') == 1
                        end_prefix = '';
                    end
            end
        end
        
        jobman.subj.filetype = [end_prefix, jobman.subj.filetype];
        
        if ~isempty(h_filetype)
            set(h_filetype, 'String', jobman.subj.filetype);
            set(h_fig, 'Userdata', jobman);
        end
    end
    
    fprintf('\n*\tAll finished!\t*\n');
    
    if strcmp(jobman.pref.parallel, 'on')
        try
            curr_pool = gcp('nocreate');
            if ~isempty(curr_pool)
                delete(curr_pool);
            end
        catch
            if (matlabpool('size') ~= 0) %#ok<*DPOOL>
                matlabpool('close');
            end
        end
    end
end
