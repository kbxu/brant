function brant_roi2wb(jobman)


[rois, targetdir] = brant_get_rois(jobman, 'roi2wb');
n_subjs = size(jobman.subj_infos.paths, 1);
mask_hdr = jobman.subj_infos.mask_hdr;
datatype = 16;

for m = 1:n_subjs
    tic;
    fprintf('\tCalculating correlations for subject %d/%d %s\n\t', m, n_subjs, jobman.subj_infos.subjnames{m});
    TC_total = brant_get_tc(jobman.subj_infos, jobman.timepoints, m);

    %%% The time series of ROI
    for n = 1:length(rois)
        roi_tc_tmp = zeros([jobman.timepoints, size(rois{n}, 1)], 'single');
        for nn = 1:size(rois{n}, 1)
            roi_tc_tmp(:, nn) = squeeze(TC_total(rois{n}(nn, 1), rois{n}(nn, 2), rois{n}(nn, 3), :));
        end
        TC_ROI = mean(roi_tc_tmp, 2);
        
        % compute the correlation coeficients
        [cor_R, cor_Z] = brant_roi_fc(TC_ROI, jobman.subj_infos.mask_ind, TC_total);
        
        if jobman.r2z == 1
            filename = fullfile(targetdir{n}, ['cor_Z_', jobman.subj_infos.subjnames{m}, '.nii']);
            nii = make_nii(cor_Z, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3), datatype); 
            save_nii(nii, filename);
        else
            filename = fullfile(targetdir{n}, ['cor_R_', jobman.subj_infos.subjnames{m}, '.nii']);
            nii = make_nii(cor_R, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3), datatype); 
            save_nii(nii, filename);
        end
    end
    fprintf('\tFinished subject %d/%d %s\n\t', m, n_subjs, jobman.subj_infos.subjnames{m});
    toc;
end
fprintf('\n\tALL finished.\n');
