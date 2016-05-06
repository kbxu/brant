function brant_cnv_mats_corr_tmp

oo = importdata('D:\SZ_scripts\power_264_FC\corr_mat.txt', '\n');
out_dir = 'D:\SZ_scripts\power_264_FC_tot';

for m = 1:numel(oo)
   disp(oo{m});
   cen_nm = regexp(oo{m}, filesep, 'split');
   mats = dir(fullfile(oo{m},'*.mat'));
   mats_full = arrayfun(@(x) fullfile(oo{m}, x.name), mats, 'UniformOutput', false);
   disp(mats_full);
   
   sam_mat = load(mats_full{1});
   num_subj = numel(mats);
   rois_str = sam_mat.rois_str;
   num_roi = numel(rois_str);
   
   subj_ids = cell(num_subj, 1);
   corr_z_tot = zeros([num_roi, num_roi, num_subj], 'single');
   corr_r_tot = zeros([num_roi, num_roi, num_subj], 'single');
   
   if isfield(sam_mat, 'corr_p')
        corr_p_tot = zeros([num_roi, num_roi, num_subj], 'single');
   end
   for n = 1:numel(mats)
       subj_ids{n} = strrep(mats(n).name, '_corr.mat', '');
       mat_tmp = load(mats_full{n});
       
       corr_z_tot(:, :, n) = mat_tmp.corr_z;
       corr_r_tot(:, :, n) = mat_tmp.corr_r;
       if isfield(sam_mat, 'corr_p')
            corr_p_tot(:, :, n) = mat_tmp.corr_p;
       end
   end
   
   if isfield(sam_mat, 'corr_p')
        save(fullfile(out_dir, [cen_nm{4}, '_roi2roi_tot.mat']), 'corr_r_tot', 'corr_z_tot', 'corr_p_tot', 'rois_str', 'subj_ids');
    else
        save(fullfile(out_dir, [cen_nm{4}, '_roi2roi_tot.mat']), 'corr_r_tot', 'corr_z_tot', 'rois_str', 'subj_ids');
    end
end
