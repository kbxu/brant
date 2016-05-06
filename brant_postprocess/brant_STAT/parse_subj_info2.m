function [data_infos, subj_ind, fil_inds, reg_good_subj, corr_good_subj] = parse_subj_info2(regressors_tbl, subj_ids, grp_est, fil_est, reg_est, score_est, discard_bad_ind)

fprintf('\tParsing subject information from %s...\n', regressors_tbl);

if isempty(regressors_tbl)
    error('A discription table file (*.csv, *.xls) is expected!')    
end

% parse regressors begin
[aa, bb, tbl] = xlsread(regressors_tbl); %#ok<*ASGLU>
tbl_title = tbl(1, :);
tbl_data = tbl(2:end, :);

[tbl_fns, fns_good] = chk_tbl_cols(tbl_data, tbl_title, {'name'}, 'str');
if numel(unique(tbl_fns)) ~= numel(tbl_fns)
    error('Duplicated subject names are found!');
end
tbl_good = fns_good;

[tbl_use, use_good] = chk_tbl_cols(tbl_data, tbl_title, {'use'}, 'logic');
if ~isempty(tbl_use)
    tbl_good = tbl_good & use_good;
end

[tbl_grp, grp_good] = chk_tbl_cols(tbl_data, tbl_title, {'group'}, 'str');
tbl_good = tbl_good & grp_good;

if ~isempty(fil_est)
    [tbl_fil, fil_good] = chk_tbl_cols(tbl_data, tbl_title, {'filter'}, 'str');
    tbl_good = tbl_good & fil_good;
end

if ~isempty(reg_est)
    [tbl_reg, reg_good] = chk_tbl_cols(tbl_data, tbl_title, reg_est, 'number');
    tbl_good = tbl_good & reg_good;
end

if ~isempty(score_est)
    tbl_corr = chk_tbl_cols(tbl_data, tbl_title, score_est, 'number');
%     tbl_good = tbl_good & corr_good;
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
[data_fns_ind_tmp, subj_loc_tmp] = ismember(lower(subj_ids), lower(tbl_fns_good_tmp));
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


function [col_data, col_data_good] = chk_tbl_cols(tbl_data, tbl_title, col_strs, col_type)

col_ind_tmp = cellfun(@(x) strcmpi(tbl_title, x), col_strs, 'UniformOutput', false);
col_num = cellfun(@sum, col_ind_tmp);

if strcmpi(col_type, 'logic')
    if any(col_num ~= 1)
        col_data = [];
        col_data_good = [];
        return;
    else
        fprintf('\tA title of "use" is detected!\n\tApplying to filter...\n');
    end
else
    if any(col_num ~= 1)
        error('None or more than one column of %s has been found!', col_strs{col_num ~= 1});
    end
end

col_ind = cellfun(@find, col_ind_tmp);
col_data_tmp = tbl_data(:, col_ind);

switch(col_type)
    case 'str'
        num_ind = cellfun(@isnumeric, col_data_tmp);
        col_data = col_data_tmp;
        if any(num_ind)
            col_data(num_ind) = cellfun(@num2str, col_data_tmp(num_ind), 'UniformOutput', false);
        end
        col_data_good = sum(cellfun(@isempty, col_data), 2) == 0;
    case 'number'
        col_data = cellfun(@(x) double(x), col_data_tmp);
        col_data_good = sum(~isfinite(col_data), 2) == 0;
    case 'logic'
        col_data = cell2mat(col_data_tmp);
        col_data_good = col_data == 1;
    otherwise
end