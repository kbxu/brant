function [data_infos, subj_ind, fil_inds] = brant_parse_subj_info3(regressors_tbl, subj_ids, grp_est, fil_est)
% for paired t-test only

fprintf('\tParsing subject information from %s...\n', regressors_tbl);

if isempty(regressors_tbl)
    error('A discription csv file is expected!'); 
end

% parse regressors begin
tbl = brant_read_csv(regressors_tbl);
tbl_title = tbl(1, :);
tbl_data = tbl(2:end, :);

num_grp = numel(grp_est);
tbl_fns_tmp = cell(1, num_grp);
fns_good = cell(1, num_grp);
for m = 1:num_grp
	[tbl_fns_tmp{m}, fns_good{m}] = brant_chk_tbl_cols(tbl_data, tbl_title, grp_est(m), 'str');
end
tbl_fns = cat(2, tbl_fns_tmp{:});
tbl_good = sum(cat(2, fns_good{:}), 2) == num_grp;

if ~isempty(fil_est)
    [tbl_fil, fil_good] = brant_chk_tbl_cols(tbl_data, tbl_title, {'filter'}, 'str');
    tbl_good = tbl_good & fil_good;
end

% find out whether data exist
tbl_good_tmp = true;
tbl_fns_good_tmp = tbl_fns(tbl_good, :);
subj_ind_tbl = zeros(size(tbl_fns_good_tmp, 1), num_grp);
for m = 1:num_grp
    [subj_ind, subj_loc] = ismember(lower(tbl_fns_good_tmp(:, m)), lower(subj_ids));
    subj_ind_tbl(:, m) = subj_loc(subj_ind);
    tbl_good_tmp = tbl_good_tmp & subj_ind;
end

data_infos = [grp_est; tbl_fns_good_tmp(tbl_good_tmp, :)];
subj_ind = subj_ind_tbl(tbl_good_tmp, :);

if ~isempty(fil_est)
    tbl_fil_good = tbl_fil(tbl_good);
    fil_inds = cellfun(@(x) strcmpi(x, tbl_fil_good), fil_est, 'UniformOutput', false);
else
    fil_inds{1} = 1;
end
