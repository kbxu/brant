function [split_prefix, split_strs] = brant_parse_filetype(filetype)
% return possiblel combinations of the input filetype
% should be [str1+str2+str3] structure in filetype
% no space is allowed

rep_str = regexp(filetype, '(\[[\w\+]+\])', 'match');
if ~isempty(rep_str)
    split_process = cellfun(@(x) regexp(x(2:end-1), '+', 'split'), rep_str, 'UniformOutput', false);
    split_num = cellfun(@numel, split_process);
    split_vec = arrayfun(@(x) 1:x, split_num, 'UniformOutput', false);
    comb_ind = combvec(split_vec{:})';
    comb_size = size(comb_ind);
    
    split_prefix = cell(comb_size(1), 1);
    split_strs = cell(comb_size(1), 1);
    for m = 1:comb_size(1)
        split_prefix{m} = filetype;
        split_strs{m} = [];
        for n = 1:comb_size(2)
            split_prefix{m} = strrep(split_prefix{m}, rep_str{n}, split_process{n}{comb_ind(m, n)});
            split_strs{m} = [split_strs{m}, split_process{n}{comb_ind(m, n)}];
        end
    end
else
    split_prefix{1} = filetype;
    split_strs = '';
end
