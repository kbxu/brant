function brant_dwi_batch(jobman)
% batch for Diffusion Toolkit

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
dk_dir = jobman.dk_dir{1};

eddy_ind = jobman.eddy_ind;
recon_dti_ind = jobman.recon_dti_ind;
bet2_ind = eddy_ind;
% recon_hardi_ind = jobman.recon_hardi_ind;
DTI_trk_ind = jobman.DTI_trk_ind;
hardi_odf_ind = jobman.hardi_odf_ind;
hardi_fod_ind = jobman.hardi_fod_ind;

% filetype is used to parse raw DWI file, bval and bvec.
[data_pth, fns, ext] = cellfun(@brant_fileparts, nifti_list, 'UniformOutput', false);
bvals = cellfun(@(x, y) fullfile(x, [y, '.bval']), data_pth, fns, 'UniformOutput', false);
bvecs = cellfun(@(x, y) fullfile(x, [y, '.bvec']), data_pth, fns, 'UniformOutput', false);

DWI_fn = cellfun(@(x, y) [x, y], fns, ext, 'UniformOutput', false);
bvals_fn = cellfun(@(x) [x, '.bval'], fns, 'UniformOutput', false);
bvecs_fn = cellfun(@(x) [x, '.bvec'], fns, 'UniformOutput', false);

% check existance of bval and bvec files
bvals_est = cellfun(@(x) exist(x, 'file') == 2, bvals);
bvecs_est = cellfun(@(x) exist(x, 'file') == 2, bvecs);
if ~all(bvals_est)
    sprintf('%s\n', bvals{bvals_est == 0});
    error('Missing above files!');
end
if ~all(bvecs_est)
    sprintf('%s\n', bvecs{bvecs_est == 0});
    error('Missing above files!');
end

num_subj = numel(subj_ids);
parallel_ind = 0;
if parallel_ind == 1
    parfor m = 1:num_subj
        dwi_parallel(dk_dir, m, num_subj, data_pth{m}, subj_ids{m}, DWI_fn{m}, bvals_fn{m}, bvecs_fn{m}, eddy_ind, bet2_ind, recon_dti_ind, DTI_trk_ind, hardi_odf_ind, hardi_fod_ind);
    end
else
    for m = 1:num_subj
        dwi_parallel(dk_dir, m, num_subj, data_pth{m}, subj_ids{m}, DWI_fn{m}, bvals_fn{m}, bvecs_fn{m}, eddy_ind, bet2_ind, recon_dti_ind, DTI_trk_ind, hardi_odf_ind, hardi_fod_ind);
    end
end

function dwi_parallel(dk_dir, m, num_subj, data_pth, subj_ids, DWI_fn, bvals_fn, bvecs_fn, eddy_ind, bet2_ind, recon_dti_ind, DTI_trk_ind, hardi_odf_ind, hardi_fod_ind)

% input filenames are fixed
eddy_out_fn = 'DWI_eddy.nii.gz';
DWI_brain_out_fn = 'DWI_eddy_brain.nii.gz';
DWI_mask_out_fn = 'DWI_eddy_mask.nii.gz';
DTI_recon_out_fn = 'DTI_eddy_dti.nii.gz';
DTI_tensor_out_fn = 'DTI_eddy_dti_tensor.nii.gz';
DTI_FA_out_fn = 'DTI_eddy_dti_FA.nii.gz';
DTI_trk_out_fn = 'DTI_eddy_mask.trk';
HARDI_ODF_out_fn = 'HARDI_eddy_odf';
HARDI_FOD_out_fn = 'HARDI_eddy_fod';

fprintf('\tCalculating DWI metrics for subject %d/%d %s...\n', m, num_subj, subj_ids);
cd(data_pth); % could save a lot characters in script

% eddy correction at first
if eddy_ind == 1
    fprintf('\tDoing eddy correction...\n');
    system(sprintf('"%s" -i "%s" -o "%s" -ref 0 -omp 2', fullfile(dk_dir, 'bneddy'), DWI_fn, eddy_out_fn));
end

% skull stripping
if bet2_ind == 1
    fprintf('\tBetting to get a DWI mask...\n');
    system(sprintf('"%s" "%s" "%s" -m "%s" -f 0.5', fullfile(dk_dir, 'bet2'), eddy_out_fn, DWI_brain_out_fn, DWI_mask_out_fn));
end

% reconstruction using DTI
if recon_dti_ind == 1
    fprintf('\tDoing reconstruction using DTI...\n');
    system(sprintf('"%s" -d "%s" -b "%s" -g "%s" -m "%s" -o "%s" -tensor 1 -eig 1',...
                   fullfile(dk_dir, 'bndti_estimate'), eddy_out_fn, bvals_fn, bvecs_fn, DWI_mask_out_fn, DTI_recon_out_fn));
end

% tracking using DTI
if DTI_trk_ind == 1
    fprintf('\tTracking using DTI...\n');
    system(sprintf('"%s" -d "%s" -m "%s" -s "%s" -fa "%s" -ft 0.1 -at 45 -sl 0.5 -min 10 -max 5000 -o "%s"',...
                   fullfile(dk_dir, 'bndti_tracking'), DTI_tensor_out_fn, DWI_mask_out_fn, DWI_mask_out_fn, DTI_FA_out_fn, DTI_trk_out_fn));
end

% estimate HARDI using ODF method
if hardi_odf_ind == 1
    fprintf('\tHARDI ODF...\n');
    system(sprintf('"%s" -d "%s" -b "%s" -g "%s" -m "%s" -o "%s" -outGFA 1 -tau 0.02533 -sh 4 -ra 1 -lambda_sh 0 -lambda_ra 0 -rdis 0.015',...
                   fullfile(dk_dir, 'bnhardi_ODF_estimate'), eddy_out_fn, bvals_fn, bvecs_fn, DWI_mask_out_fn, HARDI_ODF_out_fn));
end

% estimate HARDI using FOD method
if hardi_fod_ind == 1
    fprintf('\tHARDI FOD...\n');
    system(sprintf('"%s" -d "%s" -b "%s" -g "%s" -m "%s" -o "%s" -outFA 1 -lmax 8 -fa [0.75,0.95] -nIter 50 -lambda 1 -tau 0.1 -hr 300',...
                   fullfile(dk_dir, 'bnhardi_FOD_estimate'), eddy_out_fn, bvals_fn, bvecs_fn, DWI_mask_out_fn, HARDI_FOD_out_fn));
end