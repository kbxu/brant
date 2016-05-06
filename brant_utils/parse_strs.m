function str_sp = parse_strs(str_raw, str_name, ness_ind)

if isempty(str_raw)
    if ness_ind == 1
        error('There should be at least one column of %s!', str_name);
    end
    str_sp = '';
else
    str_sp = regexp(str_raw, '[;,]', 'split');
    str_sp = strtrim(str_sp);
end