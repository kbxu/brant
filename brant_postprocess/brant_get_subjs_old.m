function [nifti_list, subj_ids] = brant_get_subjs(data_input)

input_dirs = data_input.dirs;
input_nmpos = data_input.nm_pos;

if input_nmpos < 0
    error('Name position is expected to be no less than zero!');
end



if ~isfield(data_input, 'filetype')
    if input_nmpos == 0
        error('Name position is expected to be greater than zero!');
    end
    single_3d_ind = 0;
    is4d_ind = 0;
    nifti_list = input_dirs; % in this case output dirs instead of nii files
else
    input_filetype = data_input.filetype;

    % check input file numbers and timepoints
    data_type = cellfun(@(x) fullfile(x, input_filetype), input_dirs, 'UniformOutput', false);
    data_match = cellfun(@dir, data_type, 'UniformOutput', false);
    num_match = cellfun(@numel, data_match);

    empt_ind = cellfun(@isempty, data_match);
    if input_nmpos == 0
        num_match = sum(num_match);
        if all(empt_ind)
            error([sprintf('No %s files were found in\n', input_filetype),...
                   sprintf('%s\n', input_dirs{empt_ind})]);
        end
    else
        if any(empt_ind)
            error([sprintf('No %s files were found in\n', input_filetype),...
                   sprintf('%s\n', input_dirs{empt_ind})]);
        end
    end
        
    if isfield(data_input, 'is_txt')
        is_txt = data_input.is_txt;
    else
        is_txt = 0;
    end
    
    if isfield(data_input, 'single_3d')
        single_3d_ind = data_input.single_3d;
        is4d_ind = 0;
    elseif isfield(data_input, 'is4d')
        if data_input.is4d == 1
            single_3d_ind = 0;
            is4d_ind = data_input.is4d;
        else
            single_3d_ind = 0;
            is4d_ind = data_input.is4d;
        end
    else
        single_3d_ind = 0;
        is4d_ind = 0;
    end

    if single_3d_ind == 1 || is4d_ind == 1 || is_txt == 1
        nifti_list_tmp = cell(numel(input_dirs), 1);
        for m = 1:numel(input_dirs)
            nifti_list_tmp{m} = arrayfun(@(x) fullfile(input_dirs{m}, x.name), data_match{m}, 'UniformOutput', false);
        end
        nifti_list = cat(1, nifti_list_tmp{:});
    else
        nifti_list = cell(numel(input_dirs), 1);
        for m = 1:numel(input_dirs)
            nifti_list{m} = arrayfun(@(x) fullfile(input_dirs{m}, x.name), data_match{m}, 'UniformOutput', false);
        end
    end
end
% parse subject names

if input_nmpos == 0 
    
    fns_split = cellfun(@(x) regexp(x, filesep, 'split'), nifti_list, 'UniformOutput', false);
    subj_ids = cellfun(@(x) regexprep(x{end}, '.(nii|nii.gz|hdr|img)$', '', 'ignorecase'), fns_split, 'UniformOutput', false);
    
else
    fns = cellfun(@(x) regexp(x, filesep, 'split'), input_dirs, 'UniformOutput', false);
    num_fns = cellfun(@numel, fns);
    end_fsep = cellfun(@(x) x(end) == filesep, input_dirs);

    if numel(input_nmpos) > 0
        nm_pos = end_fsep + input_nmpos - 1;
        if any(nm_pos > num_fns)
            error(sprintf('Please check the position of output filename!\n')); %#ok<SPERR>
        end
        subj_ids = arrayfun(@(x, y, z) x{1}{y - z}, fns, num_fns, nm_pos, 'UniformOutput', false);
    else
        error('The arrange of data is not allowed!');
    end
end

if isfield(data_input, 'filetype')
    if single_3d_ind == 0 && numel(subj_ids) < numel(nifti_list)
        error('More than one files are found in one directory, please either change name position to 0 or re-arrange your data.');
    end
end

num_subj = numel(subj_ids);
uni_subj_ids = unique(subj_ids);
% disp(subj_ids);
if numel(uni_subj_ids) < num_subj
    num_same = cell2mat(cellfun(@(x) numel(find(strcmp(x, subj_ids))), uni_subj_ids, 'UniformOutput', false));
    num_same_id = num_same > 1;
    error([sprintf('For subject identities, please input a unique token for each subject (check name positions)!\n'),...
           sprintf('The following subject ids have more than one input.\n'),...
           sprintf('\t%s\n', uni_subj_ids{num_same_id})]);
end

if isfield(data_input, 'filetype')
    if single_3d_ind == 0
        if is4d_ind == 1 || is_txt == 1
            if input_nmpos > 0
                [pth, fn, ext] = cellfun(@(x) fileparts(x(1).name), data_match, 'UniformOutput', false); %#ok<*ASGLU>
                ind_4d = num_match ~= 1;
                if any(ind_4d)
                    error([sprintf('More than one %s files were found in\n', input_filetype),...
                           sprintf('%s\n', input_dirs{ind_4d})]);
                end

                nifti_list = cellfun(@(x, y) fullfile(x, y.name), input_dirs, data_match, 'UniformOutput', false);
                
                if is4d_ind == 1
                    if all(cellfun(@(x) strcmpi(x, '.gz') == 0, ext))
                        tps_tps = cell2mat(cellfun(@get_nii_frame, nifti_list, 'UniformOutput', false));
                        input_tps = strcat(nifti_list, ', timepoints:', num2str(tps_tps, '%d'));
                        fprintf('\t%s\n', input_tps{:});
                    else
                        fprintf('Brant will generate a list of timepoints later in the purpose of efficiency!\n');
                    end
                end
            end
        else
            ind_3d = num_match == 1;
            if any(ind_3d)
                error([sprintf('Only one 3-D nifti file was found in\n'),...
                       sprintf('%s\n', input_dirs{ind_3d})]);
            end

%             nifti_list = cell(numel(input_dirs), 1);
%             for m = 1:numel(input_dirs)
%                 nifti_list{m} = arrayfun(@(x) fullfile(input_dirs{m}, x.name), data_match{m}, 'UniformOutput', false);
%             end
            input_tps = strcat(input_dirs, ', timepoints:', num2str(num_match, '%d'));
            fprintf('\t%s\n', input_tps{:});
        end
    end
end

fprintf('\n');
