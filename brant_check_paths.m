function brant_check_paths
% check and update paths of brant and it's dependent packages

brant_path = fileparts(which(mfilename));
path_file_brant = fullfile(brant_path, 'config_paths', 'brant_paths.txt');

path_file_spm = fullfile(brant_path, 'config_paths', 'spm_paths.txt');
hid_path_file_spm = fullfile(brant_path, 'config_paths', 'spm_hidden_paths.txt');

searpaths = regexp(path, pathsep, 'split');

if ~any(strcmpi(searpaths, brant_path))
    addpath(brant_path);
end

spm_full = which('spm');
if isempty(spm_full)
    error('Spm paths should be added!');
else
    spm_path = fileparts(spm_full);
end

% configure paths for brant and brant's dependencies
add_rm_prop_paths(searpaths, brant_path, path_file_brant, 'add');

% check paths for spm
add_rm_prop_paths(searpaths, spm_path, path_file_spm, 'add');
add_rm_prop_paths(searpaths, spm_path, hid_path_file_spm, 'rm');

warning('off', 'MATLAB:mir_warning_changing_try_catch');
try
    savepath; 
catch
end
warning('on', 'MATLAB:mir_warning_changing_try_catch');

function add_rm_prop_paths(searpaths, root_path, path_file, opt)
% add or remove paths from search paths

paths_tmp = importdata(path_file, '\n');
paths_tmp_prop = cellfun(@(x) regexprep(x, '[\\\/]', filesep), paths_tmp, 'UniformOutput', false);
paths_tmp_prop_full = fullfile(root_path, paths_tmp_prop);

if strcmp(opt, 'add')
    nexist_ind = cellfun(@(x) ~any(strcmpi(searpaths, x)) && exist(x, 'dir') == 7, paths_tmp_prop_full);
    if any(nexist_ind)
        arrayfun(@(x) addpath(paths_tmp_prop_full{x}), find(nexist_ind));
    end
else
    exist_ind = cellfun(@(x) any(strcmpi(searpaths, x)), paths_tmp_prop_full);
    if any(exist_ind)
        arrayfun(@(x) rmpath(paths_tmp_prop_full{x}), find(exist_ind));
    end
end