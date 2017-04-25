function brant_thres_est(jobman)
% find out for each subject, the sparsity under each threshold of
% correlation

[mat_list, subj_ids] = brant_get_subjs(jobman.input_matrix);

use_abs_ind = jobman.use_abs_ind;
min_max_int = zeros(numel(subj_ids), 2);
min_max_spar = zeros(numel(subj_ids), 2);
spar_under_corr = zeros(numel(subj_ids), numel(jobman.thres_int));

% loop for each subject
for m = 1:numel(subj_ids)
    corr_mat = load(mat_list{m});
    
    if use_abs_ind == 1
        mat_tmp = abs(double(corr_mat));
    else
        mat_tmp = double(corr_mat);
    end
    
    if m == 1
        mat_ind = triu(true(size(mat_tmp)), 1);
        N = sum(mat_ind(:));
    end
    
    min_max_int(m, :) = [min(mat_tmp(mat_ind)), max(mat_tmp(mat_ind))];
    spar_under_corr(m, :) = arrayfun(@(x) sum(mat_tmp(mat_ind) >= x) / N, jobman.thres_int);
    min_max_spar(m, :) = [min(spar_under_corr(m, :)), max(spar_under_corr(m, :))];
    fprintf('%s: intensity: %g ~ %g, sparsity %g ~ %g\n', subj_ids{m}, min_max_int(m, :), min_max_spar(m, :));
end

titles = [{'subject', 'min intensity', 'max intensity', 'min sparsity', 'max sparsity'}, arrayfun(@(x) num2str(x, 'sparsity under %g'), jobman.thres_int, 'UniformOutput', false)];
outfn = fullfile(jobman.out_dir{1}, 'brant_sparsity_estimation.csv');
brant_write_csv(outfn, [titles; [subj_ids, num2cell(min_max_int), num2cell(min_max_spar), num2cell(spar_under_corr)]]);

fprintf('\nPlease open %s for sparsity under each threshold of intensity.\n', outfn);