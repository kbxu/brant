function [fil_inds, fil_strs, data_infos, data_reg_mat, fn_ept_inds, data_corr_mat, corr_scores_nm] = parse_subj_info(regressors_tbl, subj_ids, grp_est, grp_filter, grp_regr_strs, corr_scores, discard_bad_ind)

fprintf('\tParsing subject information from %s...\n', regressors_tbl);

if isempty(regressors_tbl)
    error('A discription table file (*.csv, *.xls) is expected!')    
end

% parse regressors begin
[aa, bb, tbl] = xlsread(regressors_tbl); %#ok<*ASGLU>
tbl_title = tbl(1, :);
nm_ind = find(cell2mat(cellfun(@(x) strcmpi(x, 'name'), tbl_title, 'UniformOutput', false))); %#ok<*EFIND>
grp_ind = find(cell2mat(cellfun(@(x) strcmpi(x, 'group'), tbl_title, 'UniformOutput', false)));

bad_rows = cellfun(@(x) any(isnan(x)), tbl(:, nm_ind));
tbl = tbl(~bad_rows, :);
if isempty(nm_ind) || numel(nm_ind) > 1
    error('Must there be one column with subject names titled by name!');
end

if isempty(grp_ind) || numel(grp_ind) > 1
    error('Must there be one column with group names titled by group!');
end

tbl_data = tbl(2:end, :);
fn_grp_tmp = arrayfun(@(x) tbl_data(:, x), [nm_ind, grp_ind], 'UniformOutput', false);
fn_grp = [fn_grp_tmp{:}];
% regressors_nm_tbl = setdiff(lower(tbl_title), {'name', 'group'});
if isempty(grp_regr_strs)
    fprintf('\tNo regressors are found!\n')
    reg_mat = [];
else
    regressors_nm = regexp(grp_regr_strs, '[,;]', 'split');
    regrs_ind = ~cellfun(@isempty, regressors_nm);
    regressors_nm = regressors_nm(regrs_ind);
    
    num_reg = numel(regressors_nm);
    if num_reg ~= numel(unique(regressors_nm))
        error('Regressors must use different titles!');
    end

    reg_ind = cellfun(@(x) find(strcmpi(x, tbl_title)), regressors_nm, 'UniformOutput', false);
    reg_ind_tmp = cellfun(@isempty, reg_ind);
    
    if any(reg_ind_tmp == 1)
        error([sprintf('\tMust there be one column with subject names titled by!\n'),...
               sprintf('\t%s\n', regressors_nm{reg_ind_tmp == 1})]);
    end
    reg_mat = cell2mat(cellfun(@(x) cell2mat(tbl_data(:, x)), reg_ind, 'UniformOutput', false));
end


if isempty(corr_scores)
    corr_scores_mat = [];
    corr_scores_nm = '';
else
    corr_scores_nm = regexp(corr_scores, '[,;]', 'split');
    corr_ind_ept = ~cellfun(@isempty, corr_scores_nm);
    corr_scores_nm = corr_scores_nm(corr_ind_ept);
    
    num_corr = numel(corr_scores_nm);
    if num_corr ~= numel(unique(corr_scores_nm))
        error('Correlation scores must use different titles!');
    end

    corr_ind = cellfun(@(x) find(strcmpi(x, tbl_title)), corr_scores_nm, 'UniformOutput', false);
    corr_ind_tmp = cellfun(@isempty, corr_ind);
    
    if any(corr_ind_tmp == 1)
        error([sprintf('\tMust there be one column with subject names titled by!\n'),...
               sprintf('\t%s\n', corr_scores_nm{corr_ind_tmp == 1})]);
    end
    corr_scores_mat = cell2mat(cellfun(@(x) cell2mat(tbl_data(:, x)), corr_ind, 'UniformOutput', false));
end

if isempty(grp_est)
    error('There should be at least one group!');
end
group_est = regexp(grp_est, '[;,]', 'split');
group_ind = cellfun(@(x) any(strcmpi(group_est, x)), fn_grp(:, 2));

if ~isempty(grp_filter)
    fil_strs = regexp(grp_filter, '[,;]', 'split');
    fil_strs = fil_strs(~cellfun(@isempty, fil_strs));
    fil_tbl_ind = find(cell2mat(cellfun(@(x) strcmpi(x, 'filter'), tbl_title, 'UniformOutput', false)));
    if isempty(fil_tbl_ind) || numel(fil_tbl_ind) > 1
        error('Must there be one column with subject names titled by name!');
    end
    
    fil_strs_tbl = tbl(2:end, fil_tbl_ind);
    
    fil_inds_tmp = cellfun(@(x) strcmpi(x, fil_strs_tbl) & group_ind, fil_strs, 'UniformOutput', false);
    
    fil_ept = cellfun(@(x) isempty(find(x)), fil_inds_tmp);
    if any(fil_ept)
        error([sprintf('\tFilters are not found!\n'),...
               sprintf('\t%s\n', fil_strs{fil_ept})]);
    end
    
    fil_inds = cellfun(@(x) x(fn_inds), fil_inds_tmp, 'UniformOutput', false);
else
    fil_inds{1} = group_ind;
    fil_strs{1} = 'group_set_1';
end


fn_inds_tmp = cellfun(@(x) find(strcmp(x, fn_grp(:, 1))), subj_ids, 'UniformOutput', false);
fn_ept_inds = cellfun(@isempty, fn_inds_tmp);

if any(fn_ept_inds)
    if discard_bad_ind == 0
        error([sprintf('No informations are found for subject\n'),...
               sprintf('%s\n', subj_ids{fn_ept_inds})]);
    else
        warning([sprintf('No informations are found for subject\n'),...
                 sprintf('%s\n', subj_ids{fn_ept_inds})]);
        fn_inds_tmp = fn_inds_tmp(~fn_ept_inds);
        subj_ids = subj_ids(~fn_ept_inds);
    end
end


% parse regressors end
if ~isempty(corr_scores_mat)
    corr_good = isfinite(sum(corr_scores_mat, 2));
    if ~all(corr_good)
        if discard_bad_ind == 0
            error([sprintf('No informations of scores are found for subject\n'),...
                   sprintf('%s\n', fn_grp{~corr_good})]);
        else
            warning([sprintf('No informations of scores are found for subject\n'),...
                     sprintf('%s\n', fn_grp{~corr_good})]);
            fn_inds = fn_inds(corr_good);
            subj_ids = subj_ids(corr_good);
            fn_ept_inds(~corr_good) = false;
        end
    end
    data_corr_mat = corr_scores_mat(fn_inds, :);
else
    data_corr_mat = [];
end






% fn_inds is the index of data which has information in the table
fn_inds = cell2mat(fn_inds_tmp);
% grp_infos = fn_grp(fn_inds, 2);





data_infos = fn_grp(fn_inds, :);
% regressors with intercept
num_subjs = numel(fn_inds);
if ~isempty(reg_mat)
    data_reg_mat = [reg_mat(fn_inds, :), ones(num_subjs, 1)];
else
    data_reg_mat = [];
end