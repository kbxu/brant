function size_data = brant_save_mat_bin(fn, data_mat, type_data)
% to save numeric matrics to binary files
% fn: fullpath filename
% type_data: type of numeric matrix to load, e.g. 'single', 'double'
% size_data: return the size of input data, e.g. [100, 20]

size_data = size(data_mat);

fid = fopen(fn, 'wt');

if fid == -1
    error('File open error!\nPlease check file permissions of %s\nor folder permissions of %s\n', fn, fileparts(fn));
end

fwrite(fid, data_mat, type_data);
fclose(fid);