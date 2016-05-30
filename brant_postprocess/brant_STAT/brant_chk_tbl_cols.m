function [col_data, col_data_good] = brant_chk_tbl_cols(tbl_data, tbl_title, col_strs, col_type)

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
        col_data_good = sum([cellfun(@isempty, col_data), cellfun(@(x) strcmpi(x, 'nan')|strcmpi(x, 'inf'), col_data)], 2) == 0;
    case 'number'
        col_data = cellfun(@(x) double(x), col_data_tmp);
        col_data_good = sum(~isfinite(col_data), 2) == 0;
    case 'logic'
        col_data = cell2mat(col_data_tmp);
        col_data_good = col_data == 1;
    otherwise
end
