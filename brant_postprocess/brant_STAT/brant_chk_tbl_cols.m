function [col_data, col_data_good] = brant_chk_tbl_cols(tbl_data, tbl_title, col_strs, col_type)

col_ind_tmp = cellfun(@(x) strcmpi(tbl_title, x), col_strs, 'UniformOutput', false);
col_num = cellfun(@sum, col_ind_tmp);

if any(col_num ~= 1)
    error('None or more than one column of %s!', col_strs{col_num ~= 1});
end

col_ind = cellfun(@find, col_ind_tmp);
col_data_tmp = tbl_data(:, col_ind);

switch(col_type)
    case 'str'
        col_data = col_data_tmp;
        col_data_good = sum(cellfun(@isempty, col_data), 2) == 0;
    case 'number'
        col_data = cellfun(@(x) str2double(x), col_data_tmp);
        col_data_good = sum(~isfinite(col_data), 2) == 0;
    otherwise
end
