function brant_fgn(jobman)

tc_pts = jobman.timepoint;
[pL, pR, H0, alpha] = brant_truncated_alpha(jobman.timepoints);

mask_nii = load_nii(mask_fn);
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_hdr = mask_nii.hdr;
mask_ind = find(mask_nii.img > 0.5);
% [mask_x, mask_y, mask_z] = ind2sub(size_mask, mask_ind);

outdir = jobman.out_dir{1};
out_hurst = '';
out_sigma = '';
nor_ind = jobman.nor;
warning('off', 'MATLAB:MKDIR:DirectoryExists');
% mkdir(outdir);
out_Hurst_raw = fullfile(outdir, 'fGn_Hurst_raw');
out_Sigma_raw = fullfile(outdir, 'fGn_Sigma_raw');
mkdir(out_Hurst_raw);
mkdir(out_Sigma_raw);
if jobman.nor == 1
    out_hurst_m = fullfile(outdir, 'Hurst_Normalised_m');
    out_sigma_m = fullfile(outdir, 'Sigma_Normalised_m');
    mkdir(out_hurst_m);
    mkdir(out_sigma_m);
end

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
subj_tps = zeros(numel(subj_ids), 1);

num_subj = numel(subj_ids);
for m = 1:num_subj
    tic
    [data_2d_mat, data_tps, mask_ind_new] = brant_4D_to_mat(nifti_list{m}, size_mask, mask_ind, 'cell', subj_ids{m});
    fprintf('\n\tCalculating the Hurst exponentof the whole brain for subject %d/%d %s...\n', m, num_subj, subj_ids{m});
    
    subj_tps(m) = data_tps;
    Hurst = zeros(size_mask, 'single');
    Sigma = zeros(size_mask, 'single');
        
    f_good_ind = cellfun(@(x) sum(abs(x)) > 1, data_2d_mat);    
    
    ind = cellfun(@brant_mpe_index, data_2d_mat(f_good_ind));
    [H, sigma, sf] = arrayfun(@(x, y) brant_mpe(x{1}, data_tps, pL, pR, H0, alpha, 1, y), data_2d_mat(f_good_ind), ind);
    Hurst(mask_ind_new(f_good_ind)) = H;
    Sigma(mask_ind_new(f_good_ind)) = sigma;
            
    brant_write_nii(Hurst, mask_ind_new, mask_hdr, subj_ids{m}, 'Hurst', out_Hurst_raw, nor_ind, 0, {out_hurst_m, ''});
    brant_write_nii(Sigma, mask_ind_new, mask_hdr, subj_ids{m}, 'Sigma', out_Sigma_raw, nor_ind, 0, {out_sigma_m, ''});
            
    fprintf('\t');
    toc
    fprintf('\tSubject %s finished...\n\n', subj_ids{m});
end
fprintf('\n\tFinished!\n');

if any(tc_pts ~= subj_tps)
    warning([sprintf('Timepoints that don''t match with the input timepoint!\n'),...
             sprintf('%s\n', subj_ids{tc_pts ~= subj_tps})]);
end
