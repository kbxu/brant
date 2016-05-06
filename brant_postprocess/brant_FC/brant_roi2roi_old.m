function brant_roi2roi(jobman)

tc_dir = fullfile(jobman.out_dir,'mean_ts');
if exist(tc_dir, 'dir') ~= 7
    mkdir(tc_dir);
end

corr_dir =  fullfile(jobman.out_dir,'corr_ts');
if exist(corr_dir, 'dir') ~= 7
    mkdir(corr_dir);
end

[rois_vox, targetdir, roi_ids] = brant_get_rois(jobman, 'roi2roi'); %#ok<*NASGU,*ASGLU>

subjnum = size(jobman.subj_infos.subjs, 1);
roinum = numel(roi_ids);

if jobman.roi_multiple == 1 || jobman.roi_single == 1
    
    corr_r_tot = zeros(roinum, roinum, subjnum, 'single');
    
    if jobman.r2z == 1
        corr_z_tot = zeros(roinum, roinum, subjnum, 'single');
    end
    
    for m = 1:size(jobman.subj_infos.paths, 1)

        fprintf('\tSubject %d/%d %s\n', m, subjnum, jobman.subj_infos.subjs{m}{1});
        
        TC_total = brant_get_tc(jobman.subj_infos, jobman.timepoints, m);
        
        mean_ts = zeros([jobman.timepoints, roinum], 'single');
        for n = 1:roinum
            tc_tmp = zeros([jobman.timepoints, size(rois_vox{n}, 1)], 'single');
            for nn = 1:size(rois_vox{n}, 1)
                tc_tmp(:, nn) = squeeze(TC_total(rois_vox{n}(nn, 1), rois_vox{n}(nn, 2), rois_vox{n}(nn, 3), :));
            end
            mean_ts(:, n) = mean(tc_tmp, 2);
        end
        
        corr_r = corr(mean_ts);
        corr_r(eye(size(corr_r)) == 1) = 0;
        corr_r_tot(:, :, m) = corr_r;
        
       
        filename = fullfile(jobman.out_dir, 'mean_ts', ['mean_ts_', jobman.subj_infos.subjnames{m}, '.mat']);
        save(filename, 'roi_ids', 'mean_ts');
        
        filename = fullfile(jobman.out_dir, 'corr_ts', ['corr_r_', jobman.subj_infos.subjnames{m}, '.mat']);
        save(filename, 'roi_ids', 'corr_r');
        
        if jobman.r2z == 1
            corr_z = 0.5 .* log((1 + corr_r) ./ (1 - corr_r));
            corr_z_tot(:, :, m) = corr_z;
        
            filename = fullfile(jobman.out_dir, 'corr_ts', ['corr_z_', jobman.subj_infos.subjnames{m}, '.mat']);
            save(filename, 'roi_ids', 'corr_z');
        end
    end
    
    save(fullfile(jobman.out_dir, 'corr_r_tot.mat'), 'corr_r_tot');
    
    if jobman.r2z == 1
        save(fullfile(jobman.out_dir, 'corr_z_tot.mat'), 'corr_z_tot');
    end
    
else
    error('ONLY two type of roi lists are allowed!\n');
end

fprintf('\n\tALL finished.\n\n');
