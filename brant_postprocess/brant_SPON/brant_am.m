function brant_am(jobman)

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

tc_pts = 1;
mask_fn = jobman.input_nifti.mask{1};
outdir = jobman.out_dir{1};

am_ind = jobman.am;
std_ind = jobman.std;
var_ind = jobman.var;

if ~any([am_ind, std_ind, var_ind])
    error('At least one option should be selected!');
end

nor_ind = jobman.nor;
sm_ind = jobman.sm_ind;
sm_fwhm = jobman.fwhm;

[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end
    
    if (nor_ind == 1)
        outdir_mk = brant_make_outdir(out_dir_tmp, {'AM_raw', 'STD_raw', 'VAR_raw',...
                                                    'AM_Normalised_m', 'STD_Normalised_m', 'VAR_Normalised_m',...
                                                    'AM_Normalised_z', 'STD_Normalised_z', 'VAR_Normalised_z'});
    else
        outdir_mk = brant_make_outdir(out_dir_tmp, {'AM_raw', 'STD_raw', 'VAR_raw', '', '', ''});
    end
    
    jobman.input_nifti.filetype = split_prefix{mm};
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(mask_fn, nifti_list{1}, out_dir_tmp);
    
%     subj_tps = zeros(numel(subj_ids), 1);
    
    num_subj = numel(subj_ids);
    for m = 1:num_subj
        
        tic
        [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});
        brant_spm_check_orientations([mask_hdr, nii_hdr]);
        
%         subj_tps(m) = data_tps;
        
        if (am_ind == 1)
            fprintf('\tCalculating mean temporal amplitude for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            AM_temp = nan(size_mask, 'single');
            AM_temp(mask_ind) = nanmean(abs(detrend(data_2d_mat, 'constant')));
            brant_write_nii(AM_temp, mask_ind, mask_hdr, subj_ids{m}, 'AM', outdir_mk{1}, nor_ind, nor_ind, outdir_mk([4, 7]));
        end
        
        if (std_ind == 1)
            fprintf('\tCalculating standard deviation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            STD_temp = nan(size_mask, 'single');
            STD_temp(mask_ind) = nanstd(data_2d_mat);
            brant_write_nii(STD_temp, mask_ind, mask_hdr, subj_ids{m}, 'STD', outdir_mk{2}, nor_ind, nor_ind, outdir_mk([5, 8]));
        end
        
        if (var_ind == 1)
            fprintf('\tCalculating variance for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            VAR_temp = nan(size_mask, 'single');
            VAR_temp(mask_ind) = nanvar(data_2d_mat);
            brant_write_nii(VAR_temp, mask_ind, mask_hdr, subj_ids{m}, 'VAR', outdir_mk{3}, nor_ind, nor_ind, outdir_mk([6, 9]));
        end
        
        fprintf('\tSubject %s finished in %f s.\n\n', subj_ids{m}, toc);
    end
    
    if (sm_ind == 1)
        brant_smooth_rst(outdir_mk, '*.nii', sm_fwhm, num2str(sm_fwhm,'s%d%d%d'), 1);
    end
end
fprintf('\tFinished!\n');