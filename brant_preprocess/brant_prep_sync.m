function data_fig = brant_prep_sync(brant_preps, prep_type)

brant_path = fileparts(which('brant'));
switch(prep_type)
    case 'slicetiming'
        brant_preps.denoise.filter.tr = brant_preps.slicetiming.tr;
    case 'coregister'
        brant_preps.normalise.subj.filetype_src = [brant_preps.coregister.roptions.prefix, brant_preps.coregister.subj.filetype_src];
    case 'denoise'
%         brant_preps.normalise.roptions.vox = brant_preps.denoise.subj.voxelsize;
    case 'normalise'
%         brant_preps.denoise.subj.voxelsize = brant_preps.normalise.roptions.vox;
        
%         vox_size = brant_preps.denoise.subj.voxelsize;
%         if all(vox_size == vox_size(1))
%             
%             wb_tmp = fullfile(brant_path, 'template', num2str(vox_size(1), 'fmaskEPI_V%dmm.nii'));
%             wm_tmp = fullfile(brant_path, 'template', num2str(vox_size(1), 'fmaskEPI_V%dmm_WM.nii'));
%             csf_tmp = fullfile(brant_path, 'template', num2str(vox_size(1), 'fmaskEPI_V%dmm_CSF.nii'));
%             
%             if exist(wb_tmp, 'file') == 2
%                 brant_preps.denoise.subj.wb_mask = wb_tmp;
%                 brant_preps.denoise.detrend_mask.gs = wb_tmp;
%             else
%                 warning(sprintf('Default mask not found in brant path!\n%s', wb_tmp))
%             end
%             
%             if exist(wm_tmp, 'file') == 2
%                 brant_preps.denoise.detrend_mask.wm = wm_tmp;
%             else
%                 warning(sprintf('Default mask not found in brant path!\n%s', wm_tmp))
%             end
%             
%             if exist(csf_tmp, 'file') == 2
%                 brant_preps.denoise.detrend_mask.csf = csf_tmp;
%             else
%                 warning(sprintf('Default mask not found in brant path!\n%s', csf_tmp))
%             end
%         end
    case 'initial'
        fprintf('Parameters were set to reference values in\nslicetiming (TR), normalise (voxel size), denoise(timepoints, wholebrain mask)');
        brant_preps.denoise.filter.tr = brant_preps.slicetiming.tr;
%         brant_preps.denoise.subj.voxelsize = brant_preps.normalise.roptions.vox;
end

data_fig = brant_preps;
