function brant_dicom2nii(jobman)

if (jobman.convert == 1)
    convert_ind = jobman.convert;
    par_workers = jobman.par_workers_cvt;
    is4d_ind = jobman.cvt4d_cvt;
    input_dcm_cvt = jobman.input_dcm_cvt;
    delete_ind = jobman.del_ind_cvt;
    del_tps = jobman.del_N_cvt;
    filetype_cvt = jobman.filetype_cvt;
    outdir = jobman.out_dir_cvt{1};
    out_fn = 'brant_4D';
else
    delete_ind = jobman.delete;
    convert_ind = jobman.convert;
    input_nifti_del = jobman.input_nifti_del;
    is4d_ind = input_nifti_del.is4d;
    del_tps = jobman.del_N_del;
    out_fn = jobman.out_fn_del;
    out_ind_del = jobman.out_ind_del;
    outdir = jobman.out_dir_del{1};
end

if (convert_ind == 1)
    
    if (is4d_ind == 1)
        cvt_mode = '-4 Y';
    else
        cvt_mode = '-4 N';
    end

    if isempty(outdir)
        error('Output directory is empty!');
    end

    brant_path = fileparts(which('brant'));
    dcm2nii_path = [brant_path, filesep, 'brant_utils', filesep, 'brant_dicom2nii'];
    switch(computer)
        case {'PCWIN', 'PCWIN64'}
            dcm2nii_full = fullfile(dcm2nii_path, 'dcm2nii.exe');
        case 'MACI64'
            dcm2nii_full = fullfile(dcm2nii_path, 'dcm2nii.mac');
            system(['chmod a+x', 32, dcm2nii_full]);
        case {'GLNX86', 'GLNXA64'}
            dcm2nii_full = fullfile(dcm2nii_path, 'dcm2nii.unix');
            system(['chmod a+x', 32, dcm2nii_full]);
        otherwise
            error('Unknown operation system!');
    end

    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    [dicom_dirs, subj_ids] = brant_get_subjs(input_dcm_cvt);
    outdirs_subj = cellfun(@(x) fullfile(outdir, x), subj_ids, 'UniformOutput', false);
    cellfun(@mkdir, outdirs_subj);

    fid = fopen(fullfile(outdir, 'brant_preprocess_paths.txt'), 'wt');
    cellfun(@(x) fprintf(fid, '%s\n', x), outdirs_subj);
    fclose(fid);

    command_strs = cellfun(@(x, y) ['"', dcm2nii_full, '"', 32, '-b', 32,...
                                    '"', [dcm2nii_path, filesep, 'dcm2nii.ini'], '"', 32,...
                                    '-d Y -e Y -n Y -c Y -g N', 32, cvt_mode, 32,...
                                    '-o', 32, '"', y, '"', 32, '"', x, '"'],...
                                    dicom_dirs, outdirs_subj, 'UniformOutput', false);

    if (par_workers > 0)
        par_sts = 1;
        brant_parpool('open', par_workers);
    else
        par_sts = 0;
    end

    num_subj = numel(subj_ids);
    if (par_sts == 1)
        parfor m = 1:num_subj
            system(command_strs{m});
        end
    else
        cellfun(@system, command_strs);
    end

    if (par_workers > 0)
        brant_parpool('close');
    end
    
    % files to delete the first N timepoints
    output_cvt.dirs = outdirs_subj;
    output_cvt.filetype = filetype_cvt;
    output_cvt.nm_pos = 1;
    output_cvt.is4d = is4d_ind;
else
    % delete timepoint settings
    [nifti_list, subj_ids] = brant_get_subjs(input_nifti_del);
    num_subj = numel(subj_ids);
    if (out_ind_del == 1)
        outdirs_subj = cellfun(@(x) fullfile(outdir, x), subj_ids, 'UniformOutput', false);
    else
        if (is4d_ind == 1)
            outdirs_subj = cellfun(@fileparts, nifti_list, 'UniformOutput', false);
        else
            outdirs_subj = cellfun(@(x) fileparts(x{1}), nifti_list, 'UniformOutput', false);
        end
    end
end

if ((delete_ind == 1) && (del_tps > 0))
    if (convert_ind == 1)
        nifti_list = brant_get_subjs(output_cvt);
    end
    if (is4d_ind == 1)
        nifti_tps = cellfun(@brant_get_nii_frame, nifti_list);
        for m = 1:num_subj
            if (nifti_tps(m) > del_tps)
                fprintf('\tDeleting first %d timepoints for data %s\n', del_tps, nifti_list{m});
                nifti_tmp = load_untouch_nii_mod(nifti_list{m}, del_tps + 1:nifti_tps(m));
                save_untouch_nii(nifti_tmp, fullfile(outdirs_subj{m}, [out_fn, '.nii']));
            else
                warning('First %d timepoints will not be discarded for %s, please check!\n', del_tps, nifti_list{m});
            end
        end
    else
        nifti_tps = cellfun(@numel, nifti_list);
        for m = 1:num_subj
            if (nifti_tps(m) > del_tps)
                for n = (del_tps + 1):nifti_tps(m)
                    if strcmpi(nifti_list{m}{n}(end-2:end), 'nii')
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.nii']));
                    elseif strcmpi(nifti_list{m}{n}(end-5:end), 'nii.gz')
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.nii.gz']));
                    elseif strcmpi(nifti_list{m}{n}(end-5:end), 'hdr.gz')
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.hdr.gz']));
                        copyfile([nifti_list{m}{n}(1:end-6), 'img.gz'], fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.img.gz']));
                    elseif strcmpi(nifti_list{m}{n}(end-5:end), 'img.gz')
                        copyfile([nifti_list{m}{n}(1:end-6), 'hdr.gz'], fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.hdr.gz']));
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.img.gz']));
                    elseif strcmpi(nifti_list{m}{n}(end-2:end), 'hdr')
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.hdr']));
                        copyfile([nifti_list{m}{n}(1:end-3), 'img'], fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.img']));
                    elseif strcmpi(nifti_list{m}{n}(end-2:end), 'img')
                        copyfile([nifti_list{m}{n}(1:end-3), 'hdr'], fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.hdr']));
                        copyfile(nifti_list{m}{n}, fullfile(outdirs_subj{m}, [out_fn, num2str(n, '_%04d'), '.img']));
                    else
                        error('Unknown filetype!');
                    end
                end
            else
                warning('First %d timepoints will not be discarded for %s, please check!\n', del_tps, nifti_list{m});
            end   
        end
    end
else
    warning('No timepoints will be deleted!\n');
end

fprintf('\tFinished.\n');
