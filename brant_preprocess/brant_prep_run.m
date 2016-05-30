function run_data = brant_prep_run(h_main_data, pre_processes)

% % subject settings
% run_data.subj.text.inputfile = '';
% run_data.subj.text.dirs = '';
% run_data.subj.text.files = '';
% run_data.subj.spm.dirs = '';
% run_data.subj.spm.files = '';
% run_data.subj.filetype = 'brant*.nii';
% 
% run_data.subj.out.selected = 0;
% run_data.subj.out.dir = '';
% run_data.subj.out.nmpos = '1';
% 
% % reserved
% run_data.pref.parallel = 'off';
% run_data.pref.sync = 1;
% run_data.pref.order = {'slicetiming', 'realign', 'normalise', 'denoise', 'filter', 'smooth'};
% run_data.pref.dirs_in_text = 0;
% 
% % index
% run_data.ind.slicetiming = 0;
% run_data.ind.realign = 0;
% run_data.ind.normalise = 0;
% run_data.ind.denoise = 0;
% run_data.ind.filter = 0;
% run_data.ind.smooth = 0;

% pre_processes = h_main_data.pref.order(h_main_data);

for m = 1:numel(pre_processes)
    
    switch(pre_processes{m})
        case 'slicetiming'
            % slice timing
            sub_fns = '';
            num_fns = {{'slice_order', 'tr', 'refslice'}};
            str_fns = {{'prefix'}};
            file_fns = {''};
            
        case 'realign'
            
            sub_fns = {'eoptions', 'roptions'};
            num_fns = {{'quality', 'sep', 'fwhm', 'rtm', 'wrap', 'interp'}, {'which', 'interp', 'wrap', 'mask', 'prefix'}};
            str_fns = {'', {'prefix'}};
            file_fns = {'', ''};
%             file_fns = {{'weight'}, ''};
            % estimate
%             run_data.realign.eoptions.quality = '0.9';
%             run_data.realign.eoptions.sep = '4';
%             run_data.realign.eoptions.fwhm = '5';
%             run_data.realign.eoptions.rtm = '1';
%             run_data.realign.eoptions.wrap = '0 0 0';
%             run_data.realign.eoptions.weight = '';
%             run_data.realign.eoptions.interp =  '4';
%             % write
%             run_data.realign.roptions.which = '2 1';
%             run_data.realign.roptions.interp = '4';
%             run_data.realign.roptions.wrap = '0 0 0';
%             run_data.realign.roptions.mask = '1';
%             run_data.realign.roptions.prefix = 'r';

        case 'normalise'
            
            sub_fns = {'subj', 'eoptions', 'roptions'};
            num_fns = {'', {'smosrc', 'smoref', 'cutoff', 'nits', 'reg'}, {'preserve', 'bb', 'vox', 'interp', 'wrap'}};
            str_fns = {{'filetype'}, {'regtype'}, {'prefix'}};
            file_fns = {{'source', 'wtsrc'}, {'template'}, ''};
%             file_fns = {{'template', 'weight'}, ''};
%             % estimate
%             run_data.normalise.eoptions.template = fullfile(fileparts(which('spm')),'templates/EPI.nii');
%             run_data.normalise.eoptions.weight = '';   % template weighting image
%             run_data.normalise.eoptions.smosrc = '8';    % source image smoothing
%             run_data.normalise.eoptions.smoref = '0';    % template image smoothing
%             run_data.normalise.eoptions.regtype = 'mni';
%             run_data.normalise.eoptions.cutoff = '25';
%             run_data.normalise.eoptions.nits = '30';
%             run_data.normalise.eoptions.reg = '1';
%             % write
%             run_data.normalise.roptions.preserve = '0';
%             run_data.normalise.roptions.bb = '-90 -126 -72;90 90 108';
%             run_data.normalise.roptions.vox = '2 2 2';
%             run_data.normalise.roptions.interp = '5';
%             run_data.normalise.roptions.wrap = '0 0 0';
%             run_data.normalise.roptions.prefix = 'w';

        case 'denoise'
            
            sub_fns = {'subj', 'detrend', 'mask', 'motion'};
            
            num_fns = {{'timepoints', 'voxelsize', 'gzip'}, {'constant', 'linear_drift'},...
                       {'glob'}, {'head', 'deriv'}};
            str_fns = {{'prefix'}, '', '', ''};
            file_fns = {'', '', {'wholebrain', 'wm', 'gm', 'csf'}, ''};
            
%             run_data.denoise.subj.timepoints = '0';
%             run_data.denoise.subj.voxelsize = '2 2 2';
%             run_data.denoise.subj.prefix = 'd';
%             run_data.denoise.detrend.constant = 0;
%             run_data.denoise.detrend.linear_drift = 0;
%             run_data.denoise.mask.wholebrain = fullfile(brant_path, 'template', 'fmaskEPI_V2mm.nii');
%             run_data.denoise.mask.wm = fullfile(brant_path, 'template', 'fmaskEPI_V2mm_CSF.nii');
%             run_data.denoise.mask.gm = '';
%             run_data.denoise.mask.csf = fullfile(brant_path, 'template', 'fmaskEPI_V2mm_WM.nii');
%             run_data.denoise.mask.glob = 0;
%             run_data.denoise.motion.head = 0;
%             run_data.denoise.motion.deriv = 0;

        case 'filter'
            
            sub_fns = '';
            num_fns = {{'lower_cutoff', 'upper_cutoff', 'tr', 'timepoints', 'gzip'}};
            str_fns = {{'prefix'}};
            file_fns = {{'wb_mask'}};
            
%             run_data.filter.lower_cutoff = '0.01';
%             run_data.filter.upper_cutoff = '0.08';
%             run_data.filter.wb_mask = fullfile(brant_path, 'template', 'fmaskEPI_V2mm.nii');
%             run_data.filter.tr = '0';
%             run_data.filter.timepoints = '0';
%             run_data.filter.prefix = 'f';

        case 'smooth'
            
            sub_fns = '';
            num_fns = {{'fwhm'}};
            str_fns = {{'prefix'}};
            file_fns = {''};
            
%             run_data.smooth.fwhm  = '8 8 8';
%             run_data.smooth.prefix  = 's';
    end
    
    run_data_tmp = brant_prep_check_fns(pre_processes{m}, h_main_data, sub_fns, num_fns, str_fns, file_fns);
    
    run_data.(pre_processes{m}) = run_data_tmp.(pre_processes{m});
end

function run_data = brant_prep_check_fns(pre_process, h_main_data, sub_fns, num_fns, str_fns, file_fns)

run_data.(pre_process) = h_main_data.(pre_process);

if isempty(sub_fns)
    if ~isempty(num_fns{1})
        num_ind = cellfun(@(x) isnumeric(h_main_data.(pre_process).(x)), num_fns{1});
        for n = 1:numel(num_ind)
            if num_ind(n) == 1
                run_data.(pre_process).(num_fns{1}{n}) = h_main_data.(pre_process).(num_fns{1}{n});
            else
                run_data.(pre_process).(num_fns{1}{n}) = str2num(h_main_data.(pre_process).(num_fns{1}{n}));
            end
        end
    end
    if ~isempty(str_fns{1})
        str_ind = cellfun(@(x) ischar(h_main_data.(pre_process).(x)), str_fns{1});
        for n = 1:numel(str_ind)
            if str_ind(n) == 1
                run_data.(pre_process).(str_fns{1}{n}) = h_main_data.(pre_process).(str_fns{1}{n});
            else
                error('%s is not a string!', h_main_data.(pre_process).(str_fns{1}{n}));
            end
        end
    end
    if ~isempty(file_fns{1})
        file_ind = cellfun(@(x) exist(h_main_data.(pre_process).(x), 'file') == 2, file_fns{1});
        for n = 1:numel(file_ind)
            if isempty(h_main_data.(pre_process).(file_fns{1}{n}))
                run_data.(pre_process).(file_fns{1}{n}) = '';
            elseif file_ind(n) == 1
                run_data.(pre_process).(file_fns{1}{n}) = h_main_data.(pre_process).(file_fns{1}{n});
            else
                error('%s not found!', h_main_data.(pre_process).(file_fns{1}{n}));
            end
        end
    end
else
    for m = 1:numel(sub_fns)
        if ~isempty(num_fns{m})
            num_ind = cellfun(@(x) isnumeric(h_main_data.(pre_process).(sub_fns{m}).(x)), num_fns{m});
            for n = 1:numel(num_ind)
                if num_ind(n) == 1
                    run_data.(pre_process).(sub_fns{m}).(num_fns{m}{n}) = h_main_data.(pre_process).(sub_fns{m}).(num_fns{m}{n});
                else
                    run_data.(pre_process).(sub_fns{m}).(num_fns{m}{n}) = str2num(h_main_data.(pre_process).(sub_fns{m}).(num_fns{m}{n}));
                end
            end
        end
        if ~isempty(str_fns{m})
            
            str_ind = cellfun(@(x) ischar(h_main_data.(pre_process).(sub_fns{m}).(x)), str_fns{m});
            for n = 1:numel(str_ind)
                if str_ind(n) == 1
                    run_data.(pre_process).(sub_fns{m}).(str_fns{m}{n}) = h_main_data.(pre_process).(sub_fns{m}).(str_fns{m}{n});
                else
                    error('%s is not a string!', h_main_data.(pre_process).(sub_fns{m}).(str_fns{m}{n}));
                end
            end
        end
        if ~isempty(file_fns{m})
            file_ind = cellfun(@(x) exist(h_main_data.(pre_process).(sub_fns{m}).(x), 'file') == 2, file_fns{m});
            for n = 1:numel(file_ind)
                if isempty(h_main_data.(pre_process).(sub_fns{m}).(file_fns{m}{n}))
                    run_data.(pre_process).(sub_fns{m}).(file_fns{m}{n}) = '';
                elseif file_ind(n) == 1
                    run_data.(pre_process).(sub_fns{m}).(file_fns{m}{n}) = h_main_data.(pre_process).(sub_fns{m}).(file_fns{m}{n});
                elseif any(cell2mat(strfind({'template', 'wholebrain', 'wb_mask'}, file_fns{m}{n})))
                    error('%s not found!', h_main_data.(pre_process).(sub_fns{m}).(file_fns{m}{n}));
                end
            end
        end
    end
end
