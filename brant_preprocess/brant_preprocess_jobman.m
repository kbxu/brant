function brant_preprocess_jobman(jobman, h_filetype, h_fig)

process_ind = cellfun(@(x) jobman.ind.(x), jobman.pref.order);

if any(process_ind)
    processes_curr = jobman.pref.order(process_ind > 0.5);
    %     run_data = brant_prep_run(jobman, processes_curr);
    for m = 1:numel(processes_curr)
        run_data.(processes_curr{m}) = jobman.(processes_curr{m});
    end
    %     run_data = jobmna.
    
    if jobman.pref.dirs_in_text == 1
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
    
    if jobman.subj.out.selected == 1
        
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
            if exist(output_dirs{m}, 'dir') ~= 7
                mkdir(output_dirs{m});
                fprintf('Copy %s to %s.\n', nifti_list_tmp{m}, output_dirs{m});
                copyfile(nifti_list_tmp{m}, output_dirs{m});
            end
        end
        if all(cellfun(@exist, nifti_list_tmp_mat))
            for m = 1:numel(output_dirs)
                fprintf('Copy %s to %s.\n', nifti_list_tmp_mat{m}, output_dirs{m});
                copyfile(nifti_list_tmp_mat{m}, output_dirs{m});
            end
        end
        
        if ismember('realign', processes_curr) == 0
            if any(strcmpi(processes_curr, 'denoise'))
                if all(cellfun(@exist, nifti_list_rp))
                    cellfun(@copyfile, nifti_list_rp, output_dirs);
                end
            end
            
            % copy mean*.nii files for normalise
            if any(strcmpi(processes_curr, 'normalise')) || any(strcmpi(processes_curr, 'normalise12'))
                if all(cellfun(@exist, nifti_list_mean))
                    fprintf('Copying source files...\n');
                    cellfun(@copyfile, nifti_list_mean, output_dirs);
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
            if matlabpool('size') == 0
                matlabpool('open', jobman.pref.parallel_workers);
            end
        end
    else
        par_on = 0;
    end
    
    data_input.dirs = dirs;
    data_input.nm_pos = jobman.subj.out.nmpos;
    data_input.is4d = jobman.subj.is4d;
    if jobman.subj.out.selected == 1
        data_input.dirs = output_dirs;
    end
    
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
                    
                    % reslice masks to the first data's first timepoint
                    if run_data.denoise.subj.reslice_mask_ind == 1
                        mask_all{1, 1} = run_data.denoise.subj.wb_mask;
                        mask_all{2, 1} = run_data.denoise.detrend_mask.gs;
                        mask_all{3, 1} = run_data.denoise.detrend_mask.wm;
                        mask_all{4, 1} = run_data.denoise.detrend_mask.csf;
                        mask_all{5, 1} = run_data.denoise.detrend_mask.user_mask;
                        
                        mask_all_ept = cellfun(@isempty, mask_all);
                        mask_all_uni = unique(mask_all(~mask_all_ept));
                        check_mask_ext = cellfun(@(x) exist(x, 'file') ~= 2, mask_all_uni);
                        if any(check_mask_ext)
                            error([sprintf('Mask not exist:\n'), sprintf('%s\n', mask_all_uni{check_mask_ext})]);
                        end
                        
                        mask_all_uni_new = cell(size(mask_all_uni));
                        for n = 1:numel(mask_all_uni)
                            if ~isempty(mask_all_uni{n})
                                [path_tmp, fn_tmp, ext] = fileparts(mask_all_uni{n}); %#ok<*ASGLU>
                                
                                mask_all_uni_new{n} = fullfile(working_dir, [fn_tmp, ext]);
                                
                                if exist(mask_all_uni_new{n}, 'file') ~= 2
                                    copyfile(mask_all_uni{n}, working_dir);
                                end
                            end
                        end
                        
                        load_hdr_func = @load_nii_hdr_img_raw_c; % support nii, nii.gz, img, img.gz, hdr, hdr.gz
                        mask_all_uni_new_hdr = cellfun(@load_nii_hdr_img_raw_c, mask_all_uni_new);
                        
                        if data_input.is4d == 1
                            sample_file = run_data.subjs.files{1};
                        else
                            sample_file = run_data.subjs.files{1}{1};
                        end
                        
                        data_sample_hdr = load_hdr_func(sample_file);
                        sts = brant_spm_check_orientations([mask_all_uni_new_hdr; data_sample_hdr]);
                        
                        % reslice if mask's size doesn't match with data
                        if sts == 0
                            img_size_str = sprintf('r%d%d%dmm_', data_sample_hdr.dime.pixdim(2:4));

                            mask_all_new = cell(size(mask_all));
                            for n = 1:numel(mask_all)
                                if ~isempty(mask_all{n})
                                    [path_tmp, fn_tmp, ext] = fileparts(mask_all{n});
                                    mask_all_new{n} = fullfile(working_dir, [fn_tmp, ext]);
                                end
                            end

                            mask_all_new_resliced = brant_reslice(sample_file, mask_all_new, img_size_str);
                            
                            run_data.denoise.subj.wb_mask = mask_all_new_resliced{1, 1};
                            run_data.denoise.detrend_mask.gs = mask_all_new_resliced{2, 1};
                            run_data.denoise.detrend_mask.wm = mask_all_new_resliced{3, 1};
                            run_data.denoise.detrend_mask.csf = mask_all_new_resliced{4, 1};
                            run_data.denoise.detrend_mask.user_mask = mask_all_new_resliced{5, 1};
                        end
                    end
                    
                    jobman.(processes_curr{m}) = run_data.(processes_curr{m});
                    end_prefix = brant_run_denoise_filter(run_data.(processes_curr{m}), run_data.subjs.files, subj_ids, data_input.is4d, output_dirs);
                case 'coregister'
                    end_prefix = '';
                    feval(['brant_run_', processes_curr{m}], run_data.(processes_curr{m}), run_data.subjs.files, data_input.is4d, par_on);
                otherwise
                    end_prefix = feval(['brant_run_', processes_curr{m}], run_data.(processes_curr{m}), run_data.subjs.files, data_input.is4d, par_on);
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
            if matlabpool('size') ~= 0 %#ok<*DPOOL>
                matlabpool('close');
            end
        end
    end
end
