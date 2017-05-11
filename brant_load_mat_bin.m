function data_mat = brant_load_mat_bin(fn, size_data, type_data)
% to load numeric matrics from binary files
% fn: fullpath filename
% size_data: size of numeric matrix to load, e.g. [100, 20]
% type_data: type of numeric matrix to load, e.g. 'single', 'double'

fid = fopen(fn, 'rt');

if fid == -1
    error('File open error!\nPlease check file permissions of %s\nor folder permissions of %s\n', fn, fileparts(fn));
end

data_mat = fread(fid, size_data, ['*', type_data]);
fclose(fid);