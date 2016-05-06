function file_dirs = brant_get_dirs_from_data(data_cells, is_4d)

if is_4d == 1
    file_dirs = cellfun(@fileparts, data_cells, 'UniformOutput', false);
else
    file_dirs = cellfun(@(x) fileparts(x{1}), data_cells, 'UniformOutput', false);
end
