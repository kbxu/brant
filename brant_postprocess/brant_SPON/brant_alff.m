function brant_alff(jobman)
% Help information for ALFF/fALFF:
%
% GUI parameters:
% mask: could be whole brain mask or gray matter mask.
% id index: identifier to find unique string for each subject
% filetype: files in the filetype will be searched in input directories.
% 4D nifti files: if the input data is 4D, check this item. Otherwise uncheck.
% input dirs: directories can be input either using a .txt file or spm select window.
% 
% TR: repetition time, used as sample frequency 1/TR to estimate width of frequency band.
% lower cutoff (Hz): lower cutoff for band pass filter.
% upper cutoff (Hz): upper cutoff for band pass filter.
% normalize transform: in output file, a suffix of '_m' means the output is divided by mean intensity in the mask; a suffix of '_z' means the output is subtracted by mean intensity and divided by standard deviation.
% smooth results: whether or not to smooth results using a gaussian kernel.
% smooth kernel size: fwhm of smooth kernel
% out dir: output directory for saving results.
%
% Script parameters: (-> refers to explainations in GUI parameters)
% jobman.input_nifti.mask -> mask
% jobman.input_nifti.nm_pos -> id index
% jobman.input_nifti.filetype -> filetype
% jobman.input_nifti.is4d -> 4D nifti files
% jobman.input_nifti.dirs -> input dirs
% jobman.tr -> TR
% jobman.lower_thr -> lower cutoff (Hz)
% jobman.upper_thr -> upper cutoff (Hz)
% jobman.nor -> normalize transform
% jobman.sm_ind -> smooth results
% jobman.fwhm -> smooth kernel size
% jobman.out_dir -> out dir

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

FS = 1 / jobman.tr;
BP = [jobman.lower_thr, jobman.upper_thr];

% tc_pts = 1; %jobman.timepoint;
nor_ind = jobman.nor;
outdir = jobman.out_dir{1};
mask_fn = jobman.input_nifti.mask{1};

sm_ind = jobman.sm_ind;
sm_fwhm = jobman.fwhm;

[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end
    
    if (nor_ind == 1)
        outdir_mk = brant_make_outdir(out_dir_tmp, {'ALFF_raw', 'fALFF_raw', 'ALFF_Normalised_m', 'fALFF_Normalised_m', 'ALFF_Normalised_z', 'fALFF_Normalised_z'});
    else
        outdir_mk = brant_make_outdir(out_dir_tmp, {'ALFF_raw', 'fALFF_raw', '', ''});
    end

    jobman.input_nifti.filetype = split_prefix{mm};
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, out_dir_tmp);
    
%     subj_tps = zeros(numel(subj_ids), 1);

    num_subj = numel(subj_ids);
    for m = 1:num_subj
        tic;    

        [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});
        brant_spm_check_orientations([mask_hdr, nii_hdr]);
        fprintf('\tCalculating ALFF/fALFF for subject %d/%d %s please wait ...\n', m, num_subj, subj_ids{m});

%         subj_tps(m) = data_tps;
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

        brant_write_nii(ALFF_BP_sum / length(find(f_mask_bp)), mask_ind, mask_hdr, subj_ids{m}, 'ALFF', outdir_mk{1}, nor_ind, nor_ind, outdir_mk([3, 5]));
        brant_write_nii(fALFF, mask_ind, mask_hdr, subj_ids{m}, 'fALFF', outdir_mk{2}, nor_ind, nor_ind, outdir_mk([4, 6]));

        fprintf('\tSubject %s finished in %f s.\n\n', subj_ids{m}, toc);
        clear('fALFF', 'ALFF_BP_sum', 'ALFF_AP_sum');
    end
    
    if (sm_ind == 1)
        brant_smooth_rst(outdir_mk, '*.nii', sm_fwhm, num2str(sm_fwhm,'s%d%d%d'), 1);
    end      
end
fprintf('\tFinished!\n');