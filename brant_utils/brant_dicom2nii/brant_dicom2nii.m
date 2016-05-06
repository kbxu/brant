function brant_dicom2nii(jobman)

outdir = jobman.out_dir{1};
par_workers = jobman.par_workers;

if jobman.smri == 1
    cvt_mode = '-4 N';
else
    cvt4d = jobman.cvt4d;
    tps_check = jobman.timepoint;
    del_tps = jobman.del;
    if cvt4d == 1, cvt_mode = '-4 Y'; else cvt_mode = '-4 N'; end
end

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
[dicom_dirs, subj_ids] = brant_get_subjs(jobman.input_nifti);
outdirs_subj = cellfun(@(x) fullfile(outdir, x), subj_ids, 'UniformOutput', false);
cellfun(@mkdir, outdirs_subj);

if jobman.fmri == 1
    fid = fopen(fullfile(outdir, 'brant_preprocess_paths.txt'), 'wt');
    cellfun(@(x) fprintf(fid, '%s\n', x), outdirs_subj);
    fclose(fid);
end

command_strs = cellfun(@(x, y) ['"', dcm2nii_dir, '"', 32, '-b', 32,...
                                '"', [dcm2nii_path, filesep, 'dcm2nii.ini'], '"', 32,...
                                '-d Y -e Y -n Y -c Y -g N', 32, cvt_mode, 32,...
                                '-o', 32, '"', y, '"', 32, '"', x, '"'],...
                                dicom_dirs, outdirs_subj, 'UniformOutput', false);

if par_workers > 0
    par_sts = 1;
    brant_parpool('open', par_workers);
%     matlabpool('on', par_workers);
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
%     matlabpool('close');
end

if jobman.fmri == 1 && del_tps > 0
    jobman.input_nifti.dirs = outdirs_subj;
    jobman.input_nifti.filetype = '*.nii';
    jobman.input_nifti.nm_pos = 1;
    
    jobman.input_nifti.is4d = cvt4d;
    nifti_list = brant_get_subjs(jobman.input_nifti);
    
    nifti_tps = cellfun(@get_nii_frame, nifti_list);
    warning('on'); %#ok<WNON>
    if tps_check > 0
        if any(nifti_tps ~= tps_check)
            warning([sprintf('Listed files has a different timepoint, please check your data!\n'),...
                     sprintf('\t%s\n', nifti_list{nifti_tps ~= tps_check})]);
        end
    end
    
    for m = 1:num_subj
        if (nifti_tps(m) > del_tps && tps_check <= 0) || (nifti_tps(m) == tps_check && tps_check > 0)
            fprintf('Deleting first %d timepoints for data %s\n', del_tps, nifti_list{m});
            nifti_tmp = load_untouch_nii(nifti_list{m}, del_tps + 1:nifti_tps(m));
            save_untouch_nii(nifti_tmp, fullfile(outdirs_subj{m}, 'brant_4D.nii'));
        else
            warning('First %d timepoints will not be discarded for %s, please check!\n', del_tps, nifti_list{m});
        end        
    end
end

fprintf('Finished.\n');
