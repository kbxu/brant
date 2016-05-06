function corr_mat = brant_load_all_mats(input_mats)

corr_mat.rois_str = {};
corr_mat.subj_ids = {};
corr_mat.corr_r_tot = [];
corr_mat.corr_z_tot = [];
corr_mat.corr_p_tot = [];

for m = 1:numel(input_mats)
    fprintf('\tLoading %s...\n', input_mats{m});
    corr_mat_tmp = load(input_mats{m});
    
    if ~isempty(corr_mat.rois_str)
        first_rois_str = corr_mat_tmp.rois_str;
        if ~isequal(first_rois_str, corr_mat_tmp.rois_str)
            error('ROI names should be equal!');
        end
    end
    
    corr_mat.subj_ids = cat(1, corr_mat.subj_ids, corr_mat_tmp.subj_ids);
    corr_mat.corr_r_tot = cat(3, corr_mat.corr_r_tot, corr_mat_tmp.corr_r_tot);
    corr_mat.corr_z_tot = cat(3, corr_mat.corr_z_tot, corr_mat_tmp.corr_z_tot);
    
    if isfield(corr_mat_tmp, 'corr_p_tot')
        corr_mat.corr_p_tot = cat(3, corr_mat.corr_p_tot, corr_mat_tmp.corr_p_tot);
    end
end

uni_ids = unique(corr_mat.subj_ids);

if numel(uni_ids) ~= numel(corr_mat.subj_ids)
    error(sprintf('\tOne or more subject names are used more than once, please check!')); %#ok<SPERR>
end

corr_mat.rois_str = corr_mat_tmp.rois_str;

if isempty(corr_mat.corr_p_tot)
    corr_mat = rmfield(corr_mat, 'corr_p_tot');
end
