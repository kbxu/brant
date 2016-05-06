function brant_roi_script(jobman)

% nifti_list: cell of nifti files, e.g. nifti_list{1} = 'fdwrabrant_4D.nii'
% or, nifti_list{1}{1} = 'fdwrabrant_3D_001.nii', nifti_list{1}{2} = 'fdwrabrant_3D_002.nii'
% rois: cell of roi files
% subj_ids: cell of subject names or unique tokens
% mask: string of mask file
% out_pval: 0 or 1, output p value for correlation
% our_dir: string of ouput directory
% jobman_str: could be either 'roi2roi' or 'roi2wb'. In script, can be both --> {'roi2roi', 'roi2wb'}
% updated by kb at 2015-03-16

roi_wise_ind = jobman.roi_wise;
rois = jobman.rois;
mask = jobman.mask{1};
out_dir = jobman.out_dir{1};
ext_mean_ind = jobman.ext_mean;
roi2roi_ind = jobman.roi2roi;
roi2wb_ind = jobman.roi2wb;
partial_ind = jobman.partialcorr;
pearson_ind = jobman.pearsoncorr;
roi_info_fn = jobman.roi_info{1};

vs_thres = jobman.roi_thres; % threshold of voxel size


if isempty(jobman.mask)
    error(sprintf('\tA whole brain mask is expected!\n'));
end

if isempty(jobman.out_dir)
    error(sprintf('\tPlease specify an output directories!\n'));
end

if isempty(jobman.input_nifti.dirs{1})
    error(sprintf('\tPlease input data directories!\n'));
end

if any([roi2roi_ind, roi2wb_ind, ~roi_wise_ind])
    if partial_ind == 1
        corr_type = 'partial_correlation';
        corrfun = @partialcorr;
    elseif pearson_ind == 1
        corr_type = 'pearson_correlation';
        corrfun = @corr;
    else
        error('Error: wrong type of correlation!');
    end
else
    error('Error input!');
end

if roi_wise_ind == 1
    if isempty(jobman.rois{1})
        error(sprintf('\tPlease input one roi file!\n')); %#ok<*SPERR>
    end
    
    if all([ext_mean_ind, roi2roi_ind, roi2wb_ind] == 0)
        error('No calculations.')
    end
end

% mask roi files
mask_nii = load_nii(mask);
size_mask = mask_nii.hdr.dime.dim(2:4);
mask_bin = mask_nii.img > 0.5;
mask_ind = find(mask_bin);

if roi_wise_ind == 1
    roi_show_msg = 1;
    [rois_inds, rois_str, rois_tag] = brant_get_rois(rois, size_mask, roi_info_fn, roi_show_msg);
    if numel(rois_str) == 1 && roi2roi_ind == 1
        warning('Only one roi tag is detected, roi2roi correlation will not be calculated!');
        roi2roi_ind = 0;
    end
    
    
    % num_vox = cellfun(@(x) sum(x(:)), rois_inds);
    % for n = 1:numel(rois_str)
    %     fprintf('The number of voxels within brain mask labeled as %s is %d\n', rois_str{n}, num_vox(n));
    % end
    %
    % if any(num_vox == 0)
    %     error_str = sprintf('The following ROIs tagged by number didn''t survive the mask!');
    %     error([error_str, sprintf('\n%d', rois_tag(num_vox == 0))]);
    % end
    
    fprintf('\n\tThe brain mask will be applied for ROI masks.\n\n')
    mask_good_binary = zeros(size_mask);
    mask_good_binary(mask_ind) = 1:numel(mask_ind);
    mask_good_binary_nzero = mask_good_binary ~= 0;
    rois_inds_new = cellfun(@(x) mask_good_binary(x & mask_good_binary_nzero), rois_inds, 'UniformOutput', false);
    
    num_vox_raw = cellfun(@(x) sum(x(:)), rois_inds);
    num_vox = cellfun(@numel, rois_inds_new);
    
    diary(fullfile(out_dir, 'roi_history.txt'));
    diff_ind = find(num_vox_raw ~= num_vox);
    if any(diff_ind)
        fprintf('\n');
        arrayfun(@(x, y, z) fprintf('\tThe changed roi size (masked) marked as %s is %d (raw %d)\n', x{1}, y, z), rois_str(diff_ind), num_vox(diff_ind), num_vox_raw(diff_ind));
    end
    
    % bad rois delete for tmp
    if vs_thres > 0
        fprintf('\n\tROI size smaller than 10 will be excluded!\n');
        bad_roi_ind = num_vox < vs_thres;
        arrayfun(@(x, y, z, k) fprintf('\tThe excluded roi''s (tag:%d, %s) voxelsize is %d (raw %d)\n', x, y{1}, z, k), rois_tag(bad_roi_ind), rois_str(bad_roi_ind), num_vox(bad_roi_ind), num_vox_raw(bad_roi_ind));
        
        rois_inds = rois_inds(~bad_roi_ind);
        rois_str = rois_str(~bad_roi_ind);
        rois_tag = rois_tag(~bad_roi_ind);
        rois_inds_new = rois_inds_new(~bad_roi_ind);
    end
    diary('off');
    
    num_roi = numel(rois_inds);
    corr_ind = triu(true(num_roi, num_roi), 1);
    num_corr = num_roi * (num_roi - 1) / 2;
    
    if num_roi == 0
        error('No matched roi can be found for the following calculation!');
    end
    
    % ept_ind = cellfun(@isempty, rois_inds_new);
    % if any(ept_ind)
    %     error_str = sprintf('ROI tagged by following numbers didn''t survive the brain mask!');
    %     error([sprintf(error_str), sprintf('\n%d', rois_tag(ept_ind))]);
    % end
else
    rois_str = '';
    rois_tag = []; %#ok<NASGU>
    num_roi = numel(mask_ind);
    corr_ind = triu(true(num_roi, num_roi), 1);
    num_corr = num_roi * (num_roi - 1) / 2;
    int_array = brant_get_intervals(1, num_corr, min(5000000, num_corr));
    num_pieces = size(int_array, 1);
    fprintf('\tPerforming voxel-wise correlation!\n\tLarge memory required!');
end

[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs)
        out_dir_tmp = fullfile(out_dir, split_strs{mm});
    else
        out_dir_tmp = out_dir;
    end
    jobman.input_nifti.filetype = split_prefix{mm};
    
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    num_subj = numel(nifti_list);
    
    % test for voxel size 20160425
    if jobman.input_nifti.is4d == 1;
        sample_hdr = load_nii_hdr(nifti_list{1});
    else
        sample_hdr = load_nii_hdr(nifti_list{1}{1});
    end
    brant_spm_check_orientations([mask_nii.hdr, sample_hdr]);
    
    
    if roi_wise_ind == 1
        % roi-wise correlation
        if ext_mean_ind == 1
            out_ts = fullfile(out_dir_tmp, 'mean_ts');
            
            if exist(out_ts, 'dir') ~= 7
                mkdir(out_ts);
            end
        end
        
        if roi2wb_ind == 1
            
            out_roi2wb_r = fullfile(out_dir_tmp, ['roi2wb_r_', corr_type]);
            out_roi_dirs_r = cellfun(@(x) fullfile(out_roi2wb_r, x), rois_str, 'UniformOutput', false);
            for m = 1:numel(out_roi_dirs_r)
                if exist(out_roi_dirs_r{m}, 'dir') ~= 7
                    mkdir(out_roi_dirs_r{m});
                end
            end
            
            out_roi2wb_z = fullfile(out_dir_tmp, ['roi2wb_z_', corr_type]);
            out_roi_dirs_z = cellfun(@(x) fullfile(out_roi2wb_z, x), rois_str, 'UniformOutput', false);
            for m = 1:numel(out_roi_dirs_z)
                if exist(out_roi_dirs_z{m}, 'dir') ~= 7
                    mkdir(out_roi_dirs_z{m});
                end
            end
        end
        
        if roi2roi_ind == 1
            %             corr_r_tot = zeros([num_roi, num_roi, num_subj], 'double');
            %             corr_z_tot = zeros([num_roi, num_roi, num_subj], 'double');
            %             corr_p_tot = ones([num_roi, num_roi, num_subj]);
            
            %             corr_r_tot = zeros([num_subj, num_corr], 'double');
            %             corr_z_tot = zeros([num_subj, num_corr], 'double');
            %             corr_p_tot = ones([num_subj, num_corr]);
            
            out_roi2roi = fullfile(out_dir_tmp, ['roi2roi_', corr_type]);
            out_mat = fullfile(out_roi2roi, ['corr_mats_', corr_type]);
            if exist(out_mat, 'dir') ~= 7
                mkdir(out_mat);
            end
        end
        
    else
        % voxel wise correlation
        %         corr_z_tot = zeros([num_roi, num_roi, num_subj], 'single');
        %         corr_z_tot = zeros([num_subj, num_roi * (num_roi - 1) / 2], 'single');
        
        out_vox2vox = fullfile(out_dir_tmp, ['vox2vox_', corr_type]);
        out_mat = fullfile(out_vox2vox, ['corr_mats_', corr_type]);
        if exist(out_mat, 'dir') ~= 7
            mkdir(out_mat);
        end
    end
    
    for m = 1:num_subj
        
        [data_2d_mat, data_tps, nii_hdr] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});
        brant_spm_check_orientations([mask_nii.hdr, nii_hdr]);
        
        if roi_wise_ind == 0
            fprintf('\tCalculating voxel - voxel correlation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            
            tic
            corr_r_tmp = corrfun(data_2d_mat);
            corr_r_vec = corr_r_tmp(corr_ind);
            clear('corr_r_tmp', 'data_2d_mat');
            corr_z_vec = 0.5 .* log((1 + corr_r_vec) ./ (1 - corr_r_vec));
            clear('corr_r_vec');
            
            fprintf('\tCalculating correlation finished in %.2f s\n', toc);% toc
            out_mat_tmp = fullfile(out_mat, subj_ids{m});
            if exist(out_mat_tmp, 'dir') ~= 7, mkdir(out_mat_tmp); end
            
            save_pos.num_pieces = num_pieces;
            for n = 1:num_pieces
                save_pos.n = n;
                fprintf('\t%s: saving results %d/%d...\n', subj_ids{m}, n, save_pos.num_pieces);
                corr_z = corr_z_vec(int_array(n, 1):int_array(n, 2)); %#ok<NASGU>
                save(fullfile(out_mat_tmp, num2str(n, 'corr_%04d.mat')), 'corr_z', 'num_roi', 'rois_str', 'rois_tag', 'corr_type', 'save_pos');
            end
            clear('corr_z', 'corr_z_vec');
            fprintf('\tSaving files finished in %.2f s\n\n', toc);% toc
        else
            
            % roi wise calculation
            ts_rois = zeros([data_tps, num_roi], 'double');
            for n = 1:num_roi
                ts_rois(:, n) = nanmean(data_2d_mat(:, rois_inds_new{n}), 2);
            end
            
            if ext_mean_ind == 1
                save(fullfile(out_ts, [subj_ids{m}, '_ts.mat']), 'ts_rois');
            end
            
            if roi2roi_ind == 1
                
                fprintf('\tCalculating roi - roi correlation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
                
                [corr_r, corr_p] = corrfun(ts_rois); %#ok<ASGLU>
                
%                 corr_r = corr_r_mat(corr_ind);
%                 corr_p = corr_p_mat(corr_ind);
                corr_z = 0.5 .* log((1 + corr_r) ./ (1 - corr_r)); %#ok<NASGU>
                save(fullfile(out_mat, [subj_ids{m}, '_corr.mat']), 'corr_r', 'corr_z', 'num_roi', 'corr_p', 'rois_str', 'rois_tag', 'corr_type');
                clear('corr_r', 'corr_p', 'corr_z');
            end
            
            
            mask_wb_by_p = 0; % use in spacial cases
            if roi2wb_ind == 1
                for n = 1:num_roi
                    fprintf('\tCalculating roi - whole brain correlation for subject %d/%d %s, roi %s\n', m, num_subj, subj_ids{m}, rois_str{n});
                    
                    if partial_ind == 1
                        [corr_r_wb, corr_p_wb] = partialcorr(ts_rois(:, n), data_2d_mat, ts_rois(:, 1:n-1,n+1:end));
                    elseif pearson_ind == 1
                        [corr_r_wb, corr_p_wb] = corr(ts_rois(:, n), data_2d_mat);
                    end
                    
                    if mask_wb_by_p == 1
                        corr_r_wb(corr_p_wb > 0.001) = 0;
                    end
                    
                    corr_out = zeros(size_mask, 'single');
                    corr_out(mask_ind) = corr_r_wb;
                    filename = fullfile(out_roi_dirs_r{n}, ['corr_R_', subj_ids{m}, '.nii']);
                    nii = make_nii(corr_out, mask_nii.hdr.dime.pixdim(2:4), mask_nii.hdr.hist.originator(1:3), [], corr_type);
                    save_nii(nii, filename);
                    
                    corr_out = zeros(size_mask, 'single');
                    corr_z_wb = 0.5 .* log((1 + corr_r_wb) ./ (1 - corr_r_wb));
                    corr_out(mask_ind) = corr_z_wb;
                    filename = fullfile(out_roi_dirs_z{n}, ['corr_Z_', subj_ids{m}, '.nii']);
                    nii = make_nii(corr_out, mask_nii.hdr.dime.pixdim(2:4), mask_nii.hdr.hist.originator(1:3), [], corr_type);
                    save_nii(nii, filename);
                    
                    clear('corr_out', 'corr_r_wb', 'corr_p_wb', 'corr_z_wb');
                end
            end
        end
        fprintf('\n');
        clear('data_2d_mat');
    end
    
    %     if roi_wise_ind == 1
    %         if roi2roi_ind == 1
    %             save(fullfile(out_roi2roi, 'roi2roi_tot.mat'), 'corr_r_tot', 'corr_z_tot', 'num_roi', 'corr_p_tot', 'rois_str', 'rois_tag', 'subj_ids', 'corr_type', '-v7.3');
    %             clear('corr_r_tot', 'corr_z_tot', 'corr_p_tot');
    %         end
    %     end
    
end

fprintf('\tFinished!\n');
