function dir_out = brant_make_outdir(rootdir, subdirs)
% check and create directories for sub-output folders

n_dir = numel(subdirs);
dir_out = cell(n_dir, 1);

for m = 1:n_dir
    if ~isempty(subdirs{m})
        dir_out{m} = fullfile(rootdir, subdirs{m});
        if exist(dir_out{m}, 'dir') ~= 7
            mkdir(dir_out{m});
        end
    end
end

