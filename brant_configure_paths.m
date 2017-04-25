function brant_configure_paths(varargin)
% varargin{1}: path of spm
% if no input, add paths of BRANT

if nargin == 0
    brant_path = fileparts(which(mfilename));
    fprintf('Configuring paths for BRANT...\n\tOperation: add %s with subfolders...\n', brant_path);
    % remove and add paths
    rmpath(genpath(brant_path));
    addpath(genpath(brant_path));
elseif nargin == 1
    spm_path = varargin{1};
    if exist(spm_path, 'dir') ~= 7
        error('Path %s does not exist!', spm_path);
    end
    
    spm_full = fullfile(spm_path, 'spm.m');
    if exist(spm_full, 'file') ~= 2
        error('File %s does not exist!', spm_full);
    end
    
    fprintf('Configuring paths for SPM...\n\tOperation: add %s with root folder\n\tand run spm_jobman(init)...\n', spm_path);
    rmpath(genpath(spm_path));
    addpath(spm_path);
    spm_jobman('initcfg');
else
    error('Unknown Operation!');
end

try
    savepath;
    fprintf('Configuration finished!\n');
catch
    warning('Current path configuration cannot be saved, please try again with administrator user or the default user!');
end