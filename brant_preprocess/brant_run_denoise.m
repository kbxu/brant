function end_prefix = brant_run_denoise(wk_dir, denoise_infos, data_files, subj_fns, is4d_ind, outdirs, nm_pos)
% wk_dir: working directory (to save temporary and log files)
% denoise_infos: items of denoise, exported from GUI
% data_files: N*1 cell array of full path filenames
% subj_fns: N*1 cell array of subject ids
% is4d_ind: 0 or 1, whether input file is arranged in 4D
% name position of input directories
% outdirs: N*1 cell array of output directories, leave empty to export
% files to original data directories.

%% Path of each input data
if is4d_ind == 1
    subj_paths = cellfun(@fileparts, data_files, 'UniformOutput', false);
else
    subj_paths = cellfun(@(x) fileparts(x{1}), data_files, 'UniformOutput', false);
end

%% check space of each data is in common space
if is4d_ind == 1
    ref_hdrs = cellfun(@(x) load_nii_hdr_mod(x, 'untouch0'), data_files);
%     ref_hdrs = cellfun(@(x) load_nii_hdr_img_raw_c(x), data_files);
else
    ref_hdrs = cellfun(@(x) load_nii_hdr_mod(x{1}, 'untouch0'), data_files);
end

if denoise_infos.space_mask.space_comm == 1
    fprintf('Checking data orientations and resolutions, if an error came out, please check data before preprocess!\n');
    brant_spm_check_orientations(ref_hdrs);
    fprintf('Input data are well arranged!\n');
end
    
%% whether to do regression or filter
reg_ind = (denoise_infos.fil_opt.filter_reg == 1) | (denoise_infos.fil_opt.reg_only == 1) | (denoise_infos.fil_opt.reg_filter == 1);
fil_ind = (denoise_infos.fil_opt.filter_reg == 1) | (denoise_infos.fil_opt.filter_only == 1) | (denoise_infos.fil_opt.reg_filter == 1);

if fil_ind
    if denoise_infos.fil_opt.tr == 0
        error('TR cannot be 0!');
    end
end

% whether to regress out any tissue mean signal
T_ind = (denoise_infos.reg_mdl.regressors.T == 1) | (denoise_infos.reg_mdl.regressors.T_square == 1) | (denoise_infos.reg_mdl.regressors.T_prime == 1) |...
        (denoise_infos.reg_mdl.regressors.T_prime_square == 1) | (denoise_infos.reg_mdl.regressors.T_prep == 1) | (denoise_infos.reg_mdl.regressors.T_prep_square == 1);

% whether to regress out any motion signal
R_ind = (denoise_infos.reg_mdl.regressors.R == 1) | (denoise_infos.reg_mdl.regressors.R_square == 1) | (denoise_infos.reg_mdl.regressors.R_prime == 1) |...
        (denoise_infos.reg_mdl.regressors.R_prime_square == 1) | (denoise_infos.reg_mdl.regressors.R_prep == 1) | (denoise_infos.reg_mdl.regressors.R_prep_square == 1);

% find motion files
if R_ind
    motion_files = batch_search_files(subj_paths, denoise_infos.space_mask.ft_motion, nm_pos, 1);
else
    motion_files = [];
end

if ~T_ind % is false, no tissue used, set other tissue ind to false (will not check)
    % only check for whole brain mask
    % 'mask_gs'; 'mask_wm'; 'mask_csf'
    denoise_infos.space_mask.mask_gs = 0;
    denoise_infos.space_mask.mask_wm = 0;
    denoise_infos.space_mask.mask_csf = 0;
    
    % 'ft_gs'; 'ft_wm'; 'ft_csf'
    denoise_infos.space_mask.ft_gs = 0;
    denoise_infos.space_mask.ft_wm = 0;
    denoise_infos.space_mask.ft_csf = 0;
end

%% check masks validity and copy to working directory (only for common space case)
[mask_files, mask_info, mask_thrs] = check_masks(wk_dir, subj_paths, denoise_infos.space_mask, nm_pos);

wb_img_ind = [];
gs_img_ind = [];
wm_img_ind = [];
csf_img_ind = [];

if ~isempty(mask_info)
    % reslice and threshold masks to data
    mask_files_res = reslice_masks(data_files, ref_hdrs, mask_files, denoise_infos.space_mask.mask_res_type);
    
    
    if denoise_infos.space_mask.space_comm == 1
        % find selected masks
        [wb_img_ind, gs_img_ind, wm_img_ind, csf_img_ind] = load_masks(mask_files_res{1}, mask_info, mask_thrs);
    end
end



for m = 1:numel(data_files)
   fprintf('\n*\tRunning denoise for subject %s\t*\n', subj_fns{m}); 
    
    [nii_2d, nii_size, nii_hdr] = brant_load_untouch_nifti_mask(data_files{m}, []);
    
    %% tissue masks, if reg is not selected, just get the whole brain mask
    if ~isempty(mask_info)
        if denoise_infos.space_mask.space_comm == 0
            [wb_img_ind, gs_img_ind, wm_img_ind, csf_img_ind] = load_masks(mask_files_res{m}, mask_info, mask_thrs);
        end
    end
    % regression model. Prepare parameters here.
    if reg_ind
        %% trends
        num_tps = nii_size(4);
        trends = [];
        if denoise_infos.reg_mdl.lin_trend == 1
            trends = [trends, (1:num_tps)'];
        end
        
        if denoise_infos.reg_mdl.quad_trend == 1
            trends = [trends, (1:num_tps)' .^ 2]; %#ok<*AGROW>
        end
        
        if T_ind
            % get all regressors related to mean tissue signal and store in
            % T_mat and T_mat_info
            if isempty(gs_img_ind)
                gs_ts = [];
            else
                gs_ts = nanmean(nii_2d(:, gs_img_ind), 2);
            end
            if isempty(wm_img_ind)
                wm_ts = [];
            else
                wm_ts = nanmean(nii_2d(:, wm_img_ind), 2);
            end
            if isempty(csf_img_ind)
                csf_ts = [];
            else
                csf_ts = nanmean(nii_2d(:, csf_img_ind), 2);
            end
            
            if (denoise_infos.fil_opt.gsr_nogsr == 1)
                if isempty(gs_ts)
                    error('Global mean signal is empty, please check the mask!');
                end
                T_mat_gsr = [gs_ts, wm_ts, csf_ts];
                T_mat_nogsr = [wm_ts, csf_ts];
                
                T_mat{1} = T_mat_gsr;
                T_mat{2} = T_mat_nogsr;
                
                T_mat_info = {'GSR', 'noGSR'};
            else
                T_mat{1} = [gs_ts, wm_ts, csf_ts];
                if isempty(gs_ts)
                    T_mat_info = {'noGSR'};
                else
                    T_mat_info = {'GSR'};
                end
            end
            
            T_full_mat = cell(size(T_mat));
            for n = 1:numel(T_mat)
                T_full_mat{n} = full_regression_matrix(T_mat{n}, denoise_infos.reg_mdl.regressors, 'T');
            end
        else
            T_full_mat = [];
        end
        
        %% head motion signal
        if R_ind
            R_raw = load(motion_files{m});
            R_full_mat = full_regression_matrix(R_raw, denoise_infos.reg_mdl.regressors, 'R');
        else
            R_full_mat = [];
        end
        
        % for both case (GSR and noGSR)
        reg_mat_norm_use = cell(size(T_mat));
        for n = 1:numel(T_mat)
            reg_mat = [trends, T_full_mat{n}, R_full_mat];
            if ~isempty(reg_mat)
                % mean centering to 0 and std to 1
                reg_mat_norm = zscore(reg_mat);
                reg_mat_norm_use{n} = [ones(num_tps, 1), reg_mat_norm];
            end
        end
    end
      
    if isempty(wb_img_ind)
        vol_calc = nii_2d;
    else
        vol_calc = nii_2d(:, wb_img_ind);
        clear('nii_2d');
    end
    
    if (denoise_infos.reg_mdl.scrubbing == 1)
        motion_diff = diff(R_raw);
        FD = [0; sum([abs(motion_diff(:, 1:3)), 50 * abs(motion_diff(:, 4:6))], 2)];
        t_mask = FD < denoise_infos.reg_mdl.fd_thr;
        
        if isempty(outdirs{m})
            dlmwrite(fullfile(subj_paths{m}, ['framewise_displacement_', subj_fns{m}, '.txt']), FD);
            dlmwrite(fullfile(subj_paths{m}, ['temporal_mask_FD_', subj_fns{m}, '.txt']), t_mask);
        else
            dlmwrite(fullfile(outdirs{m}, ['framewise_displacement_', subj_fns{m}, '.txt']), FD);
            dlmwrite(fullfile(outdirs{m}, ['temporal_mask_FD_', subj_fns{m}, '.txt']), t_mask);
        end
    else
        t_mask = true(num_tps, 1);
    end
            
    for n = 1:numel(reg_mat_norm_use)
        % do the work
        
        if denoise_infos.fil_opt.reg_filter == 1
            % regress + filter            
            res_calc = regress_chunk(vol_calc(t_mask, :), reg_mat_norm_use{n}(t_mask, :));
            if denoise_infos.fil_opt.save_last == 0
                % save middle files
                brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, res_calc, data_files{m}, [denoise_infos.fil_opt.prefix_reg, T_mat_info{n}], denoise_infos.fil_opt.gzip_output, outdirs{m});
            end
            
            df_out = filter_chunk(res_calc, denoise_infos.fil_opt.lower_cutoff, denoise_infos.fil_opt.upper_cutoff, denoise_infos.fil_opt.tr);
            brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, df_out, data_files{m}, [denoise_infos.fil_opt.prefix_filter, denoise_infos.fil_opt.prefix_reg, T_mat_info{n}], denoise_infos.fil_opt.gzip_output, outdirs{m});
        elseif denoise_infos.fil_opt.filter_reg == 1
             % filter + regress
             % scrubbing won't affect filter here
            fil_calc = filter_chunk(vol_calc, denoise_infos.fil_opt.lower_cutoff, denoise_infos.fil_opt.upper_cutoff, denoise_infos.fil_opt.tr);
            if denoise.fil_opt.save_last == 0
                % save middle files
                brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, fil_calc, data_files{m}, denoise_infos.fil_opt.prefix_filter, denoise_infos.fil_opt.gzip_output, outdirs{m});
            end
            
            df_out = regress_chunk(fil_calc(t_mask, :), reg_mat_norm_use{n}(t_mask, :));
            brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, df_out, data_files{m}, [denoise_infos.fil_opt.prefix_reg, T_mat_info{n}, denoise_infos.fil_opt.prefix_filter], denoise_infos.fil_opt.gzip_output, outdirs{m});
        elseif denoise_infos.fil_opt.reg_only == 1
            % regress only
            df_out = regress_chunk(vol_calc(t_mask, :), reg_mat_norm_use{n}(t_mask, :));
            brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, df_out, data_files{m}, [denoise_infos.fil_opt.prefix_reg, T_mat_info{n}], denoise_infos.fil_opt.gzip_output, outdirs{m});
        elseif denoise_infos.fil_opt.fil_only == 1
            % filter only
            % do not loop if it's only filter
            if n == 1
                df_out = filter_chunk(vol_calc, denoise_infos.fil_opt.lower_cutoff, denoise_infos.fil_opt.upper_cutoff, denoise_infos.fil_opt.tr);
                brant_save_untouch_nifti_mask(nii_hdr, wb_img_ind, t_mask, df_out, data_files{m}, denoise_infos.fil_opt.prefix_filter, denoise_infos.fil_opt.gzip_output, outdirs{m});
            end
        else
            error('Unknown process!');
        end
        clear('df_out', 'res_calc', 'fil_calc');
    end
    clear('vol_calc');
end

 % handle output prefix to next stage
if numel(T_mat_info) > 1
    gs_str = sprintf('[%s+%s]', T_mat_info{1}, T_mat_info{2});
elseif numel(T_mat_info) == 1
    gs_str = T_mat_info{1};
else
    gs_str = '';
end

if denoise_infos.fil_opt.reg_filter == 1
    end_prefix = [denoise_infos.fil_opt.prefix_filter, denoise_infos.fil_opt.prefix_reg, gs_str];
elseif denoise_infos.fil_opt.filter_reg == 1
    end_prefix = [denoise_infos.fil_opt.prefix_reg, gs_str, denoise_infos.fil_opt.prefix_filter];
elseif denoise_infos.fil_opt.reg_only == 1
    end_prefix = [denoise_infos.fil_opt.prefix_reg, gs_str];
elseif denoise_infos.fil_opt.fil_only == 1
    end_prefix = denoise_infos.fil_opt.prefix_filter;
else
    error('You shall not pass!');
end

function vol_res = regress_chunk(vol_calc, reg_mat)

int_array = brant_get_intervals(1, size(vol_calc, 2), 128);
vol_res = zeros(size(vol_calc), 'single');
for n = 1:size(int_array, 1)
    ind_vec = int_array(n, 1):int_array(n, 2);
    beta_vol = reg_mat \ vol_calc(:, ind_vec);
    vol_res(:, ind_vec) = vol_calc(:, ind_vec) - reg_mat * beta_vol;
end

function fil_calc = filter_chunk(vol_calc, filter_lower, filter_upper, filter_tr)

int_array = brant_get_intervals(1, size(vol_calc, 2), 1024);
fil_calc = zeros(size(vol_calc), 'single');
for n = 1:size(int_array, 1)
    ind_vec = int_array(n, 1):int_array(n, 2);
    fil_calc(:, ind_vec) = brant_Filter_FFT_Butterworth(vol_calc(:, ind_vec), filter_lower, filter_upper, 1 / filter_tr, 0);
end

function full_mat = full_regression_matrix(raw_mat, inds, mat_str)

full_mat = [];
if inds.(mat_str) == 1
    full_mat = [full_mat, raw_mat];
end

if inds.([mat_str, '_square']) == 1
    full_mat = [full_mat, raw_mat .^ 2];
end

if inds.([mat_str, '_prime']) == 1
    full_mat = [full_mat, [zeros(1, size(raw_mat, 2)); diff(raw_mat)]];
end

if inds.([mat_str, '_prime_square']) == 1
    full_mat = [full_mat, [zeros(1, size(raw_mat, 2)); diff(raw_mat)] .^ 2];
end

if inds.([mat_str, '_prep']) == 1
    full_mat = [full_mat, [zeros(1, size(raw_mat, 2)); raw_mat(1:end-1, :)]];
end

if inds.([mat_str, '_prep_square']) == 1
    full_mat = [full_mat, [zeros(1, size(raw_mat, 2)); raw_mat(1:end-1, :)] .^ 2];
end

function [wb_img_ind, gs_img_ind, wm_img_ind, csf_img_ind] = load_masks(mask_files, mask_info, mask_thrs)

% find selected masks
mask_info_raw = {'whole brain mask'; 'global signal mask'; 'white matter mask'; 'csf mask'};
mask_inds = cellfun(@(x) find(strcmpi(x, mask_info)), mask_info_raw, 'UniformOutput', false);

% load masks
wb_img_ind = load_mask_to_ind(mask_inds{1}, mask_files, mask_thrs);
gs_img_ind = load_mask_to_ind(mask_inds{2}, mask_files, mask_thrs);
wm_img_ind = load_mask_to_ind(mask_inds{3}, mask_files, mask_thrs);
csf_img_ind = load_mask_to_ind(mask_inds{4}, mask_files, mask_thrs);

if ~isempty(wb_img_ind)
    if ~isempty(gs_img_ind)
        gs_img_ind = gs_img_ind & wb_img_ind;
    end
    if ~isempty(wm_img_ind)
        wm_img_ind = wm_img_ind & wb_img_ind;
    end
    if ~isempty(csf_img_ind)
        csf_img_ind = csf_img_ind & wb_img_ind;
    end
end

function mask_img_ind = load_mask_to_ind(mask_ind, mask_file, thr)

if isempty(mask_ind)
    mask_img_ind = [];
else
    mask_nii = load_untouch_nii_mod(mask_file{mask_ind});
    mask_img_ind = mask_nii.img > thr(mask_ind);
end

function mask_files_res = reslice_masks(data_files, ref_hdrs, mask_files, mask_res_type)
% mask_files_res: N*1 cell, in each cell stores masks for each subject,
% masks are stored in the same order as mask_info

if strcmpi(mask_res_type, 'nearest neighbour')
    res_type = 0;
else
    res_type = 4;
end

% reslice masks to data
mask_files_res = cell(size(mask_files));
fprintf('Checking and reslicing masks...\n');
for m = 1:numel(mask_files)
    mask_hdrs = cellfun(@(x) load_nii_hdr_mod(x, 'untouch0'), mask_files{m});
%     mask_hdrs = cellfun(@(x) load_nii_hdr_img_raw_c(x), mask_files{m});
    sts = brant_spm_check_orientations([ref_hdrs(m); mask_hdrs]);
    if sts % is true
        mask_files_res{m} = mask_files{m};
    else
        mask_files_res{m} = brant_reslice(data_files{m}, mask_files{m}, 'res_', res_type);
    end
end

function [mask_files, mask_info, mask_thrs] = check_masks(wk_dir, subj_paths, mask_opt, nm_pos)
% check masks validity

mask_files = {};
mask_thrs = [];
if mask_opt.space_comm == 1
    % process in common space
    mask_fields = {'mask_wb'; 'mask_gs'; 'mask_wm'; 'mask_csf'};
    mask_inds = cellfun(@(x) mask_opt.(x).ind == 1, mask_fields);
    
    if any(mask_inds)
        mask_strs = cellfun(@(x) mask_opt.(x).string, mask_fields, 'UniformOutput', false);
        mask_files = {mask_strs(mask_inds)};
        mask_thrs = repmat(0.5, size(mask_files{1}));

        ext_masks = cellfun(@(x) exist(x, 'file') == 2, mask_files{1});
        if any(~ext_masks)
            error([sprintf('%s\n', mask_files{1}{~ext_masks}), sprintf('Above mask(s) cannot be found!\n')]);
        end
        
        % copy to working directory
        cp_dir = fullfile(wk_dir, 'common_space_masks');
        if exist(cp_dir, 'dir') ~= 7
            mkdir(cp_dir);
        end
        for m = 1:numel(mask_files{1})
            fprintf('Copy %s to %s...\n', mask_files{1}{m}, cp_dir);
            copyfile(mask_files{1}{m}, cp_dir);
            [tmp, fn, ext] = brant_fileparts(mask_files{1}{m}); %#ok<*ASGLU>
            mask_files{1}{m} = fullfile(cp_dir, [fn, ext]);
        end
        fprintf('Maks copy finished.\n');
    end
else
    % process in individual space
    mask_fields = {'ft_wb'; 'ft_gs'; 'ft_wm'; 'ft_csf'};
    mask_inds = cellfun(@(x) mask_opt.(x).ind == 1, mask_fields);
    
    if any(mask_inds)
        mask_strs = cellfun(@(x) mask_opt.(x).string, mask_fields, 'UniformOutput', false);
        mask_files_tmp = cellfun(@(x) batch_search_files(subj_paths, x, nm_pos, 1), mask_strs(mask_inds), 'UniformOutput', false);
        mask_files = arrayfun(@(x) [mask_files_tmp{1}(x); mask_files_tmp{2}(x); mask_files_tmp{3}(x); mask_files_tmp{4}(x)],...
                                    1:numel(subj_paths), 'UniformOutput', false);
        mask_thrs = cellfun(@(x) mask_opt.(x).thr, mask_fields(mask_inds));

        all_masks = cat(1, mask_files{:});
        ext_masks = cellfun(@(x) exist(x, 'file') == 2, all_masks);
        if any(~ext_masks)
            error([sprintf('%s\n', all_masks{~ext_masks}), sprintf('Above mask(s) cannot be found!\n')]);
        end
    end
end

mask_info_raw = {'whole brain mask'; 'global signal mask'; 'white matter mask'; 'csf mask'};
mask_info = mask_info_raw(mask_inds);


function [nifti_list, subj_ids] = batch_search_files(datadirs, filetype, nm_pos, is4d)

data_input.nm_pos = nm_pos;
data_input.dirs = datadirs;
data_input.is4d = is4d;
data_input.filetype = filetype;
data_input.check_tps_ind = 0;
[nifti_list, subj_ids] = brant_get_subjs(data_input);