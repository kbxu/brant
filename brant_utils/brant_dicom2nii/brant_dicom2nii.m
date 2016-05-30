function brant_dicom2nii(jobman)



if isfield(jobman, 'input_dcm')
    
    outdir = jobman.out_dir{1};
    par_workers = jobman.par_workers;
    if jobman.cvt4d == 1
        cvt_mode = '-4 Y';
    else
        cvt_mode = '-4 N';
    end

    del_tps = jobman.del;
    if isempty(outdir)
        error('Output directory is empty!');
    end

    brant_path = fileparts(which('brant'));
    dcm2nii_path = [brant_path, filesep, 'brant_utils', filesep, 'brant_dicom2nii'];
    switch(computer)
        case {'PCWIN', 'PCWIN64'}
            dcm2nii_dir = fullfile(dcm2nii_path, 'dcm2nii.exe');
        case 'MACI64'
            dcm2nii_dir = fullfile(dcm2nii_path, 'dcm2nii.mac');
            system(['chmod a+x', 32, dcm2nii_dir]);
        case {'GLNX86', 'GLNXA64'}
            dcm2nii_dir = fullfile(dcm2nii_path, 'dcm2nii.unix');
            system(['chmod a+x', 32, dcm2nii_dir]);
        otherwise
            error('Unknown operation system!');
    end

    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    [dicom_dirs, subj_ids] = brant_get_subjs(jobman.input_dcm);
    outdirs_subj = cellfun(@(x) fullfile(outdir, x), subj_ids, 'UniformOutput', false);
    cellfun(@mkdir, outdirs_subj);

    fid = fopen(fullfile(outdir, 'brant_preprocess_paths.txt'), 'wt');
    cellfun(@(x) fprintf(fid, '%s\n', x), outdirs_subj);
    fclose(fid);

    command_strs = cellfun(@(x, y) ['"', dcm2nii_dir, '"', 32, '-b', 32,...
                                    '"', [dcm2nii_path, filesep, 'dcm2nii.ini'], '"', 32,...
                                    '-d Y -e Y -n Y -c Y -g N', 32, cvt_mode, 32,...
                                    '-o', 32, '"', y, '"', 32, '"', x, '"'],...
                                    dicom_dirs, outdirs_subj, 'UniformOutput', false);

    if par_workers > 0
        par_sts = 1;
        brant_parpool('open', par_workers);
    else
        par_sts = 0;
    end

    num_subj = numel(subj_ids);
    if par_sts == 1
        parfor m = 1:num_subj
            system(command_strs{m});
        end
    else
        cellfun(@system, command_strs);
    end

    if par_workers > 0
        brant_parpool('close');
    end
else
    % delete timepoint settings
    jobman.del_ind = 1;
    del_tps = jobman.del;
    
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    num_subj = numel(subj_ids);
    if jobman.out_ind == 1
        outdir = jobman.out_dir{1};
        outdirs_subj = cellfun(@(x) fullfile(outdir, x), subj_ids, 'UniformOutput', false);
    else
        if jobman.input_nifti.is4d == 1
            outdirs_subj = cellfun(@fileparts, nifti_list, 'UniformOutput', false);
        else
            outdirs_subj = cellfun(@(x) fileparts(x{1}), nifti_list, 'UniformOutput', false);
        end
    end
    
    is4d_ind = jobman.input_nifti.is4d;
    out_fn = jobman.out_fn;
end

if jobman.del_ind == 1 && del_tps > 0
    if isfield(jobman, 'input_dcm')
        jobman.input_dcm.dirs = outdirs_subj;
        jobman.input_dcm.filetype = jobman.filetype;
        jobman.input_dcm.nm_pos = 1;

        jobman.input_dcm.is4d = jobman.cvt4d;
        nifti_list = brant_get_subjs(jobman.input_dcm);
        out_fn = 'brant_4D';
        
        is4d_ind = jobman.input_dcm.is4d;
    end
    
    if is4d_ind == 1
        nifti_tps = cellfun(@get_nii_frame, nifti_list);
        
        for m = 1:num_subj
            if nifti_tps(m) > del_tps
                fprintf('\tDeleting first %d timepoints for data %s\n', del_tps, nifti_list{m});
                nifti_tmp = load_untouch_nii(nifti_list{m}, del_tps + 1:nifti_tps(m));
                save_untouch_nii(nifti_tmp, fullfile(outdirs_subj{m}, [out_fn, '.nii']));
            else
                warning('First %d timepoints will not be discarded for %s, please check!\n', del_tps, nifti_list{m});
            end        
        end
    else
        nifti_tps = cellfun(@numel, nifti_list);
        
        for m = 1:num_subj
            if nifti_tps(m) > del_tps
                for n = (del_tps + 1):nifti_tps(m)
                    copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n - del_tps, '_%04d'), '.nii']))
                end
            else
                warning('First %d timepoints will not be discarded for %s, please check!\n', del_tps, nifti_list{m});
            end   
        end
    end
    
%     warning('on'); %#ok<WNON>
%     if tps_check > 0
%         if any(nifti_tps ~= tps_check)
%             warning([sprintf('Listed files has a different timepoint, please check your data!\n'),...
%                      sprintf('\t%s\n', nifti_list{nifti_tps ~= tps_check})]);
%         end
%     end
end

fprintf('\tFinished.\n');
