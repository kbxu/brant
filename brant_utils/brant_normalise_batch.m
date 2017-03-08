function brant_normalise_batch(jobman)
% to normalise individual files into mni space or do inverse deformation

norm_ind = jobman.norm_ind;
fwd_deform_ind = jobman.fwd_deform_ind;
fwd_deform_ft = jobman.fwd_deform_filetypes;
inv_deform_ind = jobman.inv_deform_ind;
inv_deform_file = jobman.inv_deform_file{1};
inv_ref_ft = jobman.inv_deform_ref;
input_nifti_tmp = jobman.input_nifti;

if norm_ind == 1
    
    tpm_file = fullfile(fileparts(which('spm')), 'tpm', 'TPM.nii');
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    num_subj = numel(subj_ids);
    spm('defaults', 'FMRI');
    
    for m = 1:num_subj
        if strcmpi(nifti_list{m}(end-2:end), '.gz')
            tmp_file = gunzip(nifti_list{m});
        else
            tmp_file = '';
        end
        matlabbatch{1}.spm.spatial.normalise.est.subj.vol = {[tmp_file{1}, ',1']};
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm = {tpm_file};
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm = 0;
        matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp = 3;
        
        spm_jobman('run', matlabbatch);
        clear('matlabbatch');
    end    
end

if (fwd_deform_ind == 1) || (inv_deform_ind == 1)
    input_nifti_tmp.filetype = 'y_*.nii';
    deform_file = brant_get_subjs(input_nifti_tmp);
end

if fwd_deform_ind == 1
    split_strs = regexp(fwd_deform_ft, '[;,]', 'split');
    resample_flies = cell(numel(split_strs), 1);
    for mm = 1:numel(split_strs)
        input_nifti_tmp.filetype = split_strs{mm};
        resample_flies{mm} = brant_get_subjs(input_nifti_tmp);
        for m = 1:numel(resample_flies{mm})
            if strcmpi(resample_flies{mm}{m}(end-2:end), '.gz')
                resample_flies{mm}(m) = gunzip(resample_flies{mm}{m});
            end
        end
    end
    
    for m = 1:numel(deform_file)
        tmp_files = cellfun(@(x) [x{m}, ',1'], resample_flies, 'UniformOutput', false);
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = deform_file(m);
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = tmp_files;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72;90 90 108];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3, 3, 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        spm_jobman('run', matlabbatch);
        clear('matlabbatch');
    end
end

if inv_deform_ind == 1
end