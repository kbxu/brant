function brant_ibma(jobman)

% when using a table to specify the number of subjects in each group,
% use the title of center, group1 and group2.

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');

if jobman.matrix == 1
    input_type = 'mat';
    brant_check_empty(jobman.input_matrix.dirs{1}, '\tPlease input data directories!\n');
elseif jobman.volume == 1
    input_type = 'voxel';
    brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');
else
    error('Unknown datatype for IBMA!');
end

stouffer_ind = jobman.stouffer;
fisher_ind = jobman.fisher;
fem_ind = jobman.fem;
mem_ind = jobman.mem;
friston_ind = jobman.friston;
nichols_ind = jobman.nichols;

thr = jobman.thr;

fdrID_ind = jobman.fdrID;
fdrN_ind = jobman.fdrN;
bonf_ind = jobman.bonf;
multi_type = {'fdrID', 'fdrN', 'bonf'};
multi_ind  = [fdrID_ind, fdrN_ind, bonf_ind];

if ~any([stouffer_ind, fisher_ind, fem_ind, mem_ind, friston_ind, nichols_ind])
    error('At least one IBMA methods is expected!');
end
outdir = jobman.out_dir{1};
if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end
    
outfn = fullfile(outdir, 'ibma_rst.mat');

if strcmp(input_type, 'mat')
    
    mats_list = brant_get_subjs(jobman.input_matrix);
    mats_info = cellfun(@load, mats_list);
    
    nStudies = numel(mats_info);
    
    grp_est_tmp = arrayfun(@(x) x.group_est, mats_info, 'UniformOutput', false);
    grp_chk = cellfun(@(x) isequal(x, grp_est_tmp{1}), grp_est_tmp);
    if ~all(grp_chk)
        error('The number and the order of test groups are expected to be same!');
    end
    group_names = grp_est_tmp{1};
    
    tail_tmp = arrayfun(@(x) x.tail_rst, mats_info, 'UniformOutput', false);
    tail_chk = cellfun(@(x) isequal(x, tail_tmp{1}), tail_tmp);
    if ~all(tail_chk)
        error('The number and the order of test tails are expected to be same!');
    end
    tail_est = tail_tmp{1};
    num_tail = numel(tail_est);
    
    if any([fem_ind, mem_ind])
        N1 = arrayfun(@(x) sum(strcmp(group_names{1}, x.subjs(:, 2))), mats_info);
        N2 = arrayfun(@(x) sum(strcmp(group_names{2}, x.subjs(:, 2))), mats_info);
    end
    
    t_cell = arrayfun(@(x) x.t_rst, mats_info, 'UniformOutput', false);
    t_mats = cat(3, t_cell{:});
    
    df = arrayfun(@(x) x.df, mats_info);    
%     df_cell = arrayfun(@(x) x.df, mats_info, 'UniformOutput', false); %%
%     df = cat(3, df_cell{:});
    
    for m = 1:num_tail
        p_mats_tmp = arrayfun(@(x) x.p_rst_unc{m}, mats_info, 'UniformOutput', false);
        p_mats.(tail_est{m}) = cat(3, p_mats_tmp{:});
    end
    
    save(outfn, 'mats_list', 'group_names', 'tail_est');
    % leave to test
elseif strcmp(input_type, 'voxel')

    jobman.input_nifti.single_3d = 1;
    [nifti_list, subj_ids_org] = brant_get_subjs(jobman.input_nifti);
    
    fprintf('Found files\n');
    fprintf('%s\n', subj_ids_org{:});
    
    
    tbl_fields = {'center', 'group1', 'group2'};
    tbl_info = brant_read_csv(jobman.num_subjs_tbl{1});
    tbl_titles = tbl_info(1, :);
    if size(tbl_titles, 2) < 3
        error('Please use center, group1 and group2 in the first row!');
    end
    tbl_ind = cellfun(@(x) find(strcmpi(tbl_titles, x)), tbl_fields, 'UniformOutput', false);
    
    ept_ind = cellfun(@isempty, tbl_ind);
    if any(ept_ind)
        error([sprintf('Please use center, group1 and group2 in the first row!'),...
               sprintf('\t%s\n', tbl_fields{ept_ind})]);
    end
    
    center_fns = tbl_info(2:end, tbl_ind{1});
    subj_ind = cellfun(@(x) find(strcmpi(center_fns, x)), subj_ids_org, 'UniformOutput', false);
    ept_ind = cellfun(@isempty, subj_ind);
    if any(ept_ind)
        error([sprintf('Information of subject can not be found!!'),...
               sprintf('\t%s\n', subj_ids_org{ept_ind})]);
    end
    
    group1_org = cellfun(@str2num, tbl_info(2:end, tbl_ind{2}));
    group2_org = cellfun(@str2num, tbl_info(2:end, tbl_ind{3}));
    
    if any([fem_ind, mem_ind])
        N1 = group1_org(cell2mat(subj_ind));
        N2 = group2_org(cell2mat(subj_ind));
        arrayfun(@(x, y, z) fprintf('Center: %s, group1: %d, group2: %d\n', x{1}, y, z), subj_ids_org, N1, N2);
    end
    
    [mask_hdr, mask_ind, size_mask] = brant_check_load_mask(jobman.input_nifti.mask{1}, nifti_list{1}, outdir);
    
%     mask_nii = load_nii(jobman.input_nifti.mask{1});
%     size_mask = mask_nii.hdr.dime.dim(2:4);
%     mask_bin = mask_nii.img > 0.5;
    mask_bin = false(size_mask);
    mask_bin(mask_ind) = true;
    
    nStudies = numel(nifti_list);
    
    size_T_all = [size_mask, nStudies];
    pix_dim = mask_hdr.dime.pixdim(2:4);
    org_mask = mask_hdr.hist.originator(1:3);

%     t_mats = zeros(size_T_all, 'double');
    t_maps_all = cellfun(@load_nii, nifti_list);
    tf_df = arrayfun(@(x) regexpi(x.hdr.hist.descrip, '[SPM,REST,DPABI]{([TF])_\[(.*)\]}.*', 'tokens'), t_maps_all, 'UniformOutput', false);
    TF_ind = cellfun(@(x) strcmpi('T', x{1}{1}), tf_df, 'UniformOutput', false);
    if ~all(cell2mat(TF_ind))
        error('Only T maps are allowed!');
    end
    df = cellfun(@(x) str2num(x{1}{2}), tf_df);
    t_cell = arrayfun(@(x) double(x.img), t_maps_all, 'UniformOutput', false);
    t_mats = double(cat(4, t_cell{:}));
    t_mats(isnan(t_mats)) = 0;    
    
    tail_est = {'left', 'right', 'both'}; % you don't want to change the order!
    num_tail = numel(tail_est);
    
    for m = 1:num_tail
        p_mats_tmp = zeros(size_T_all, 'double');
        switch(tail_est{m})
            case 'left'
                for n = 1:nStudies
                    p_mats_tmp(:, :, :, n) = spm_Tcdf(t_mats(:, :, :, n), df(n));
                end
            case 'right'
                for n = 1:nStudies
                    p_mats_tmp(:, :, :, n) = 1 - spm_Tcdf(t_mats(:, :, :, n), df(n));
                end
            case 'both'
                for n = 1:nStudies
                    p_mats_tmp(:, :, :, n) = 2 * spm_Tcdf(-1 * abs(t_mats(:, :, :, n)), df(n));
                end
        end
        p_mats.(tail_est{m}) = p_mats_tmp;
    end
    
    if any([fem_ind, mem_ind])
        save(outfn, 'N1', 'N2', 'df');
    else
        save(outfn, 'df');
    end
end

fprintf('\n');

size_t_mat = size(t_mats);
dim_t_mats = length(size_t_mat);

rep_size = [ones(1, dim_t_mats - 1), nStudies];
        
if stouffer_ind == 1    
%   https://en.wikipedia.org/wiki/Fisher%27s_method#cite_note-5
% 	Stouffer, S.A., Suchman, E.A., DeVinney, L.C., Star, S.A. and Williams Jr, R.M., 1949. The American soldier: Adjustment during army life.(Studies in social psychology in World War II), Vol. 1.
    fprintf('\tCalculating Stouffer''s meta-analysis on %d studies\n', nStudies);
    if dim_t_mats == 4
        Zimgs_sum = 0;
        for m = 1:nStudies
            Zimgs_sum = Zimgs_sum + spm_t2z(t_mats(:, :, :, m), df(m));
        end
    elseif dim_t_mats == 3
        z_sum_tmp = arrayfun(@(x, y) spm_t2z(x{1}, y), t_cell, df, 'UniformOutput', false);
        Zimgs_sum = sum(cat(3, z_sum_tmp{:}), 3);
    end
    
    stouffer_ibma.zval = Zimgs_sum / sqrt(nStudies);
    stouffer_ibma.pval = cell(num_tail, 1);
    for m = 1:num_tail
        switch(tail_est{m})
            case 'left'
                stouffer_ibma.pval{m} = spm_Ncdf(stouffer_ibma.zval);
            case 'right'
                stouffer_ibma.pval{m} = spm_Ncdf(-1 * stouffer_ibma.zval);
            case 'both'
                stouffer_ibma.pval{m} = 2 * spm_Ncdf(-1 * abs(stouffer_ibma.zval));
        end
    end
    
    if dim_t_mats == 3
        stouffer_ibma = brant_save_MulCC_results_mat(stouffer_ibma, tail_est, thr, multi_type, multi_ind, 'stouffer_', outdir);
        save(outfn, 'stouffer_ibma', '-append');
    end
    
    if dim_t_mats == 4
        brant_save_t_vals(multi_ind, thr, stouffer_ibma.pval, stouffer_ibma.zval, outdir, 'stouffers_z', mask_bin, pix_dim, org_mask, nStudies - 1);
    end
end

if fisher_ind == 1
%     https://en.wikipedia.org/wiki/Fisher%27s_method#cite_note-5
%     Fisher, R.A. (1925). Statistical Methods for Research Workers. Oliver and Boyd (Edinburgh). ISBN 0-05-002170-2.
    fprintf('\tCalculating Fisher''s meta-analysis on %d studies\n', nStudies);
    
    fisher_ibma.pval = cell(num_tail, 1);
    for m = 1:num_tail
        Chi_2 = -2 * sum(log(p_mats.(tail_est{m})), dim_t_mats);
        fisher_ibma.pval{m} = 1 - cdf('chi2', Chi_2, 2 * nStudies);
    end
    
    if dim_t_mats == 3
        fisher_ibma = brant_save_MulCC_results_mat(fisher_ibma, tail_est, thr, multi_type, multi_ind, 'fisher_', outdir);
        save(outfn, 'fisher_ibma', '-append');
    end
    
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_nii_ibma(fullfile(outdir, ['meta_fisher_', tail_est{m}, '_tail', '_p.nii']), fisher_ibma.pval{m} .* mask_bin, pix_dim, org_mask, []);
        end
    end
end

if any([fem_ind, mem_ind])
    J = 1 - 3 ./ (4 * (N1 + N2 - 2) - 1);
    dev_N = (N1 + N2) ./ N1 ./ N2;
    sum_N = N1 + N2;
    ES_cell = arrayfun(@(x, y, z) sqrt(x) * y{1} * z, dev_N, t_cell, J, 'UniformOutput', false); % unbiased Hedge's g
    Va_cell = arrayfun(@(x, y, z) x + y{1} .^2 / 2 / z, dev_N, ES_cell, sum_N, 'UniformOutput', false); 
    ES = cat(dim_t_mats, ES_cell{:});
    Va = cat(dim_t_mats, Va_cell{:});
    W = 1 ./ Va;
    beta0 = sum(ES .* W, dim_t_mats) ./ sum(W, dim_t_mats);
    v = 1 ./ sum(W, dim_t_mats);
end

if fem_ind == 1
    % Hedges, L.V. (1992). Meta-Analysis. Journal of Educational and Behavioral Statistics 17(4), 279-296. doi: 10.3102/10769986017004279.
    % Konstantopoulos, S., 2006. Fixed and mixed effects models in meta-analysis.
    fprintf('\tCalculating Fixed Effects Model meta-analysis on %d studies\n', nStudies);

    % fixed effects model
    fixed_effects.zval = beta0 ./ sqrt(v);
    fixed_effects.pval = cell(num_tail, 1);
    for m = 1:num_tail
        switch(tail_est{m})
            case 'right'
                fixed_effects.pval{m} = spm_Ncdf(-1 * fixed_effects.zval);
            case 'left'
                fixed_effects.pval{m} = spm_Ncdf(fixed_effects.zval);
            case 'both'
                fixed_effects.pval{m} = 2 * spm_Ncdf(-1 * abs(fixed_effects.zval));
        end
    end
    
    if dim_t_mats == 3
        fixed_effects = brant_save_MulCC_results_mat(fixed_effects, tail_est, thr, multi_type, multi_ind, 'fixed_effect_', outdir);
        save(outfn, 'fixed_effects', '-append');
    end
    
    if dim_t_mats == 4
        brant_save_t_vals(multi_ind, thr, fixed_effects.pval, fixed_effects.tval, outdir, 'fem_t', mask_bin, pix_dim, org_mask, nStudies - 1);
    end
end

if mem_ind == 1
    % Hedges, L.V. (1992). Meta-Analysis. Journal of Educational and Behavioral Statistics 17(4), 279-296. doi: 10.3102/10769986017004279.
    % Konstantopoulos, S., 2006. Fixed and mixed effects models in meta-analysis.
    % https://en.wikipedia.org/wiki/Effect_size#cite_note-HedgesL1985Statistical-15
    % Hedges g*
    fprintf('\tCalculating Mixed Effects Model meta-analysis on %d studies\n', nStudies);

    % mixed effects model
    a = sum(W, dim_t_mats) - sum(W.^2, dim_t_mats) ./ sum(W, dim_t_mats);
    Q = sum((ES - repmat(beta0, rep_size)).^ 2 ./ Va, dim_t_mats);
    tau2 = zeros(size(Q));
    tau2(Q >= (nStudies - 1)) = (Q(Q >= (nStudies - 1)) - (nStudies - 1)) ./ a(Q >= (nStudies - 1));
    W2 = 1 ./ (Va + repmat(tau2, rep_size));
    beta2 = sum(ES .* W2, dim_t_mats) ./ sum(W2, dim_t_mats);
    v2 = 1 ./ sum(W2, dim_t_mats);

    mixed_effects.pval_ES = 1 - cdf('chi2', Q, nStudies - 1);
    mixed_effects.tval = beta2 ./ sqrt(v2);
    mixed_effects.esbar = beta2;
        
    for m = 1:num_tail
        switch(tail_est{m})
            case 'right'
                mixed_effects.pval{m} = squeeze(spm_Ncdf(-1 * mixed_effects.tval));
            case 'left'
                mixed_effects.pval{m} = squeeze(spm_Ncdf(mixed_effects.tval));
            case 'both'
                mixed_effects.pval{m} = 2 * spm_Ncdf(-1 * abs(mixed_effects.tval));
        end
    end
    
    if dim_t_mats == 3
        mixed_effects = brant_save_MulCC_results_mat(mixed_effects, tail_est, thr, multi_type, multi_ind, 'mixed_effect_', outdir);
        save(outfn, 'mixed_effects', '-append');
        dlmwrite(fullfile(outdir, 'meta_mem_ES.txt'), mixed_effects.pval_ES);
    end
        
    if dim_t_mats == 4
        brant_save_nii_ibma(fullfile(outdir, 'meta_mem_ES.nii'), mixed_effects.pval_ES .* mask_bin, pix_dim, org_mask, []);
        brant_save_t_vals(multi_ind, thr, mixed_effects.pval, mixed_effects.tval, outdir, 'mem_t', mask_bin, pix_dim, org_mask, nStudies - 1);
    end
end

if friston_ind == 1
    % Worsley, K.J., and Friston, K.J. (2000). A test for a conjunction. Statistics & Probability Letters 47(2), 135-140. doi: Doi 10.1016/S0167-7152(99)00149-2.
    fprintf('\tCalculating Worsley and Friston''s meta-analysis on %d studies\n', nStudies);
    
    for m = 1:num_tail
        max_p = max(p_mats.(tail_est{m}), [], dim_t_mats);
        friston_ibma.pval{m} = (max_p).^nStudies;
    end
    
    if dim_t_mats == 3
        friston_ibma = brant_save_MulCC_results_mat(friston_ibma, tail_est, thr, multi_type, multi_ind, 'friston_', outdir);
        save(outfn, 'friston_ibma', '-append');
    end
        
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_nii_ibma(fullfile(outdir, ['meta_friston_', tail_est{m}, '_tail', '_p.nii']), friston_ibma.pval{m} .* mask_bin, pix_dim, org_mask, []);
        end
    end
end

if nichols_ind == 1
    % Nichols, T., Brett, M., Andersson, J., Wager, T., and Poline, J.B. (2005). Valid conjunction inference with the minimum statistic. Neuroimage 25(3), 653-660. doi: 10.1016/j.neuroimage.2004.12.005.
    fprintf('\tCalculating Nichols''s meta-analysis on %d studies\n', nStudies);
    
    for m = 1:num_tail
        nichols_ibma.pval{m} = max(p_mats.(tail_est{m}), [], dim_t_mats);
    end
    
    if dim_t_mats == 3
        nichols_ibma = brant_save_MulCC_results_mat(nichols_ibma, tail_est, thr, multi_type, multi_ind, 'nichols_', outdir);
        save(outfn, 'nichols_ibma', '-append');
    end
    
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_nii_ibma(fullfile(outdir, ['meta_nichols_', tail_est{m}, '_tail', '_p.nii']), nichols_ibma.pval{m} .* mask_bin, pix_dim, org_mask, []);
        end
    end
end

fprintf('\tFinished!\n');

function ibma_model = brant_save_MulCC_results_mat(ibma_model, tail_est, thr, multi_type, multi_ind, prefix, outdir)
% use one tail results as output
% right - left !

size_mat = size(ibma_model.pval{1});
upper_ind = triu(true(size_mat), 1);

right_ind = strcmpi(tail_est, 'right');
left_ind = strcmpi(tail_est, 'left');

h_unc_one_tail = (ibma_model.pval{right_ind} <= thr) - (ibma_model.pval{left_ind} <= thr);
if any(h_unc_one_tail(:) ~= 0)
    dlmwrite(fullfile(outdir, [prefix, num2str(thr, '%.2g_h'), '.txt']), h_unc_one_tail);
end

for m = 1:numel(multi_type)
    if multi_ind(m) == 1
        [thr_r, sts_r] = brant_MulCC(ibma_model.pval{right_ind}(upper_ind), thr, multi_type{m});
        [thr_l, sts_l] = brant_MulCC(ibma_model.pval{left_ind}(upper_ind), thr, multi_type{m});
        
        if any([sts_r, sts_l] ~= -1)
            ibma_model.([multi_type{m}, '_h']) = (ibma_model.pval{right_ind} <= thr_r) - (ibma_model.pval{left_ind} <= thr_l);
            dlmwrite(fullfile(outdir, [prefix, multi_type{m}, num2str(thr, '_%.2g_h'), '.txt']), ibma_model.([multi_type{m}, '_h']));
        else
            ibma_model.([multi_type{m}, '_h']) = [];
        end
    end
end

function brant_save_t_vals(multi_ind, thr, pval, tval, tardir, tok, mask_bin, pix_dim, org_mask, df)

filename = fullfile(tardir, ['meta_', tok, '_t.nii']);
brant_save_nii_ibma(filename, tval, pix_dim, org_mask, 'SPM_Z[1]');

p_mask = (pval{1} > 0 & pval{1} < thr) | (pval{2} > 0 & pval{2} < thr);
tval_tmp = tval .* p_mask .* mask_bin;

filename = fullfile(tardir, ['meta_', tok, '_t', '_masked_', num2str(thr, '%.2e'), '.nii']);
brant_save_nii_ibma(filename, tval_tmp, pix_dim, org_mask, 'SPM_Z[1]');

if any(multi_ind)
    multi_type = {'fdrID', 'fdrN', 'bonf'};
    p_vec_L = pval{1}(mask_bin);
    p_vec_R = pval{2}(mask_bin);
    for n = 1:numel(multi_type)
        if multi_ind(n) == 1
            t_mat_thres = brant_multi_thres_t(p_vec_L, p_vec_R, thr, multi_type{n}, tval);
            
            if ~isempty(t_mat_thres)
                filename = fullfile(tardir, ['meta_', tok, '_t', '_masked_', multi_type{n}, num2str(thr, '_%.2g'), '.nii']);
                brant_save_nii_ibma(filename, t_mat_thres, pix_dim, org_mask, 'SPM_Z[1]');
            end
        end
    end
end

function brant_save_nii_ibma(filename, img, pix_dim, org_mask, imginfo)

% filename = fullfile(tardir, ['meta_', tok, '_p.nii']);
nii = make_nii(img, pix_dim, org_mask, 16, imginfo);
save_nii(nii, filename);