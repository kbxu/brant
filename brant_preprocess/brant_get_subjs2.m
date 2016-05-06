function file_subj = brant_get_subjs2(file_dirs, single_3d, filetype)

data_input.dirs = file_dirs;
data_input.single_3d = single_3d;
data_input.filetype = filetype;
file_subj = brant_get_subjs(data_input);
