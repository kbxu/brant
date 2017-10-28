function brant_run_segment(vol_co, mod_inds, varargin)
% do only segment in order to bet, no warping
% mod_inds: [unmodulated_ind, modulated_ind];


% to write inverse and forward deformation
if nargin == 3
    write_opt = varargin{1};
else
    write_opt = [0, 0];
end


spm_path = fileparts(which('spm'));

if isequal(spm('ver'), 'SPM8')
    matlabbatch{1}.spm.tools.preproc8.channel.vols = {[vol_co, ',1']};
    matlabbatch{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
    matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = 60;
    matlabbatch{1}.spm.tools.preproc8.channel.write = [0 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(1).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,1')};
    matlabbatch{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
    matlabbatch{1}.spm.tools.preproc8.tissue(1).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(1).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.tissue(2).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,2')};
    matlabbatch{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
    matlabbatch{1}.spm.tools.preproc8.tissue(2).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(2).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.tissue(3).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,3')};
    matlabbatch{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.tools.preproc8.tissue(3).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(3).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.tissue(4).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,4')};
    matlabbatch{1}.spm.tools.preproc8.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.tools.preproc8.tissue(4).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(4).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.tissue(5).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,5')};
    matlabbatch{1}.spm.tools.preproc8.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.tools.preproc8.tissue(5).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(5).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.tissue(6).tpm = {fullfile(spm_path, 'toolbox', 'Seg', 'TPM.nii,6')};
    matlabbatch{1}.spm.tools.preproc8.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.tools.preproc8.tissue(6).native = [1 0];
    matlabbatch{1}.spm.tools.preproc8.tissue(6).warped = mod_inds;
    matlabbatch{1}.spm.tools.preproc8.warp.mrf = 0;
    matlabbatch{1}.spm.tools.preproc8.warp.reg = 4;
    matlabbatch{1}.spm.tools.preproc8.warp.affreg = 'mni';
    matlabbatch{1}.spm.tools.preproc8.warp.samp = 3;
    matlabbatch{1}.spm.tools.preproc8.warp.write = write_opt;
elseif isequal(spm('ver'), 'SPM12')
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {[vol_co, ',1']};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,1')};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,2')};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,3')};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,4')};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,5')};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spm_path, 'tpm', 'TPM.nii,6')};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = mod_inds;
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = write_opt;
end

spm_jobman('run', matlabbatch);