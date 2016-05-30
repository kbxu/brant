function brant_am(jobman)

tc_pts = jobman.timepoint;
mask_fn = jobman.mask{1};
outdir = jobman.out_dir{1};

am_ind = jobman.am;
std_ind = jobman.std;
var_ind = jobman.var;

if ~any([am_ind, std_ind, var_ind])
    error('At least one option should be selected!');
end

nor_ind = jobman.nor;


mask_nii = load_nii(mask_fn);
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_hdr = mask_nii.hdr;
mask_ind = find(mask_nii.img > 0.5);
% [mask_x, mask_y, mask_z] = ind2sub(size_mask, mask_ind);


[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end
    
    out_raw_am = fullfile(out_dir_tmp, 'AM_raw');
    out_raw_std = fullfile(outdir, 'STD_raw');
    out_raw_var = fullfile(out_dir_tmp, 'VAR_raw');
    
    if (am_ind == 1) && (exist(out_raw_am, 'dir') ~= 7), mkdir(out_raw_am); end
    if (std_ind == 1) && (exist(out_raw_std, 'dir') ~= 7), mkdir(out_raw_std); end
    if (var_ind == 1) && (exist(out_raw_var, 'dir') ~= 7), mkdir(out_raw_var); end
    
    if nor_ind == 1
        out_nor_z_am = fullfile(out_dir_tmp, 'AM_Normalised_z');
        out_nor_z_std = fullfile(outdir, 'STD_Normalised_z');
        out_nor_z_var = fullfile(out_dir_tmp, 'VAR_Normalised_z');
        
        if (am_ind == 1) && (exist(out_nor_z_am, 'dir') ~= 7), mkdir(out_nor_z_am); end
        if (std_ind == 1) && (exist(out_nor_z_std, 'dir') ~= 7), mkdir(out_nor_z_std); end
        if (var_ind == 1) && (exist(out_nor_z_var, 'dir') ~= 7), mkdir(out_nor_z_var); end
    else
        out_nor_z_am = '';
        out_nor_z_std = '';
        out_nor_z_var = '';
    end
    
    jobman.input_nifti.filetype = split_prefix{mm};
    
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    subj_tps = zeros(numel(subj_ids), 1);
    
    num_subj = numel(subj_ids);
    for m = 1:num_subj
        
        tic
        [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});
        brant_spm_check_orientations([mask_hdr, nii_hdr]);
        
        
        subj_tps(m) = data_tps;
        
        if am_ind == 1
            fprintf('\tCalculating mean temporal amplitude for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            AM_temp = nan(size_mask, 'single');
            AM_temp(mask_ind) = mean(abs(detrend(data_2d_mat, 'constant')));
            brant_write_nii(AM_temp, mask_ind, mask_hdr, subj_ids{m}, 'AM', out_raw_am, 0, nor_ind, {'', out_nor_z_am});
        end
        
        if std_ind == 1
            fprintf('\tCalculating standard deviation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            STD_temp = nan(size_mask, 'single');
            STD_temp(mask_ind) = nanstd(data_2d_mat);
            brant_write_nii(STD_temp, mask_ind, mask_hdr, subj_ids{m}, 'STD', out_raw_std, 0, nor_ind, {'', out_nor_z_std});
        end
        
        if var_ind == 1
            fprintf('\tCalculating variance for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            VAR_temp = nan(size_mask, 'single');
            VAR_temp(mask_ind) = nanvar(data_2d_mat);
            brant_write_nii(VAR_temp, mask_ind, mask_hdr, subj_ids{m}, 'VAR', out_raw_var, 0, nor_ind, {'', out_nor_z_var});
        end
        
        fprintf('\tSubject %s finished in %f s.\n\n', subj_ids{m}, toc);
    end
end

fprintf('\n\t All finished. \n');

if any(tc_pts ~= subj_tps)
    warning([sprintf('Timepoints that don''t match with the input timepoint!\n'),...
        sprintf('%s\n', subj_ids{tc_pts ~= subj_tps})]);
end
