function data_out = brant_file_pre(data_files, num_niis, is4d_ind, data_outtype)
% convert data filenames to spm compatable filenames

data_out = cell(numel(data_files), 1);
if is4d_ind == 1
    switch(data_outtype)
        case 'data_matrix',
            for m = 1:numel(data_files)
                seq_str = arrayfun(@(x) num2str(x, ',%04d'), 1:num_niis(m), 'UniformOutput', false);
                data_out{m} = cell2mat(strcat(data_files{m}, seq_str'));
            end
        case 'data_cell'
            for m = 1:numel(data_files)
                seq_str = arrayfun(@(x) num2str(x, ',%04d'), 1:num_niis(m), 'UniformOutput', false);
                data_out{m} = strcat(data_files{m}, seq_str');
            end
    end
else
    switch(data_outtype)
        case 'data_matrix',
            for m = 1:numel(num_niis)
                data_out{m} = cell2mat(strcat(data_files{m}, ',0001'));
            end
        case 'data_cell',
            for m = 1:numel(num_niis)
                data_out{m} = strcat(data_files{m}, ',0001');
            end
    end
end