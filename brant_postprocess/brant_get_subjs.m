function [nifti_list, subj_ids] = brant_get_subjs(data_input)


input_dirs = data_input.dirs;

if isfield(data_input, 'nm_pos')
    input_nmpos = data_input.nm_pos;
else
    input_nmpos = [];
end

if isfield(data_input, 'check_tps_ind')
    check_tps_ind = data_input.check_tps_ind;
else
    check_tps_ind = 1;
end

if isfield(data_input, 'filetype')
    if isfield(data_input, 'is4d') % multi-4D or multi-3D
        if data_input.is4d == 1
            [nifti_list, subj_ids] = brant_get_subjs_multi4d_single3d(input_nmpos, input_dirs, data_input.filetype, 'multi4d', check_tps_ind);
        else
            [nifti_list, subj_ids] = brant_get_subjs_multi3d(input_nmpos, input_dirs, data_input.filetype, check_tps_ind);
        end
    else %if isfield(data_input, 'single_3d')
        % single-3D or other cases, e.g. rp*.txt
        [nifti_list, subj_ids] = brant_get_subjs_multi4d_single3d(input_nmpos, input_dirs, data_input.filetype, 'single3d', check_tps_ind);
    end
else
    
    nifti_list = cellfun(@(x) regexprep(x, '[\\\/]+$', ''), input_dirs, 'UniformOutput', false);
%     nifti_list = input_dirs;
    subj_ids = brant_get_subj_ids(input_nmpos, input_dirs);
end

function subj_ids = brant_get_subj_ids(nm_pos, input_dirs)

% with input only data directories, e.g. dicom convert
if nm_pos <= 0
    error('If the input is multiple 3d data for each subject, name position is expected to be greater than 0!');
end

fns = cellfun(@(x) regexp(x, filesep, 'split'), input_dirs, 'UniformOutput', false);
num_fns = cellfun(@numel, fns);
end_fsep = cellfun(@(x) x(end) == filesep, input_dirs);
nm_pos_eff = end_fsep + nm_pos - 1;
nm_ind = nm_pos_eff > num_fns;
if any(nm_ind)
    error([sprintf('%s\n', input_dirs{nm_ind}),...
           sprintf('Please check name position!\n')]);
end
subj_ids = arrayfun(@(x, y, z) x{1}{y - z}, fns, num_fns, nm_pos_eff, 'UniformOutput', false);
subj_ids_src = input_dirs;

num_subj = numel(subj_ids);
[uniq_fns, ia] = unique(subj_ids);
if numel(ia) < num_subj
    ia_overlap = setdiff(1:num_subj, ia);
    error([sprintf('%s\n', subj_ids_src{ia_overlap}),...
           sprintf('Listed filenames are overlapped, please check your data!\n')]);
end


function [nifti_list, subj_ids] = brant_get_subjs_multi4d_single3d(nm_pos, input_dirs, filetype, input_type, check_tps_ind)

if ~isempty(nm_pos)
    [pth_tmp, fn_tmp, ext_ft] = fileparts(filetype); %#ok<*ASGLU>
    if strcmpi(input_type, 'multi4d')
        if nm_pos < 0
            error('If the input is multiple 4d data for each subject, name position is expected to be equal or greater than 0!');
        elseif nm_pos == 0
            if any(strcmpi(ext_ft, {'.img', '.hdr'}))
                error('If the input datatype is *.img/hdr, which is 3d nifti datatype, name position is expected to be greater than 0!');
            end
        end
    elseif strcmpi(input_type, 'single3d')
        if nm_pos < 0
            error('If the input is single 3d data for each subject, name position is expected to be equal or greater than 0!');
        end
    else
        error('Don''t know what to do...');
    end
end

% get data files
data_type = cellfun(@(x) fullfile(x, filetype), input_dirs, 'UniformOutput', false);
data_match = cellfun(@dir, data_type, 'UniformOutput', false);
empt_ind = cellfun(@isempty, data_match);
if any(empt_ind)
    error([sprintf('%s\n', input_dirs{empt_ind}),...
           sprintf('No %s files were found in\n', filetype)]);
end

if (strcmpi(input_type, 'single3d') && (numel(input_dirs) > 1))
    num_match = cellfun(@numel, data_match);
    bad_ind = num_match ~= 1;
    if any(bad_ind)
        error([sprintf('%s\n', input_dirs{bad_ind}),...
           sprintf('No or more than one %s files were found in\n', filetype)]);
    end
end

nifti_list_tmp = cell(numel(input_dirs), 1);
for m = 1:numel(input_dirs)
    nifti_list_tmp{m} = arrayfun(@(x) fullfile(input_dirs{m}, x.name), data_match{m}, 'UniformOutput', false);
end
nifti_list = cat(1, nifti_list_tmp{:});

% get subject ids
if isempty(nm_pos)
    subj_ids = '';
else
    num_match = cellfun(@numel, data_match);
    if nm_pos > 0
        multi_file_ind = num_match > 1;
        if any(multi_file_ind)
            error([sprintf('%s\n', input_dirs{multi_file_ind}),...
                   sprintf('More than one %s files were found in above directories\n', filetype)]);
        end
    end

    % parse subject ids
    if nm_pos == 0
        [pth, fns_tmp] = cellfun(@fileparts, nifti_list, 'UniformOutput', false);
        subj_ids = cellfun(@(x) regexprep(x, '.(nii|nii.gz|hdr|img)$', '', 'ignorecase'), fns_tmp, 'UniformOutput', false);
        subj_ids_src = nifti_list;
    else
        fns = cellfun(@(x) regexp(x, filesep, 'split'), input_dirs, 'UniformOutput', false);
        num_fns = cellfun(@numel, fns);
        end_fsep = cellfun(@(x) x(end) == filesep, input_dirs);
        nm_pos_eff = end_fsep + nm_pos - 1;
        nm_ind = nm_pos_eff > num_fns;
        if any(nm_ind)
            error([sprintf('%s\n', input_dirs{nm_ind}),...
                   sprintf('Please check name position!\n')]);
        end
        subj_ids = arrayfun(@(x, y, z) x{1}{y - z}, fns, num_fns, nm_pos_eff, 'UniformOutput', false);
        subj_ids_src = input_dirs;
    end

    num_subj = numel(subj_ids);
    [uniq_fns, ia] = unique(subj_ids);
    if numel(ia) < num_subj
        ia_overlap = setdiff(1:num_subj, ia);
        error([sprintf('%s\n', subj_ids_src{ia_overlap}),...
               sprintf('Listed filenames are overlapped, please check your data!\n')]);
    end

    if check_tps_ind == 1
        if strcmpi(input_type, 'multi4d')
            fprintf('\tChecking timepoints...\n');
            tps_tps = cellfun(@brant_get_nii_frame, nifti_list);
            input_tps = strcat('Timepoints:', num2str(tps_tps, '%d'), char(7), nifti_list);
            fprintf('\t%s\n', input_tps{:});
        end
    end
end

function [nifti_list, subj_ids] = brant_get_subjs_multi3d(nm_pos, input_dirs, filetype, check_tps_ind)

if ~isempty(nm_pos)
    if nm_pos <= 0
        error('If the input is multiple 3d data for each subject, name position is expected to be greater than 0!');
    end
end

data_type = cellfun(@(x) fullfile(x, filetype), input_dirs, 'UniformOutput', false);
data_match = cellfun(@dir, data_type, 'UniformOutput', false);
empt_ind = cellfun(@isempty, data_match);
if any(empt_ind)
    error([sprintf('%s\n', input_dirs{empt_ind}),...
           sprintf('No %s files were found in\n', filetype)]);
end

nifti_list = cell(numel(input_dirs), 1);
for m = 1:numel(input_dirs)
    nifti_list{m} = arrayfun(@(x) fullfile(input_dirs{m}, x.name), data_match{m}, 'UniformOutput', false);
end

if isempty(nm_pos)
    subj_ids = '';
else
    fns = cellfun(@(x) regexp(x, filesep, 'split'), input_dirs, 'UniformOutput', false);
    num_fns = cellfun(@numel, fns);
    end_fsep = cellfun(@(x) x(end) == filesep, input_dirs);

    nm_pos = end_fsep + nm_pos - 1;
    nm_ind = nm_pos > num_fns;
    if any(nm_ind)
        error([sprintf('%s\n', input_dirs{nm_ind}),...
               sprintf('Please check name position!\n')]);
    end

    subj_ids = arrayfun(@(x, y, z) x{1}{y - z}, fns, num_fns, nm_pos, 'UniformOutput', false);
    
    if check_tps_ind == 1
        [pth_tmp, fn_tmp, ext_ft] = fileparts(filetype);
        if any(strcmpi(ext_ft, {'.nii', '.img', '.hdr', '.nii.gz'}))
            num_match = cellfun(@numel, data_match);
            input_tps = strcat('Timepoints:', num2str(num_match, '%d'), char(7), subj_ids);
            fprintf('\t%s\n', input_tps{:});
        end
    end
end
