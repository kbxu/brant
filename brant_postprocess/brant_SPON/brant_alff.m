function brant_alff(jobman)


FS = 1 / jobman.tr;
BP = [jobman.lower_thr, jobman.higher_thr];

tc_pts = jobman.timepoint;
nor_z_ind = jobman.nor;

outdir = jobman.out_dir{1};

warning('off', 'MATLAB:MKDIR:DirectoryExists');
outdir_alff = fullfile(outdir, 'ALFF_raw');
outdir_falff = fullfile(outdir, 'fALFF_raw');
if exist(outdir_alff, 'dir') ~= 7, mkdir(outdir_alff); end
if exist(outdir_falff, 'dir') ~= 7, mkdir(outdir_falff); end

nor_m_ind = 0;
if nor_m_ind == 1
    out_nor_ALFF_m = fullfile(outdir, 'ALFF_Normalized_m');
    out_nor_fALFF_m = fullfile(outdir, 'fALFF_Normalized_m');
    if exist(out_nor_ALFF_m, 'dir') ~= 7, mkdir(out_nor_ALFF_m); end
    if exist(out_nor_fALFF_m, 'dir') ~= 7, mkdir(out_nor_fALFF_m); end
else
    out_nor_ALFF_m = '';
    out_nor_fALFF_m = '';
end

if nor_z_ind == 1
    out_nor_ALFF_z = fullfile(outdir, 'ALFF_Normalized_z');
    out_nor_fALFF_z = fullfile(outdir, 'fALFF_Normalized_z');
    if exist(out_nor_ALFF_z, 'dir') ~= 7, mkdir(out_nor_ALFF_z); end
    if exist(out_nor_fALFF_z, 'dir') ~= 7, mkdir(out_nor_fALFF_z); end
else
    out_nor_ALFF_z = '';
    out_nor_fALFF_z = '';
end

mask_fn = jobman.mask{1};
mask_nii = load_nii(mask_fn);
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_hdr = mask_nii.hdr;
mask_ind = find(mask_nii.img > 0.5);

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
subj_tps = zeros(numel(subj_ids), 1);

num_subj = numel(subj_ids);
for m = 1:num_subj
    tic;    
    
    [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});
    brant_spm_check_orientations([mask_hdr, nii_hdr]);
    
%     [data_2d_mat, data_tps, mask_ind_new] = brant_4D_to_mat(nifti_list{m}, size_mask, mask_ind, 'mat', subj_ids{m});
    fprintf('\tCalculating ALFF/fALFF for subject %d/%d %s please wait ...\n', m, num_subj, subj_ids{m});

    subj_tps(m) = data_tps;
    L = data_tps;
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    f = FS / 2 * linspace(0 , 1, NFFT / 2 + 1);
    f_mask_bp = [f >= BP(1) & f <= BP(2), false(1, NFFT / 2 - 1)];
%     f_mask_bp(1) = false;
    
    Y = 2 * fft(data_2d_mat, NFFT, 1) / L;
    clear('data_2d_mat');
    
    ALFF_BP_sum = nan(size_mask, 'single');
    ALFF_BP_sum(mask_ind) = sum(abs(Y(f_mask_bp, :)), 1);
    ALFF_BP_sum(ALFF_BP_sum < 0) = NaN;
    
    f_mask_all = [true(1, NFFT / 2 + 1), false(1, NFFT / 2 - 1)];
    ALFF_AP_sum = nan(size_mask, 'single');
    ALFF_AP_sum(mask_ind) = sum(abs(Y(f_mask_all, :)), 1);
    ALFF_AP_sum(ALFF_AP_sum < 0) = NaN;
    
    fALFF = ALFF_BP_sum ./ ALFF_AP_sum;
    fALFF(isinf(fALFF)) = NaN;
    
    brant_write_nii(ALFF_BP_sum / length(find(f_mask_bp)), mask_ind, mask_hdr, subj_ids{m}, 'ALFF', outdir_alff, nor_m_ind, nor_z_ind, {out_nor_ALFF_m, out_nor_ALFF_z});
    brant_write_nii(fALFF, mask_ind, mask_hdr, subj_ids{m}, 'fALFF', outdir_falff, nor_m_ind, nor_z_ind, {out_nor_fALFF_m, out_nor_fALFF_z});
    
    fprintf('\t');
    toc
    fprintf('\tSubject %s finished...\n\n', subj_ids{m});
    clear('fALFF', 'ALFF_BP_sum', 'ALFF_AP_sum');
end
fprintf('\tFinished!\n');

if any(tc_pts ~= subj_tps)
    warning([sprintf('Timepoints that don''t match with the input timepoint!\n'),...
             sprintf('%s\n', subj_ids{tc_pts ~= subj_tps})]);
end
