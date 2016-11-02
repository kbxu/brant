function brant_spm_est_volume(segfiles, outfn, numTissue)
% segfiles: _seg*.mat generated from new segment
% outfn: output to a csv file. empty means only print on screen.
% number of tissue to be estimated, 1-6


spm_path = fileparts(which('spm'));

if isequal(spm('ver'), 'SPM8')
    warning('SPM8 doesn''t have tissue volume extraction function!');
    return;
else
    icv_mask = fullfile(spm_path, 'tpm', 'mask_ICV.nii,1');
end

matlabbatch{1}.spm.util.tvol.matfiles = segfiles;
matlabbatch{1}.spm.util.tvol.tmax = numTissue;
matlabbatch{1}.spm.util.tvol.mask = {icv_mask};
matlabbatch{1}.spm.util.tvol.outf = outfn;

spm_jobman('run', matlabbatch);
