function [data_infos, subj_ind, fil_inds, reg_good_subj, corr_good_subj] = brant_parse_subj_info2(regressors_tbl, subj_ids, grp_est, fil_est, reg_est, score_est, discard_bad_ind)

fprintf('\tParsing subject information from %s...\n', regressors_tbl);

if isempty(regressors_tbl)
    error('A discription csv file is expected!');
end

% parse regressors begin
tbl = brant_read_csv(regressors_tbl);
tbl_title = tbl(1, :);
tbl_data = tbl(2:end, :);

[tbl_fns, fns_good] = brant_chk_tbl_cols(tbl_data, tbl_title, {'name'}, 'str');
if numel(unique(tbl_fns)) ~= numel(tbl_fns)
    tmp = unique(tbl_fns);
    tmp_num = cellfun(@(x) sum(strcmpi(x, tbl_fns)), tmp);
    tmp_dup = tmp(tmp_num > 1);
    fprintf('%s\n', tmp_dup{:});
    error('Duplicated subject names are found!');
end
tbl_good = fns_good;

[tbl_grp, grp_good] = brant_chk_tbl_cols(tbl_data, tbl_title, {'group'}, 'str');
tbl_good = tbl_good & grp_good;

if ~isempty(fil_est)
    [tbl_fil, fil_good] = brant_chk_tbl_cols(tbl_data, tbl_title, {'filter'}, 'str');
    tbl_good = tbl_good & fil_good;
end

if ~isempty(reg_est)
    [tbl_reg, reg_good] = brant_chk_tbl_cols(tbl_data, tbl_title, reg_est, 'number');
    tbl_good = tbl_good & reg_good;
end

if ~isempty(score_est)
    tbl_corr = brant_chk_tbl_cols(tbl_data, tbl_title, score_est, 'number');
end

% filter for wanted groups and filters
grp_ind_data = cellfun(@(x) any(strcmpi(x, grp_est)), tbl_grp);
if ~isempty(fil_est)
    fil_ind_data = cellfun(@(x) any(strcmpi(x, fil_est)), tbl_fil);
else
    fil_ind_data = 1;
end
subj_fil = grp_ind_data & fil_ind_data;
tbl_good_merge = tbl_good & subj_fil;


% get subject without or broken info
tbl_fns_good_tmp = tbl_fns(tbl_good);
[data_fns_ind_tmp, subj_loc_tmp] = ismember(lower(subj_ids), lower(tbl_fns_good_tmp)); %#ok<ASGLU>
if any(data_fns_ind_tmp == 0)
    if discard_bad_ind == 0
        error([sprintf('%s\n', subj_ids{data_fns_ind_tmp == 0}),...
               sprintf('No informations are found for above %d subjects!\n', sum(data_fns_ind_tmp == 0)),...
               ]);
    else
        warning([sprintf('%s\n', subj_ids{data_fns_ind_tmp == 0}),...
               sprintf('No informations are found for above %d subjects!\n', sum(data_fns_ind_tmp == 0)),...
               ]);
    end
end

tbl_miss = subj_fil & ~tbl_good;
if any(tbl_miss)
    warning([sprintf('%s\n', tbl_fns{tbl_miss}),...
             sprintf('Broken informations are found for %d subjects in the table\n', sum(tbl_miss)),...
             ]);
end

% good and filtered file names in the table
tbl_fns_good = tbl_fns(tbl_good_merge);

[subj_ind, subj_loc] = ismember(lower(subj_ids), lower(tbl_fns_good));
subj_ind_tbl = subj_loc(subj_ind);


if isempty(subj_ind_tbl)
    error('None subject can be indexed from the excel table, please check filenames!');
end


% map the order in the table to the order in the existing subject order
good_subj = tbl_fns_good(subj_ind_tbl);
tbl_grp_good = tbl_grp(tbl_good_merge);
grp_good_subj = tbl_grp_good(subj_ind_tbl);

data_infos = strtrim([good_subj, grp_good_subj]);

fil_inds{1} = 1;
if ~isempty(fil_est)
    tbl_fil_good = tbl_fil(tbl_good_merge);
    tbl_good_subj = tbl_fil_good(subj_ind_tbl);
    fil_inds = cellfun(@(x) strcmpi(x, tbl_good_subj), fil_est, 'UniformOutput', false);
end

reg_good_subj = [];
if ~isempty(reg_est)
    tbl_reg_good = tbl_reg(tbl_good_merge, :);
    reg_good_subj = tbl_reg_good(subj_ind_tbl, :);
end

corr_good_subj = [];
if ~isempty(score_est),
    tbl_corr_good = tbl_corr(tbl_good_merge, :);
    corr_good_subj = tbl_corr_good(subj_ind_tbl, :);
end