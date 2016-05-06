function brant_dir(srcdir, allowed_filetype, reg_filetype)

files = cell(numel(allowed_filetype), 1);
for m = 1:numel(allowed_filetype)
    file_tmp = dir(fullfile(srcdir, allowed_filetype{m}));
    match_tmp = arrayfun(@(x) regexp(x.name, reg_filetype, 'match'), file_tmp, 'UniformOutput', false);
    
    if iscell(reg_filetype)
        match_tmp_2 = zeros(numel(file_tmp), numel(reg_filetype));
        for n = 1:numel(reg_filetype)
            match_tmp_2(:, n) = cell2mat(cellfun(@(x) isempty(x{n}), match_tmp, 'uniformoutput', false));
        end
        match_ind = sum(match_tmp_2, 2) > 0;
    else
        match_ind = cellfun(@(x) isempty(x{1}), match_tmp, 'uniformoutput', false);
    end
    
    file_ok = file_tmp(match_ind);
    if ~isempty(file_ok)
        files{m} = arrayfun(@(x) x.name, file_ok);
    end
end
