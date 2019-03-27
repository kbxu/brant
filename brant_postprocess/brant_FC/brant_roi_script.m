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


brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');


roi_wise_ind = jobman.roi_wise;
rois = jobman.rois;
mask_fn = jobman.input_nifti.mask{1};
outdir = jobman.out_dir{1};
ext_mean_ind = jobman.ext_mean;
roi2roi_ind = jobman.roi2roi;
roi2wb_ind = jobman.roi2wb;
partial_ind = jobman.partialcorr;
% pearson_ind = jobman.pearsoncorr;
roi_info_fn = jobman.roi_info{1};
cs_thr = jobman.roi_thres; % threshold of voxel size

sm_ind = jobman.sm_ind;
sm_fwhm = jobman.fwhm;

% if any([roi2roi_ind, roi2wb_ind])
if (partial_ind == 1)
    corr_type = 'partial_correlation';
    corrfun = @partialcorr;
else % if pearson_ind == 1
    corr_type = 'pearson_correlation';
    corrfun = @corr;
end
% end

if (roi_wise_ind == 1)
    brant_check_empty(jobman.rois{1}, '\tPlease input one roi file!\n');
    
    if all([ext_mean_ind, roi2roi_ind, roi2wb_ind] == 0)
        warning('No calculations has been done.\n');
        return;
    end
end

if (exist(outdir, 'dir') ~= 7)
    mkdir(outdir);
end

% assuming different input filetypes use same nifti header
[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);
% take a sample of data
jobman.input_nifti.filetype = split_prefix{1};
nifti_list = brant_get_subjs(jobman.input_nifti);
% check for ROI and mask with one of the data
[unused1, unused2, unused3, rois_resliced] = brant_check_load_mask(rois{1}, nifti_list{1}, outdir); %#ok<ASGLU>
[mask_hdr, mask_ind, size_mask, mask_new] = brant_check_load_mask(mask_fn, nifti_list{1}, outdir);

if (roi_wise_ind == 1)
    % call external functoin
    jobman_tmp.lab_c = 1;
    jobman_tmp.sep_c = 0;
    jobman_tmp.mask_in{1} = mask_new;
    jobman_tmp.cs_thr = cs_thr;
    jobman_tmp.template_img{1} = rois_resliced;
    jobman_tmp.template_info{1} = roi_info_fn;
    jobman_tmp.out_dir{1} = outdir;
    jobman_tmp.from_roi_calc = 1;
    
    roi_info_out = brant_roi_coordinates(jobman_tmp);
    rois_str = roi_info_out.rois_str;
    rois_tag = roi_info_out.rois_tag;
    rois_inds_new = roi_info_out.rois_inds_new;
    
    num_roi = numel(rois_inds_new);
    
    % output new roi file
    roi_new_img = zeros(size_mask);
    for m = 1:num_roi
        roi_new_img(mask_ind(rois_inds_new{m})) = rois_tag(m);
    end
    nii = make_nii(roi_new_img, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3), [], 'roi_new');
    [pth, fn, ext] = fileparts(rois_resliced); %#ok<ASGLU>
    filename = fullfile(outdir, ['masked_', fn, ext]);
    save_nii(nii, filename);
    
    roi_info_new = [num2cell(rois_tag), rois_str];
    brant_write_csv([filename, '.txt'], roi_info_new)
    %
    
    corr_ind = triu(true(num_roi, num_roi), 1);
    if (num_roi == 0)
        error('No matched roi can be found for the following calculation!');
    end
else
    rois_str = '';
    rois_tag = [];
    num_roi = numel(mask_ind);
    corr_ind = triu(true(num_roi, num_roi), 1);
    num_corr = num_roi * (num_roi - 1) / 2;
    int_array = brant_get_intervals(1, num_corr, min(5000000, num_corr));
    num_pieces = size(int_array, 1);
    fprintf('\tPerforming voxel-wise correlation!\n\tLarge memory required!');
end



for mm = 1:numel(split_prefix)
    
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end
    
    jobman.input_nifti.filetype = split_prefix{mm};
    [nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);
    num_subj = numel(nifti_list);
        
    if (roi_wise_ind == 1)
        % roi-wise correlation
        if (ext_mean_ind == 1)
            out_ts = brant_make_outdir(out_dir_tmp, {'mean_ts'});
        end
        
        if (roi2roi_ind == 1)
            out_mat_r = brant_make_outdir(out_dir_tmp, {['roi2roi_r_', corr_type]});
            out_mat_z = brant_make_outdir(out_dir_tmp, {['roi2roi_z_', corr_type]});
        end
        
        if (roi2wb_ind == 1)
            out_roi_dirs_r = brant_make_outdir(fullfile(out_dir_tmp, ['roi2wb_r_', corr_type]), rois_str);
            out_roi_dirs_z = brant_make_outdir(fullfile(out_dir_tmp, ['roi2wb_z_', corr_type]), rois_str);
        end
    else
        % voxel wise correlation
        out_mat = brant_make_outdir(out_dir_tmp, {['vox2vox_', corr_type]});
    end
    
    for m = 1:num_subj
        
        if all([roi2roi_ind, roi2wb_ind] == 0)
            fprintf('\tSubject %d/%d %s\n', m, num_subj, subj_ids{m});
        end
        
        [data_2d_mat, data_tps] = brant_4D_to_mat_new(nifti_list{m}, mask_ind, 'mat', subj_ids{m});        
        if (roi_wise_ind == 0)
            fprintf('\tCalculating voxel - voxel correlation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
            
            tic
            corr_r_tmp = corrfun(data_2d_mat);
            corr_r_vec = corr_r_tmp(corr_ind);
            clear('corr_r_tmp', 'data_2d_mat');
            corr_z_vec = 0.5 .* log((1 + corr_r_vec) ./ (1 - corr_r_vec));
            clear('corr_r_vec');
            
            fprintf('\tVoxel-wise correlation finished in %.2f s\n', toc);% toc
            out_mat_tmp = fullfile(out_mat{1}, subj_ids{m});
            if (exist(out_mat_tmp, 'dir') ~= 7), mkdir(out_mat_tmp); end
            
            save_pos.num_pieces = num_pieces;
            for n = 1:num_pieces
                save_pos.n = n;
                fprintf('\t%s: saving results %d/%d...\n', subj_ids{m}, n, save_pos.num_pieces);
                corr_z = corr_z_vec(int_array(n, 1):int_array(n, 2));
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
            
            if (ext_mean_ind == 1)
                brant_write_csv(fullfile(out_ts{1}, [subj_ids{m}, '_ts.csv']), num2cell(ts_rois));
            end
            
            if (roi2roi_ind == 1)                
                fprintf('\tCalculating roi - roi correlation for subject %d/%d %s\n', m, num_subj, subj_ids{m});
                corr_r = corrfun(ts_rois);
                corr_z = 0.5 .* log((1 + corr_r) ./ (1 - corr_r));                
                dlmwrite(fullfile(out_mat_r{1}, [subj_ids{m}, '_corr_r.txt']), corr_r);
                dlmwrite(fullfile(out_mat_z{1}, [subj_ids{m}, '_corr_z.txt']), corr_z);
                clear('corr_r', 'corr_z');
            end
            
            mask_wb_by_p = 0; % use in certain cases
            if (roi2wb_ind == 1)
                for n = 1:num_roi
                    fprintf('\tCalculating roi - whole brain correlation for subject %d/%d %s, roi %s\n', m, num_subj, subj_ids{m}, rois_str{n});
                    
                    if (mask_wb_by_p == 1)
                        if (partial_ind == 1)
                            [corr_r_wb, corr_p_wb] = partialcorr(ts_rois(:, n), data_2d_mat, ts_rois(:, 1:n-1,n+1:end));
                        else % if pearson_ind == 1
                            [corr_r_wb, corr_p_wb] = corr(ts_rois(:, n), data_2d_mat);
                        end
                        
                        corr_r_wb(corr_p_wb > 0.001) = 0;
                    else
                        if (partial_ind == 1)
                            corr_r_wb = partialcorr(ts_rois(:, n), data_2d_mat, ts_rois(:, 1:n-1,n+1:end));
                        else % if pearson_ind == 1
                            corr_r_wb = corr(ts_rois(:, n), data_2d_mat);
                        end
                    end
                    
                    % corr_r
                    corr_out = nan(size_mask, 'single');
                    corr_out(mask_ind) = corr_r_wb;
                    nii = make_nii(corr_out, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3), [], ['rval_', corr_type]);
                    save_nii(nii, fullfile(out_roi_dirs_r{n}, [subj_ids{m}, '_corr_r.nii']));
                    
                    % corr_z
                    corr_out = nan(size_mask, 'single');
                    corr_z_wb = 0.5 .* log((1 + corr_r_wb) ./ (1 - corr_r_wb));
                    corr_out(mask_ind) = corr_z_wb;
                    nii = make_nii(corr_out, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3), [], ['zval_', corr_type]);
                    save_nii(nii, fullfile(out_roi_dirs_z{n}, [subj_ids{m}, '_corr_z.nii']));
                    
                    clear('corr_out', 'corr_r_wb', 'corr_p_wb', 'corr_z_wb');
                end
            end
        end
        fprintf('\n');
        clear('data_2d_mat');
    end
    
    if ((roi_wise_ind == 1) && (sm_ind == 1) && (roi2wb_ind == 1))
        for n = 1:num_roi
            brant_smooth_rst({out_roi_dirs_r{n}; out_roi_dirs_z{n}}, '*.nii', sm_fwhm, num2str(sm_fwhm,'s%d%d%d'), 1);
        end
    end
end

fprintf('\tFinished!\n');
