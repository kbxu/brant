function brant_extract_ts(jobman)

% only extract one time series

% Change those lines when scripting and good luck!

% jobman.mask = {''};
% jobman.out_dir = {''};
% jobman.no_nan = 1;
% jobman.input_nifti.dirs = {''}; 
% jobman.input_nifti.filetype = '*.nii.gz';
% jobman.input_nifti.nm_pos = 0;
% jobman.input_nifti.is4d = 1;


outdir = jobman.out_dir{1};
no_nan_ind = jobman.no_nan;
mask_file = jobman.mask{1};



if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end
out_ts = fullfile(outdir, 'mean_ts');
if exist(out_ts, 'dir') ~= 7
    mkdir(out_ts);
end
    
mask_nii = load_nii(mask_file);
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_ind = find(mask_nii.img > 0.5);
% [mask_x, mask_y, mask_z] = ind2sub(mask_size, mask_ind);

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);

mean_ts_tot = [];
for m = 1:numel(nifti_list)
    
    [data_2d_mat, data_tps, mask_ind_new] = brant_4D_to_mat(nifti_list{m}, size_mask, mask_ind, 'mat', subj_ids{m}); %#ok<*ASGLU,*NASGU>
    
    mean_ts = mean(data_2d_mat, 2);
    subjname = subj_ids{m};
    save(fullfile(out_ts, [subjname, '_ts.mat']), 'mean_ts', 'subjname');
    
    mean_ts_tot = [mean_ts_tot, mean_ts];
    clear('data_4d_mat');
end

save(fullfile(outdir, 'mean_ts_tot.mat'), 'mean_ts_tot', 'subj_ids');
fprintf('\tFinished!\n');
