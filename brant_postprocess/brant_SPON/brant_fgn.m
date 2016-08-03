function brant_fgn(jobman)

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

mask_fn = jobman.input_nifti.mask{1};
% tc_pts = 1; %jobman.timepoint;
[pL, pR, H0, alpha] = brant_truncated_alpha(jobman.timepoints);

outdir = jobman.out_dir{1};
nor_ind = jobman.nor;
    
[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end
    
    if nor_ind == 1
        outdir_mk = brant_make_outdir(out_dir_tmp, {'fGn_Hurst_raw', 'fGn_Sigma_raw', 'Hurst_Normalised_m', 'Sigma_Normalised_m'});
    else
        outdir_mk = brant_make_outdir(out_dir_tmp, {'fGn_Hurst_raw', 'fGn_Sigma_raw', '', ''});
    end

    jobman.input_nifti.filetype = split_prefix{mm};
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, out_dir_tmp);
    
%     subj_tps = zeros(numel(subj_ids), 1);
    num_subj = numel(subj_ids);
    for m = 1:num_subj
        tic
        [data_2d_mat, data_tps, mask_ind_new] = brant_4D_to_mat(nifti_list{m}, size_mask, mask_ind, 'cell', subj_ids{m});
        fprintf('\n\tCalculating the Hurst exponentof the whole brain for subject %d/%d %s...\n', m, num_subj, subj_ids{m});

%         subj_tps(m) = data_tps;
        Hurst = zeros(size_mask, 'single');
        Sigma = zeros(size_mask, 'single');

        f_good_ind = cellfun(@(x) sum(abs(x)) > 1, data_2d_mat);    

        ind = cellfun(@brant_mpe_index, data_2d_mat(f_good_ind));
        [H, sigma, sf] = arrayfun(@(x, y) brant_mpe(x{1}, data_tps, pL, pR, H0, alpha, 1, y), data_2d_mat(f_good_ind), ind);
        Hurst(mask_ind_new(f_good_ind)) = H;
        Sigma(mask_ind_new(f_good_ind)) = sigma;

        brant_write_nii(Hurst, mask_ind_new, mask_hdr, subj_ids{m}, 'Hurst', outdir_mk{1}, nor_ind, 0, {outdir_mk{3}, ''});
        brant_write_nii(Sigma, mask_ind_new, mask_hdr, subj_ids{m}, 'Sigma', outdir_mk{2}, nor_ind, 0, {outdir_mk{4}, ''});

        fprintf('\tSubject %s finished in %f s.\n\n', subj_ids{m}, toc);
    end
end


% if any(tc_pts ~= subj_tps)
%     warning([sprintf('Timepoints that don''t match with the input timepoint!\n'),...
%              sprintf('%s\n', subj_ids{tc_pts ~= subj_tps})]);
% end

fprintf('\n\tFinished!\n');