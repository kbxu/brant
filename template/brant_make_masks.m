function brant_make_masks

cd(fileparts(which(mfilename)));

% should be spm2012
spm_path = fileparts(which('spm'));
tpm_file = fullfile(spm_path, 'tpm', 'TPM.nii');

tpm_vol = spm_vol(tpm_file);

make_wm = 1;
make_csf = 0;
make_gm = 0;

% white matter mask
if (make_wm == 1)
    wm_vol = tpm_vol(2);
    wm_data = spm_read_vols(wm_vol);
    wm_data_mask = wm_data > 0.95;
    wm_data(~wm_data_mask) = 0;
%     wm_vol.n(1) = 1;
%     wm_vol.fname = 'tpm_mask_wm_95.nii';
%     spm_write_vol(wm_vol, wm_data);

    % remove white matter in sub-cortical structures,
    % rJHU-WhiteMatter-labels-1mm.nii has been resliced to tpm.nii
    wm_mask_vol = spm_vol('rJHU-WhiteMatter-labels-1mm.nii');
    wm_mask_data = spm_read_vols(wm_mask_vol);
    wm_mask_bin = wm_mask_data > 0 & wm_mask_data <= 22;

    % raal.nii has been resliced to tpm.nii
    wm_mask_vol2 = spm_vol('raal.nii');
    wm_mask_data2 = spm_read_vols(wm_mask_vol2);
    wm_mask_bin2 = wm_mask_data2 ~= 0;

    %
    wm_tmp = wm_data;
    wm_tmp(wm_mask_bin | wm_mask_bin2) = 0;

    % erode to extract white matter backbones
    N_nbr = 1;
    [xx,yy,zz] = ndgrid(-1 * N_nbr:N_nbr);
    nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= N_nbr;
    wm_tmp_2 = imerode(wm_tmp, nhood);

    wm_tmp_3 = brant_thres_clustersize(wm_tmp_2, 20);

    wm_vol.n(1) = 1;
    wm_vol.fname = 'mask_WM.nii';
    spm_write_vol(wm_vol, single(wm_tmp_3 > 0.5));
end


% CSF mask
if (make_csf == 1)
    csf_vol = tpm_vol(3);
    csf_data = spm_read_vols(csf_vol);
    csf_data_mask = csf_data > 0.95;
    csf_data(~csf_data_mask) = 0;
    csf_vol.n(1) = 1;
    csf_vol.fname = 'mask_csf_95.nii';
    spm_write_vol(csf_vol, csf_data);
    
    % select clusters from xjview
end

% use GM masks in spm12_masks folder
% gray matter mask
if (make_gm == 1)
    gm_vol = tpm_vol(1);
    gm_data = spm_read_vols(gm_vol);
    gm_data = gm_data > 0.4;
    gm_vol.n(1) = 1;
    gm_vol.fname = 'mask_gm_40.nii';
    spm_write_vol(gm_vol, double(gm_data));
    
    % select clusters from xjview
end
