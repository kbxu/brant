function den_fil_prefix = brant_run_denoise_filter_old(den_fil_infos, data_files, subj_fns, is4d_ind, outdirs)
% deprecated function
% den_fil_infos
% data_files: N*1 cell array of full path filenames
% subj_fns: N*1 cell array of subject ids
% is4d_ind: 0 or 1, is input file 4D
% outdirs: N*1 cell array of output directories.

gzip_ind = [0, 0];

denoise_prefix = den_fil_infos.subj.prefix_denoise;
filter_prefix = den_fil_infos.subj.prefix_filter;

gsr_ind = den_fil_infos.subj.gsr;
nogsr_ind = den_fil_infos.subj.nogsr;
bothgsr_ind = den_fil_infos.subj.bothgsr;

if (bothgsr_ind == 1)
    gr_prefix = {'GR', 'noGR'};
    gr_str_out = '[GR+noGR]';
elseif (nogsr_ind == 1)
    gr_prefix = {'noGR'};
    gr_str_out = 'noGR';
elseif (gsr_ind == 1)
    gr_prefix = {'GR'};
    gr_str_out = 'GR';
else
    error('Unknown Option!');
end

if ((nogsr_ind == 0) && isempty(den_fil_infos.detrend_mask.gs))
    error('Mask of global signal regression is missing!');
end


work_tissue = den_fil_infos.detrend_mask.tissue_trends_ind;
work_motion = den_fil_infos.motion.hm_model_ind;
work_filter = den_fil_infos.filter.filter_ind;

work_denoise = any([work_tissue, work_motion]);
den_fil_prefix = [];
if (work_denoise == 1)
    den_fil_prefix = [denoise_prefix, gr_str_out];
end
if (work_filter == 1)
    den_fil_prefix = [filter_prefix, den_fil_prefix];
end


wb_mask = den_fil_infos.subj.wb_mask;

detrend_ind = den_fil_infos.detrend_mask.detrend;
reg_masks{1} = den_fil_infos.detrend_mask.gs;
reg_masks{2} = den_fil_infos.detrend_mask.wm;
reg_masks{3} = den_fil_infos.detrend_mask.csf;
tissue_deriv = den_fil_infos.detrend_mask.tissue_deriv;
reg_strs = {'gs', 'wm', 'csf'};

motion_model_ind = [den_fil_infos.motion.params_6, den_fil_infos.motion.params_12, den_fil_infos.motion.params_24];
motion_model_strs = {'6 parameters', '12 parameters', '24 parameters'};
motion_model_str = motion_model_strs{motion_model_ind == 1};
motion_scrub = den_fil_infos.motion.scrub_FD;
apply_temp_mask = den_fil_infos.motion.use_temp_mask;
motion_filetype = den_fil_infos.motion.filetype;

filter_lower = den_fil_infos.filter.lower_cutoff;
filter_upper = den_fil_infos.filter.upper_cutoff;
filter_tr = den_fil_infos.filter.tr;

% check_tps = 1;

wb_mask_bin = true;
if ~isempty(wb_mask)
    wb_mask_tmp = load_nii_mod(wb_mask);
    wb_mask_bin_tmp = wb_mask_tmp.img > 0.5;
    mask_hdrs = wb_mask_tmp.hdr;
else
    wb_mask_bin_tmp = true;
end
wb_mask_bin = wb_mask_bin & wb_mask_bin_tmp;


num_subj = numel(data_files);
if (numel(wb_mask_bin) == 1)
    mask_ind_notsnr = [];
else
    mask_ind_notsnr = find(wb_mask_bin);
end

% size_mask = size(wb_mask_bin);

% create mask for tsnr
mask_tsnr_ind = 'none';
thres_tsnr = 0; % mask this function
if (strcmpi(mask_tsnr_ind, 'none') == 0)
       
    tsnr_mean = 0;
    for m = 1:numel(data_files)
        fprintf('\tCalculating TSNR for subject %s...\n', data_files{m});
        
        [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(data_files{m}, mask_ind_notsnr, 'mat', subj_fns{m}); %#ok<*ASGLU>
        size_data = nii_hdr.dime.dim(2:4);
        
        len_mask = size(data_2d_mat, 2);
        if isempty(mask_ind_notsnr)
            out_index = 1:len_mask;
        else
            out_index = mask_ind_notsnr;
        end

        % check data dimensions
%         subj_info.dim = nii_hdr.dime.dim(2:4);
%         subj_info.pixdim = nii_hdr.dime.pixdim(2:4);
%         brant_spm_check_orientations([mask_hdr_info, subj_info]);
        brant_spm_check_orientations([mask_hdrs, nii_hdr]);
        
        % split data into blocks
        int_array = brant_get_intervals(1, len_mask, 1024);
        
        tsnr_mask = zeros(len_mask, 1);
        for n = 1:size(int_array, 1)
            ind_vec = int_array(n, 1):int_array(n, 2);
            tsnr_mask(ind_vec) = mean(data_2d_mat(:, ind_vec), 1) ./ std(data_2d_mat(:, ind_vec), 1);
        end
        
        tsnr_ts_3d = zeros(size_data, 'double');
        tsnr_ts_3d(out_index) = tsnr_mask;
        brant_save_nii(1, data_files{m}, ['tsnr_', subj_fns{m}, '_'], nii_hdr, tsnr_ts_3d, outdirs{m}, 0);
        
        tsnr_mean = tsnr_mean + tsnr_mask / num_subj;
        
        fprintf('\tFinished calculating TSNR for subject %s...\n\n', data_files{m});
    end
    
    brant_save_nii_tmp(size_data, tsnr_mean, mask_ind_notsnr, nii_hdr, sprintf('mean_tsnr_subj_%d.nii', num_subj), pwd);
    tsnr_mean_mask_tmp = brant_save_nii_tmp(size_data, double(tsnr_mean > thres_tsnr), mask_ind_notsnr, nii_hdr, sprintf('mean_tsnr_subj_%d_mask.nii', num_subj), pwd);
    fprintf('\tGroup mean TSNR and TSNR-mask are stored in %s.\n', pwd);
    tsnr_mean_mask = tsnr_mean_mask_tmp > 0.5;
else
    tsnr_mean_mask = true;
end

tissue_ext_ind = ~cellfun(@isempty, reg_masks);
reg_strs_good = reg_strs(tissue_ext_ind);
if any(tissue_ext_ind)
    reg_masks_good = reg_masks(tissue_ext_ind);
%     reg_masks_good_bin = cell(sum(tissue_ext_ind), 1);
    mask_tmp = cellfun(@load_nii_mod, reg_masks_good);
    reg_masks_good_bin = arrayfun(@(x) x.img > 0.5, mask_tmp, 'UniformOutput', false);
    reg_mask_hdrs = arrayfun(@(x) x.hdr, mask_tmp);
    clear('mask_tmp');
%     for m = 1:numel(reg_masks_good)
%         mask_tmp = load_nii_mod(reg_masks_good{m});
%         reg_masks_good_bin{m} = mask_tmp.img > 0.5;
%         reg_mask_hdrs(m) = mask_tmp.hdr; %#ok<AGROW>
%     end
else
    reg_mask_hdrs = [];
    reg_masks_good_bin = [];    
end
brant_spm_check_orientations([mask_hdrs, reg_mask_hdrs]);

if (is4d_ind == 1)
    data_dirs = cellfun(@fileparts, data_files, 'UniformOutput', false);
else
    data_dirs = cellfun(@(x) fileparts(x{1}), data_files, 'UniformOutput', false);
end

if (work_motion == 1)
    data_input_hm.dirs = data_dirs;
    data_input_hm.single_3d = 1;
    data_input_hm.filetype = motion_filetype;
    file_hm = brant_get_subjs(data_input_hm);
end

% start calculating for denoise and filter
wb_mask_final = tsnr_mean_mask & wb_mask_bin;


for m = 1:num_subj
    % yes load all the data here!
    [nii_2d, data_size, nii_hdr] = brant_load_nifti_mask(data_files{m}, []);
    
    sum_nii_2d = sum(nii_2d, 1);
    nii_2d_mask = isfinite(sum_nii_2d) & (sum_nii_2d ~= 0); %individual mask
    
    size_input = size(nii_2d);
    
    if (numel(wb_mask_final) == 1)
        nii_2d_calc = nii_2d;
    else
        nii_2d_calc = nii_2d(:, wb_mask_final(:)); % do not use individual mask here
    end
    
    num_tps = size(nii_2d_calc, 1);
%     num_mask = size(nii_2d_calc, 2);
    
    reg_tissue = [];
    diff_tissue = [];
    detrend_reg = [];
    if (work_tissue == 1)
        % tissue regressors
        if (detrend_ind == 1)
            detrend_reg = (1:num_tps)';
        end
        
        if ~isempty(reg_masks_good_bin)
            reg_tissue = cellfun(@(x) nanmean(nii_2d(:, x(:)' & nii_2d_mask), 2), reg_masks_good_bin, 'UniformOutput', false);
            reg_tissue = cat(2, reg_tissue{:});
            if (tissue_deriv == 1)
                diff_tissue = [zeros(1, size(reg_tissue, 2)); diff(reg_tissue)];
            end
        end
    end
    clear('nii_2d');

    temp_mask = true(num_tps, 1);
    motion_reg = [];
    if (work_motion == 1)
        head_motion_6 = load(file_hm{m});
        
        col_hm = size(head_motion_6, 2);

        switch(motion_model_str)
            case '6 parameters'
                motion_reg = head_motion_6;
            case '12 parameters'
                motion_reg = [head_motion_6, [zeros(1, col_hm); diff(head_motion_6)]];
            case '24 parameters'
                motion_pre = [zeros(1, col_hm); head_motion_6(1:end-1, :)];
                motion_reg = [head_motion_6, head_motion_6.^2, motion_pre, motion_pre.^2];
        end

        if (motion_scrub > 0)
            motion_diff = diff(head_motion_6);
            FD = [0; sum([abs(motion_diff(:, 1:3)), 50 * abs(motion_diff(:, 4:6))], 2)];
            temp_mask = FD < motion_scrub;
            
            dlmwrite(fullfile(data_dirs{m}, ['framewise_displacement', subj_fns{m}, '.txt']), FD);
            dlmwrite(fullfile(data_dirs{m}, ['temporal_mask_FD', subj_fns{m}, '.txt']), temp_mask);
        end
    end
        
    gsr_ind = strcmpi(reg_strs_good, 'gs');
    for mm = 1:numel(gr_prefix)
        if any([work_tissue, work_motion])
            fprintf('\n\tDoing Multi-variable regression (%s) for subject %s %d/%d.\n', gr_prefix{mm}, subj_fns{m}, m, num_subj);

            if any(work_tissue)
                if strcmpi(gr_prefix{mm}, 'GR')
                    reg_gr = [reg_tissue, diff_tissue];
                elseif strcmpi(gr_prefix{mm}, 'noGR')
                    if (tissue_deriv == 1)
                        reg_gr = [reg_tissue(:, ~gsr_ind), diff_tissue(:, ~gsr_ind)];
                    else
                        reg_gr = reg_tissue(:, ~gsr_ind);
                    end
                end
            else
                reg_gr = [];
            end
            
            %whitten regressors
            reg_mat_tmp = [detrend_reg, reg_gr, motion_reg];
            
            
%             reg_mat = [ones(num_tps, 1), detrend_reg, reg_gr, motion_reg];
            if ~isempty(reg_mat_tmp)
                reg_mat_demean = bsxfun(@minus, reg_mat_tmp, mean(reg_mat_tmp));
                reg_mat_nor = bsxfun(@rdivide, reg_mat_demean, max(abs(reg_mat_demean), [], 1));
                reg_mat = [ones(num_tps, 1), reg_mat_nor];
                
%                 reg_mat_nor = bsxfun(@rdivide, reg_mat, max(abs(reg_mat), [], 1));
                beta_reg = reg_mat(temp_mask, :) \ nii_2d_calc(temp_mask, :);
                res_data = nii_2d_calc - reg_mat * beta_reg;
            else
                res_data = nii_2d_calc;
            end
            
            denoise_vol = nan(size_input, 'single');
            denoise_vol(:, wb_mask_final(:)) = res_data;

            denoise_vol = reshape(denoise_vol, [data_size(4), data_size(1:3)]);
            denoise_vol = shiftdim(denoise_vol, 1);

            prefix_calc = [denoise_prefix, gr_prefix{mm}];
            
            if (apply_temp_mask == 1)
                brant_save_nii(is4d_ind, data_files{m}, prefix_calc, nii_hdr, denoise_vol(:, :, :, temp_mask), outdirs{m}, gzip_ind(1));
            else
                brant_save_nii(is4d_ind, data_files{m}, prefix_calc, nii_hdr, denoise_vol, outdirs{m}, gzip_ind(1));
            end

            % vol_calc: T timepoints * N voxels
            vol_calc = res_data;
            clear('res_data');
        else
            % vol_calc: T timepoints * N voxels
            vol_calc = nii_2d_calc;
            prefix_calc = '';
        end

        if (work_filter == 1)

            fprintf('\tFilter: %.3f-%.3f Hz, TR:%.2f s, subject: %s %d/%d\n', filter_lower, filter_upper, filter_tr, subj_fns{m}, m, num_subj);

            int_array = brant_get_intervals(1, size(vol_calc, 2), 1024);
            filter_calc = zeros(size(vol_calc), 'single');
            for n = 1:size(int_array, 1)
                ind_vec = int_array(n, 1):int_array(n, 2);
                filter_calc(:, ind_vec) = brant_Filter_FFT_Butterworth(vol_calc(:, ind_vec), filter_lower, filter_upper, 1 / filter_tr, 0);
            end

            filter_vol = nan(size_input, 'single');
            filter_vol(:, wb_mask_final(:)) = filter_calc;

            filter_vol = reshape(filter_vol, [data_size(4), data_size(1:3)]);
            filter_vol = shiftdim(filter_vol, 1);

            filter_prefix_calc = [filter_prefix, prefix_calc];
            
            if (apply_temp_mask == 1)
                brant_save_nii(is4d_ind, data_files{m}, filter_prefix_calc, nii_hdr, filter_vol(:, :, :, temp_mask), outdirs{m}, gzip_ind(2));
            else
                brant_save_nii(is4d_ind, data_files{m}, filter_prefix_calc, nii_hdr, filter_vol, outdirs{m}, gzip_ind(2));
            end
            
            clear('filter_vol', 'filter_calc', 'vol_calc');
        end
    end
end

fprintf('\n\tFinished!\n');

function vol_tmp = brant_save_nii_tmp(size_mask, data_1d, mask_ind, nii_hdr, fn, outdir)

vol_tmp = zeros(size_mask, 'double');
if isempty(mask_ind)
    vol_tmp(:) = data_1d;
else
    vol_tmp(mask_ind) = data_1d;
end

% outdir = pwd;
filename = fullfile(outdir, fn);
nii = make_nii(vol_tmp, nii_hdr.dime.pixdim(2:4), nii_hdr.hist.originator(1:3)); 
save_nii(nii, filename);
