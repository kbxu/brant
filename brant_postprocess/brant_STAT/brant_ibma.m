function brant_ibma(jobman)

% when using a table to specify the number of subjects in each group,
% use the title of center, group1 and group2.

if jobman.matrix == 1
    input_type = 'mat';
elseif jobman.volume == 1
    input_type = 'voxel';
else
    error('Unknown datatype for IBMA!');
end

stouffer_ind = jobman.stouffer;
fisher_ind = jobman.fisher;
fem_ind = jobman.fem;
mem_ind = jobman.mem;
friston_ind = jobman.friston;
nicolas_ind = jobman.nicolas;

p_thr = jobman.p_thr;
fdr_ind = jobman.fdr;
fdr2_ind = jobman.fdr2;
bonf_ind = jobman.bonf;
multi_ind  = [fdr_ind, fdr2_ind, bonf_ind];
    
multi_type = {'FDR', 'FDR2', 'Bonf'};

if ~any([stouffer_ind, fisher_ind, fem_ind, mem_ind, friston_ind, nicolas_ind])
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
    
    N1 = arrayfun(@(x) sum(strcmp(group_names{1}, x.subjs(:, 2))), mats_info);
    N2 = arrayfun(@(x) sum(strcmp(group_names{2}, x.subjs(:, 2))), mats_info);
        
    t_cell = arrayfun(@(x) x.t_rst, mats_info, 'UniformOutput', false);
    t_mats = cat(3, t_cell{:});
    
    df_cell = arrayfun(@(x) x.df, mats_info, 'UniformOutput', false); %%
    df = cat(3, df_cell{:});
    
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
    [a, b, tbl_info] = xlsread(jobman.num_subjs_tbl{1}); %#ok<*ASGLU>
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
    
    group1_org = cell2mat(tbl_info(2:end, tbl_ind{2}));
    group2_org = cell2mat(tbl_info(2:end, tbl_ind{3}));
    
    N1 = group1_org(cell2mat(subj_ind));
    N2 = group2_org(cell2mat(subj_ind));
    
    arrayfun(@(x, y, z) fprintf('Center: %s, group1: %d, group2: %d\n', x{1}, y, z), subj_ids_org, N1, N2);
    
    mask_nii = load_nii(jobman.mask{1});
    size_mask = mask_nii.hdr.dime.dim(2:4);
    mask_bin = mask_nii.img > 0.5;
    
    nStudies = numel(nifti_list);
    
    size_T_all = [size_mask, nStudies];
    pix_dim = mask_nii.hdr.dime.pixdim(2:4);
    org_mask = mask_nii.hdr.hist.originator(1:3);

%     t_mats = zeros(size_T_all, 'double');
    t_maps_all = cellfun(@load_nii, nifti_list);
    tf_df = arrayfun(@(x) regexpi(x.hdr.hist.descrip, 'SPM{([TF])_\[(.*)\]}.*', 'tokens'), t_maps_all, 'UniformOutput', false);
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
    
    save(outfn, 'N1', 'N2', 'df');
end

fprintf('\n');

size_t_mat = size(t_mats);
dim_t_mats = length(size_t_mat);

if dim_t_mats == 3
    upper_ind = triu(ones(size_t_mat(1)), 1) == 1;
    mat_ind = find(upper_ind);
end
diag_ind = eye(size_t_mat(1)) > 0.5;
rep_size = [ones(1, dim_t_mats - 1), nStudies];
        
if stouffer_ind == 1
    
    fprintf('\tCalculating Stourffer''s meta-analysis on %d studies\n', nStudies);
    if dim_t_mats == 4
        Timgs_sum = 0;
        for m = 1:nStudies
            Timgs_sum = Timgs_sum + spm_t2z(t_mats(:, :, :, m), df(m));
        end
    elseif dim_t_mats == 3
        Timgs_sum_tmp = 0;
        if numel(unique(df_cell)) == 1
            t_sum_tmp = cellfun(@(x, y) spm_t2z(x, y), t_cell, df_cell, 'UniformOutput', false);
            t_sum_tmp2 = cat(3, t_sum_tmp{:});
            Timgs_sum = sum(t_sum_tmp2, 3);
        else
            t_sum_tmp = 0;
            for m = 1:nStudies
                t_sum_tmp = t_sum_tmp + arrayfun(@(x, y) spm_t2z(x, y), t_cell{m}(mat_ind), df_cell{m}(mat_ind));
            end
            Timgs_sum = zeros(size_t_mat(1));
            Timgs_sum(mat_ind) = Timgs_sum_tmp;
            Timgs_sum = Timgs_sum + Timgs_sum';
        end
    end
    
    stouffer.zval = Timgs_sum / sqrt(nStudies);
    stouffer.pval = cell(num_tail, 1);
    for m = 1:num_tail
        switch(tail_est{m})
            case 'left'
                stouffer.pval{m} = spm_Ncdf(stouffer.zval);
            case 'right'
                stouffer.pval{m} = spm_Ncdf(-1 * stouffer.zval);
            case 'both'
                stouffer.pval{m} = 2 * spm_Ncdf(-1 * abs(stouffer.zval));
        end
        
        if dim_t_mats == 3
            stouffer.pval{m}(diag_ind) = 0;
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(stouffer.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        stouffer.([multi_type{n}, '_h']){m} = stouffer.pval{m} <= p_thr_tmp;
                        stouffer.([multi_type{n}, '_h']){m}(diag_ind) = false;
                    else
                        stouffer.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end
        
    
    if dim_t_mats == 4
        brant_save_t_vals(multi_ind, p_thr, stouffer.pval, stouffer.zval, outdir, 'stouffers_z', mask_bin, pix_dim, org_mask, nStudies - 1);
%         for m = 1:num_tail
%             brant_save_p_vals(multi_ind, p_thr, stouffer.pval{m}, outdir, ['stouffers_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
%         end
    else
        save(outfn, 'stouffer', '-append');
    end
end

if fisher_ind == 1
    
    fprintf('\tCalculating Fisher''s meta-analysis on %d studies\n', nStudies);
    
    fisher.pval = cell(num_tail, 1);
    for m = 1:num_tail
        Chi_2 = -2 * sum(log(p_mats.(tail_est{m})), dim_t_mats);
        fisher.pval{m} = 1 - cdf('chi2', Chi_2, 2 * nStudies);
        
        if dim_t_mats == 3
            fisher.pval{m}(diag_ind) = 0;
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(fisher.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        fisher.([multi_type{n}, '_h']){m} = fisher.pval{m} <= p_thr_tmp;
                        fisher.([multi_type{n}, '_h']){m}(diag_ind) = false;
                    else
                        fisher.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end
    
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_p_vals(multi_ind, p_thr, fisher.pval{m}, outdir, ['fisher_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
        end
    else
        save(outfn, 'fisher', '-append');
    end
end

if any([fem_ind, mem_ind])
    J = 1 - 3 ./ (4 * (N1 + N2 - 2) - 1);
    dev_N = (N1 + N2) ./ N1 ./ N2;
    sum_N = N1 + N2;
    ES_cell = arrayfun(@(x, y, z) sqrt(x) * y{1} * z, dev_N, t_cell, J, 'UniformOutput', false);
    Va_cell = arrayfun(@(x, y, z) x + y{1} .^2 / 2 / z, dev_N, ES_cell, sum_N, 'UniformOutput', false);
    ES = cat(dim_t_mats, ES_cell{:});
    Va = cat(dim_t_mats, Va_cell{:});
    W = 1 ./ Va;
    beta0 = sum(ES .* W, dim_t_mats) ./ sum(W, dim_t_mats);
    v = 1 ./ sum(W, dim_t_mats);
end

if fem_ind == 1

    fprintf('\tCalculating Fixed Effect Model meta-analysis on %d studies\n', nStudies);

    % fixed effect model
    fix_effect.tval = beta0 ./ sqrt(v);
    fix_effect.pval = cell(num_tail, 1);
    for m = 1:num_tail
        switch(tail_est{m})
            case 'left'
                fix_effect.pval{m} = spm_Ncdf(fix_effect.tval);
            case 'right'
                fix_effect.pval{m} = spm_Ncdf(-1 * fix_effect.tval);
            case 'both'
                fix_effect.pval{m} = 2 * spm_Ncdf(-1 * abs(fix_effect.tval));
        end
        
        if dim_t_mats == 3
            fix_effect.pval{m}(diag_ind) = 0;
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(fix_effect.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        fix_effect.([multi_type{n}, '_h']){m} = fix_effect.pval{m} <= p_thr_tmp;
                        fix_effect.([multi_type{n}, '_h']){m}(diag_ind) = false;
                    else
                        fix_effect.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end

    if dim_t_mats == 4
        brant_save_t_vals(multi_ind, p_thr, fix_effect.pval, fix_effect.tval, outdir, 'fem_t', mask_bin, pix_dim, org_mask, nStudies - 1);
%         for m = 1:num_tail
%             brant_save_p_vals(multi_ind, p_thr, fix_effect.pval{m}, outdir, ['fem_p_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
%         end
    else
        save(outfn, 'fix_effect', '-append');
    end
end

if mem_ind == 1

    fprintf('\tCalculating Mixed Effect Model meta-analysis on %d studies\n', nStudies);

    % random effect model
    a = sum(W, dim_t_mats) - sum(W.^2, dim_t_mats) ./ sum(W, dim_t_mats);
    Q = sum((ES - repmat(beta0, rep_size)).^ 2 ./ Va, dim_t_mats);
    tau2 = zeros(size(Q));
    tau2(Q >= (nStudies - 1)) = (Q(Q >= (nStudies - 1)) - (nStudies - 1)) ./ a(Q >= (nStudies - 1));
    W2 = 1 ./ (Va + repmat(tau2, rep_size));
    beta2 = sum(ES .* W2, dim_t_mats) ./ sum(W2, dim_t_mats);
    v2 = 1 ./ sum(W2, dim_t_mats);

    mix_effect.pval_h = 1 - cdf('chi2', Q, nStudies - 1);
    mix_effect.tval = beta2 ./ sqrt(v2);
    mix_effect.esbar = beta2;
    
    sign_t = sign(mix_effect.tval);
    
    for m = 1:num_tail
        switch(tail_est{m})
            case 'left'
                mix_effect.pval{m} = squeeze(spm_Ncdf(mix_effect.tval));
            case 'right'
                mix_effect.pval{m} = squeeze(spm_Ncdf(-1 * mix_effect.tval));
            case 'both'
                mix_effect.pval{m} = 2 * spm_Ncdf(-1 * abs(mix_effect.tval));
        end
        
        if dim_t_mats == 3
            mix_effect.pval_h(diag_ind) = 0;
            mix_effect.pval{m}(diag_ind) = 0;
            
%             tmp = load('D:\Circos Practice\BA_atlas_kb\stat_one_sample\siemens_one_t_unc_mask.txt');
%             upper_ind = upper_ind & (tmp > 0);
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(mix_effect.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        mix_effect.([multi_type{n}, '_h']){m} = (mix_effect.pval{m} <= p_thr_tmp) .* sign_t;
                        mix_effect.([multi_type{n}, '_h']){m}(diag_ind) = false;
                        dlmwrite(fullfile(outdir, ['mixed_effect_', multi_type{n}, num2str(p_thr, '_%.2e_h'), '.txt']), mix_effect.([multi_type{n}, '_h']){m})
                    else
                        mix_effect.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end
        
    if dim_t_mats == 4
        brant_save_p_vals(multi_ind, p_thr, mix_effect.pval_h, outdir, 'mem_ES_p_h', mask_bin, pix_dim, org_mask);
        brant_save_t_vals(multi_ind, p_thr, mix_effect.pval, mix_effect.tval, outdir, 'mem_t', mask_bin, pix_dim, org_mask, nStudies - 1);
%         for m = 1:num_tail
        mix_effect = brant_MulCC_tmp(mix_effect, multi_ind);
%             brant_save_p_vals(multi_ind, p_thr, mix_effect.pval{m}, outdir, ['mem_p_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
%         end
%     else
%         
    end
    save(outfn, 'mix_effect', '-append');
end

if friston_ind == 1
    
    fprintf('\tCalculating Friston''s meta-analysis on %d studies\n', nStudies);
    
    for m = 1:num_tail
        max_p = max(p_mats.(tail_est{m}), [], dim_t_mats);
        friston.pval{m} = (max_p).^nStudies;
        
        if dim_t_mats == 3
            friston.pval{m}(diag_ind) = 0;
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(friston.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        friston.([multi_type{n}, '_h']){m} = friston.pval{m} <= p_thr_tmp;
                        friston.([multi_type{n}, '_h']){m}(diag_ind) = false;
                    else
                        friston.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end
    
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_p_vals(multi_ind, p_thr, friston.pval{m}, outdir, ['friston_p_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
        end
    else
        save(outfn, 'friston', '-append');
    end
end

if nicolas_ind == 1
    fprintf('\tCalculating Nicolas''s meta-analysis on %d studies\n', nStudies);
    
    for m = 1:num_tail
        nicolas.pval{m} = max(p_mats.(tail_est{m}), [], dim_t_mats);
        nicolas.pval{m}(diag_ind) = 0;
        
        if dim_t_mats == 3
            nicolas.pval{m}(diag_ind) = 0;
            
            for n = 1:numel(multi_type)
                if multi_ind(n) == 1
                    [p_thr_tmp, sts] = brant_MulCC(nicolas.pval{m}(upper_ind), p_thr, multi_type{n});
                    if sts == 1
                        nicolas.([multi_type{n}, '_h']){m} = nicolas.pval{m} <= p_thr_tmp;
                        nicolas.([multi_type{n}, '_h']){m}(diag_ind) = false;
                    else
                        nicolas.([multi_type{n}, '_h']){m} = false(size_t_mat(1:2));
                    end
                end
            end
        end
    end
    
    if dim_t_mats == 4
        for m = 1:num_tail
            brant_save_p_vals(multi_ind, p_thr, nicolas.pval{m}, outdir, ['nicolas_p_', tail_est{m}, '_tail'], mask_bin, pix_dim, org_mask);
        end
    else
        save(outfn, 'nicolas', '-append');
    end
end

disp([9, 'Finished'])

function mth_struc = brant_MulCC_tmp(mth_struc, multi_ind)

if any(multi_ind)
    multi_type = {'FDR', 'FDR2', 'Bonf'};
    for n = 1:numel(multi_type)
        if multi_ind(n) == 1
            mth_struc.(multi_type{n}) = 1;
        end
    end
end


function brant_save_t_vals(multi_ind, p_thr, pval, tval, tardir, tok, mask_bin, pix_dim, org_mask, df)

filename = fullfile(tardir, ['meta_', tok, '_t.nii']);
nii = make_nii(tval .* mask_bin, pix_dim, org_mask, 16, 'SPM_Z[1]');
save_nii(nii, filename);

% for m = 1:numel(tails)
p_mask = (pval{1} > 0 & pval{1} < p_thr) | (pval{2} > 0 & pval{2} < p_thr);
tval_tmp = tval .* p_mask .* mask_bin;

filename = fullfile(tardir, ['meta_', tok, '_t', '_masked_', num2str(p_thr, '%.2e'), '.nii']);
nii = make_nii(tval_tmp, pix_dim, org_mask, 16, 'SPM_Z[1]');
save_nii(nii, filename);


if any(multi_ind)
    multi_type = {'FDR', 'FDR2', 'Bonf'};
    p_vec_L = pval{1}(mask_bin);
    p_vec_R = pval{2}(mask_bin);
    for n = 1:numel(multi_type)
        if multi_ind(n) == 1
            t_mat_thres = brant_multi_thres_t(p_vec_L, p_vec_R, p_thr, multi_type{n}, tval);
            
            if ~isempty(t_mat_thres)
                filename = fullfile(tardir, ['meta_', tok, '_t', '_masked_', multi_type{n}, num2str(p_thr, '_%.2e'), '.nii']);
                nii = make_nii(t_mat_thres, pix_dim, org_mask, 16, 'SPM_Z[1]');
                save_nii(nii, filename);
            end
        end
    end
end
% end


function brant_save_p_vals(multi_ind, p_thr, pval, tardir, tok, mask_bin, pix_dim, org_mask)

filename = fullfile(tardir, ['meta_', tok, '_p.nii']);
nii = make_nii(pval .* mask_bin, pix_dim, org_mask, 16);
save_nii(nii, filename);
