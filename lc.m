function file_paths = lc(varargin)
% tarfile - target file to store results
% filepattern - pattern of file in regular expression
% filetype, 'f' - regular file, 'd' - folder, 'a' - all
% last modified -- 2014-11-26

if nargin == 0
    tarfile = '';
    filepat = '*';
    filetype = 'd';
elseif nargin == 1
    tarfile = varargin{1};
    filepat = '*';
    filetype = 'd';
elseif nargin == 2
    tarfile = varargin{1};
    filepat = varargin{2};
    filetype = 'a';
elseif nargin == 3
    tarfile = varargin{1};
    filepat = varargin{2};
    filetype = varargin{3};
else
    error('Wrong Input!');
end

files = dir(fullfile(pwd, filepat));

if filetype == 'd'
    file_ind = arrayfun(@(x) x.isdir == 1 && any(strcmp(x.name, {'.', '..'})) == 0, files);
elseif filetype == 'f'
    file_ind = arrayfun(@(x) x.isdir == 0, files);
else
    file_ind = arrayfun(@(x) any(strcmp(x.name, {'.', '..'})) == 0, files);
end

file_good = files(file_ind);

file_paths = arrayfun(@(x) fullfile(pwd, x.name), file_good, 'UniformOutput', false);
disp(file_paths);

if nargin > 0 && numel(file_paths) > 0 && ~isempty(tarfile)
    fid = fopen(tarfile, 'wt');
    for m = 1:numel(file_paths)
        fprintf(fid, '%s\n', file_paths{m});
    end
    fclose(fid);
end