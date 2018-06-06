function brant_reho(jobman)

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

outdir = jobman.out_dir{1};
mask_fn = jobman.input_nifti.mask{1};
totalvoxel = jobman.neighbour_num + 1;

nor_ind = jobman.nor;

sm_ind = jobman.sm_ind;
sm_fwhm = jobman.fwhm;

[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end

    if (nor_ind == 1)
        outdir_mk = brant_make_outdir(out_dir_tmp, {'ReHo_raw', 'ReHo_Normalised_m', 'ReHo_Normalised_z'});
    else
        outdir_mk = brant_make_outdir(out_dir_tmp, {'ReHo_raw', '', ''});
    end

    jobman.input_nifti.filetype = split_prefix{mm};
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, out_dir_tmp);
    n_vox_slice = prod(size_mask(1:2));
    n_vox_vol = prod(size_mask(1:3));
    
%     subj_tps = zeros(numel(subj_ids), 1);
    num_subj = numel(subj_ids);
    
    ind_out = brant_nbr_vox(mask_ind, totalvoxel, size_mask, n_vox_slice, n_vox_vol);
    num_mask = numel(mask_ind);
    
    for m = 1:num_subj
        tic;

        [data_2d_mat, data_tps] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'cell', subj_ids{m});
%         brant_spm_check_orientations([mask_hdr, nii_hdr]);
        
        fprintf('\tCalculating ReHo for subject %d/%d %s...\n', m, num_subj, subj_ids{m});
        [TC_total_sorted, TC_total_ind] = cellfun(@sort, data_2d_mat, 'UniformOutput', false);

        diff_mat = cell2mat(cellfun(@(x) diff(x) == 0, TC_total_sorted, 'UniformOutput', false));

        uniq_ind = sum(diff_mat, 1) == 0;
%         subj_tps(m) = data_tps;
        TC_total_ranked = nan([data_tps, num_mask], 'single');
        asc_seq = 1:data_tps;
        for n = 1:num_mask
            TC_total_ranked(TC_total_ind{n}, n) = asc_seq;
        end

        dup_vox = find(~uniq_ind);
        if ~isempty(dup_vox)

            num_dup = numel(dup_vox);

            % dup_ind: indices of duplicated values in sorted matrix
            dup_ind = ([false(1, num_dup); diff_mat(:, dup_vox)] | [diff_mat(:, dup_vox); false(1, num_dup)]);

            % dup_vals: duplicated values in sorted vectors
            dup_vals = arrayfun(@(x, y) TC_total_sorted{x}(dup_ind(:, y)), dup_vox, 1:num_dup, 'UniformOutput', false);

            % uni_dup_vals: unique duplicated values in sorted vectors
            uni_dup_vals = cellfun(@unique, dup_vals, 'UniformOutput', false);

            % dup_ind_1d: indices of duplicated values in original vectors
            dup_ind_1d = arrayfun(@(x, y) TC_total_ind{x}(dup_ind(:, y)), dup_vox, 1:num_dup, 'UniformOutput', false);

            for n = 1:num_dup
                for nn = 1:numel(uni_dup_vals{n})
                    % dup_pos: indices of a group of duplicated values in original vectors
                    dup_pos = dup_ind_1d{n}(dup_vals{n} == uni_dup_vals{n}(nn));

                    % get the average of the same rank and assign it to the duplicated indices
                    TC_total_ranked(dup_pos, dup_vox(n)) = mean(TC_total_ranked(dup_pos, dup_vox(n)));
                end
            end
        end
        clear('TC_total_sorted', 'data_2d_mat');

        Reho_temp = nan(size_mask, 'single');

        for n = 1:num_mask
            ind_good = ind_out(n, ind_out(n, :) > 0);
            R_block_tmp = TC_total_ranked(:, ind_good);
            Reho_temp(mask_ind(n)) = calc_reho(R_block_tmp);
        end
        clear('TC_total_ranked');

        brant_write_nii(Reho_temp, mask_ind, mask_hdr, subj_ids{m}, 'ReHo', outdir_mk{1}, nor_ind, nor_ind, outdir_mk(2:3));

        fprintf('\tSubject %s finished in %f s.\n\n', subj_ids{m}, toc);
    end
    clear('ind_out');
    
    
    if (sm_ind == 1)
        brant_smooth_rst(outdir_mk, '*.nii', sm_fwhm, num2str(sm_fwhm,'s%d%d%d'), 1);
    end
end
fprintf('\tFinished!\n');

function ReHo = calc_reho(nbr_array)
[N, K] = size(nbr_array);
SR = sum(nbr_array, 2); 
SRBAR = mean(SR);
S = sum(SR .^ 2) - N * SRBAR ^ 2;
ReHo = 12 * S / (K ^2 * (N ^ 3 - N));
