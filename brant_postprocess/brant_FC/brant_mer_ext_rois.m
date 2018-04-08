function brant_mer_ext_rois(jobman)
% merge or extract rois

mer_ind = jobman.merge;
ext_ind = jobman.extract;

extract_info.rois = jobman.rois;
extract_info.roi_info = jobman.roi_info;
extract_info.roi_vec = jobman.roi_vec;

merge_info = jobman.input_nifti;
merge_info.out_fn = jobman.out_fn;

out2single = jobman.out2single;
output_dir = jobman.out_dir{1};

if mer_ind == 1
    [nifti_list, subj_ids] = brant_get_subjs(merge_info);
%     %
%     spm_vols_input = cellfun(@spm_vol, nifti_list);
%     spm_check_orientations(spm_vols_input);
%     
%     fprintf('\n\tMerging ROI files...\n');
%     fprintf('\n\tBRANT uses abs(intensity) > 0.5 to binarize the input rois.\n');
%     input_sum = single(0); input_num = single(0);
%     for m = 1:numel(spm_vols_input)
%         input_img_tmp = spm_read_vols(spm_vols_input(m));
%         input_bin = abs(input_img_tmp) > 0.5;
%         input_sum = input_sum + single(input_bin);
%         input_num = input_num + single(input_bin) * m;
%     end
%     clear('input_img_tmp');
%     
%     overlap_mask = input_sum > 1;
%     if any(overlap_mask(:))
%         warning('on');
%         warning(sprintf('\n\tOverlap has been detected among the input files!\n\tOverlaping areas will be set to 0!\n')); %#ok<SPWRN>
%         input_num(overlap_mask) = 0;
%     end
%     
%     out_vol = spm_vols_input(1);
    
    ref_hdrs = cellfun(@(x) load_nii_hdr_mod(x, 'untouch0'), nifti_list);
    fprintf('\tChecking data orientations and resolutions, if an error came out, please check/reslice data before preprocess!\n');
    brant_spm_check_orientations(ref_hdrs);
    fprintf('\tInput data are well arranged!\n');

    fprintf('\n\tMerging ROI files...\n');
    fprintf('\tBRANT uses abs(intensity) > 0.5 to binarize the input rois.\n');
    input_sum = single(0); input_num = single(0);
    for m = 1:numel(nifti_list)
        input_img_tmp = load_untouch_nii_mod(nifti_list{m});
        input_bin = abs(input_img_tmp.img) > 0.5;
        input_sum = input_sum + single(input_bin);
        input_num = input_num + single(input_bin) * m;
    end
    clear('input_img_tmp');
    
    overlap_mask = input_sum > 1;
    if any(overlap_mask(:))
        warning('on');
        warning(sprintf('\n\tOverlap has been detected among the input files!\n\tOverlaping areas will be set to 0!\n')); %#ok<SPWRN>
        input_num(overlap_mask) = 0;
    end
    
    out_vol = spm_vol(nifti_list{1});
    out_vol.fname = fullfile(output_dir, [merge_info.out_fn, '.nii']);
    out_vol.dt = [spm_type('float32'), spm_platform('bigend')];
    spm_write_vol(out_vol, input_num);
    
    fid = fopen(fullfile(output_dir, [merge_info.out_fn, '.txt']), 'wt');
    for m = 1:numel(subj_ids)
        fprintf(fid, '%d %s\n', m, subj_ids{m});
    end
    fclose(fid);
    
elseif ext_ind == 1
    
    fprintf('\n\tExtracting ROIs...\n');
    roi_full = load_untouch_nii(extract_info.rois{1});
    all_roi_inds = setdiff(roi_full.img(:), [0, NaN]);
    all_roi_inds = all_roi_inds(isfinite(all_roi_inds));
    
    if isa(all_roi_inds, 'float') && (numel(all_roi_inds) > 2000)
        error(sprintf(['Brant support at most 2000 roi indexes!\n',...
                       'Please check the data type of the input file and make sure it''s integer instead of float!\n',...
                       'Float file type may generate unwanted float numbers in the roi!'])); %#ok<SPERR>
    end
    
    roi_vec = extract_info.roi_vec;
    
    except_ind = setdiff(roi_vec, all_roi_inds);
    if any(except_ind)
        error('Index %d can not be found in the roi file!\n', except_ind);
    end
    
    % uses load_untouch_nii to load roi file
    [rois_inds, rois_str, roi_tags] = brant_get_rois(extract_info.rois, [], extract_info.roi_info{1}, 0, @load_untouch_nii);
    
    roi_ind_bp = arrayfun(@(x) find(x == roi_tags), roi_vec);
    if out2single == 0
        % output to seperated ROIs
        cla_input = class(roi_tags);
        roi_full.hdr.dime.glmax = 1;
        for m = 1:numel(roi_ind_bp)
            ind_tmp = roi_ind_bp(m);
            fprintf('Extract ROI index %d for %s.\n', roi_tags(ind_tmp), rois_str{ind_tmp});
            
            roi_full.img = eval([cla_input, '(rois_inds{ind_tmp})']);
            save_untouch_nii(roi_full, fullfile(output_dir, [rois_str{ind_tmp}, '.nii']));
        end
    else
        % output to single ROI file
        roi_full.hdr.dime.glmax = max(roi_vec);
        roi_full.hdr.dime.glmin = min(roi_vec);
        roi_full.img(:) = 0;
        for m = 1:numel(roi_ind_bp)
            ind_tmp = roi_ind_bp(m);
            roi_full.img(rois_inds{ind_tmp}) = roi_tags(ind_tmp);
        end
        
        [pth, fn, ext] = brant_fileparts(extract_info.rois{1});  %#ok<ASGLU>
        save_untouch_nii(roi_full, fullfile(output_dir, ['brant_extract_', fn, '.nii']));
        
        out_file = fullfile(output_dir, ['brant_extract_', fn, '.csv']);
        roi_info_cell = [arrayfun(@num2cell, roi_tags(roi_ind_bp)), rois_str(roi_ind_bp)];
        brant_write_csv(out_file, roi_info_cell);
    end
else
    error('Unknown Input!');
end

fprintf('\tFinished!\n')
