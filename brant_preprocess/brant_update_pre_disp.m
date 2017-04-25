function string_disp = brant_update_pre_disp

h_main = findobj(0, 'Name',             'brant_Preprocessing',...
    'Tag',              'brant_preprocess_main');

h_disp = findobj(0, 'Name',             'brant_CheckBoard',...
    'Tag',              'brant_preprocess_check');

h_para_disp = findobj(h_disp, 'Tag', 'info_label_chbd');
h_para_disp_sel = findobj(h_disp, 'Tag', 'disp_only_sel_chbd');
only_sel_disp = get(h_para_disp_sel, 'Value');

if isempty(h_main) || isempty(h_disp)
    error('Brant preprocessing main figure is not open!');
end

main_data = get(h_main, 'Userdata');
string_disp = '';
cnt = 1;

m_steps = numel(main_data.pref.order);
str_sel = '';

for m = 1:m_steps
    
    if only_sel_disp == 0
        if main_data.ind.(main_data.pref.order{m}) == 1
            str_sel = 'selected';
        else
            str_sel = 'not selected';
        end
    else
        if main_data.ind.(main_data.pref.order{m}) == 0
            continue;
        end
    end
    if strcmpi(main_data.pref.order{m}, 'denoise') == 1
        [string_disp_denoise, cnt] = parse_denoise_strs(main_data.denoise);
        string_disp = [string_disp; string_disp_denoise]; %#ok<AGROW>
        continue;
    end
    string_disp{cnt, 1} = strcat(upper(main_data.pref.order{m}), 32, str_sel);
    cnt = cnt + 1;
    sub_fields = fieldnames(main_data.(main_data.pref.order{m}));
    n_sub = numel(sub_fields);
    for n = 1:n_sub
        if isstruct(main_data.(main_data.pref.order{m}).(sub_fields{n}))
            string_disp{cnt, 1} = strcat(upper(sub_fields{n}(1)), sub_fields{n}(2:end), ':');
            cnt = cnt + 1;
            sub_sub_fields = fieldnames(main_data.(main_data.pref.order{m}).(sub_fields{n}));
            n_sub_sub = numel(sub_sub_fields);
            for nn = 1:n_sub_sub
                if isnumeric(main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn}))
                    str_tmp = num2str(main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn}));
                    
                    if size(str_tmp, 1) > 1
                        str_cell = cellstr(str_tmp);
                        str_edit = sprintf('%s;',str_cell{:});
                        str_tmp = str_edit(1:end-1);
                    end
                else
                    str_tmp = main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn});
                end
                string_disp{cnt, 1} = sprintf('%-25s\t%s', [sub_sub_fields{nn}, ':'], str_tmp);
                cnt = cnt + 1;
            end
        else
            if isnumeric(main_data.(main_data.pref.order{m}).(sub_fields{n}))
                str_tmp = num2str(main_data.(main_data.pref.order{m}).(sub_fields{n}));
                
                if size(str_tmp, 1) > 1
                    str_cell = cellstr(str_tmp);
                    str_edit = sprintf('%s;',str_cell{:});
                    str_tmp = str_edit(1:end-1);
                end
            else
                str_tmp = main_data.(main_data.pref.order{m}).(sub_fields{n});
            end
            string_disp{cnt, 1} = sprintf('%-25s\t%s', [sub_fields{n}, ':'], str_tmp);
            cnt = cnt + 1;
        end
    end
    string_disp{cnt, 1} = '';
    cnt = cnt + 1;
    
end

set(h_para_disp, 'String', string_disp);
figure(h_disp);

function [strs, cnt] = parse_denoise_strs(denoise_struct)

% space and masks
strs = [];
strs{end+1, 1} = 'DENOISE';
strs{end+1, 1} = 'Space & Masks';
if denoise_struct.space_mask.space_comm == 1
    strs{end+1, 1} = 'running in common space.';
    strs{end+1, 1} = 'selected masks are';
    mask_fields = {'mask_wb'; 'mask_gs'; 'mask_wm'; 'mask_csf'};
    
    [mask_fns, mask_strs] = get_mask_str(mask_fields, denoise_struct.space_mask);
    str_masks = cellfun(@(x, y) sprintf('%-25s\t%s', [x, ':'], y), mask_fns, mask_strs, 'UniformOutput', false);
else
    strs{end+1, 1} = 'running in individual space.';
    strs{end+1, 1} = 'selected masks'' wildcards are';
    mask_fields = {'ft_wb'; 'ft_gs'; 'ft_wm'; 'ft_csf'};
    
    [mask_fns, mask_strs] = get_mask_str(mask_fields, denoise_struct.space_mask);
    str_masks = cellfun(@(x, y) sprintf('%-25s\t%s', [x, ':'], y), mask_fns, mask_strs, 'UniformOutput', false);
end
strs = [strs; str_masks];
strs{end+1, 1} = '';
strs{end+1, 1} = sprintf('%-25s\t%s', ['mask_res_type', ':'], denoise_struct.space_mask.mask_res_type);
strs{end+1, 1} = sprintf('%-25s\t%s', ['ft_motion', ':'], denoise_struct.space_mask.ft_motion);
strs{end+1, 1} = '';

% regression model
strs{end+1, 1} = sprintf('%-25s\t%s', 'Regressors:', get_regressors(denoise_struct.reg_mdl));

if denoise_struct.reg_mdl.scrubbing == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'Spike Handling:', sprintf('Scrubbing at FD¡Ü%.2f', denoise_struct.reg_mdl.fd_thr));
end

% filter
strs{end+1, 1} = '';
strs{end+1, 1} = 'Filter options:';
strs{end+1, 1} = sprintf('%-25s\t%.1f', 'TR(s):', denoise_struct.fil_opt.tr);
strs{end+1, 1} = sprintf('%-25s\t%.2f', 'lower cutoff:', denoise_struct.fil_opt.lower_cutoff);
strs{end+1, 1} = sprintf('%-25s\t%.2f', 'upper cutoff:', denoise_struct.fil_opt.upper_cutoff);

% process options
strs{end+1, 1} = '';
strs{end+1, 1} = 'Process options';
if denoise_struct.fil_opt.reg_filter == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'Order:', 'Regression first, then filter');
elseif denoise_struct.fil_opt.filter_reg == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'Order:', 'Filter first, then regression');
elseif denoise_struct.fil_opt.filter_only == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'Order:', 'Filter only');
elseif denoise_struct.fil_opt.reg_only == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'Order:', 'Regression only');
else
    error('Unknown operation!')
end

if denoise_struct.fil_opt.save_last == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'save option:', 'only the last result will be saved');
else
    strs{end+1, 1} = sprintf('%-25s\t%s', 'save option:', 'all selected options will have output files');
end

if denoise_struct.fil_opt.gzip_output == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'gzip option:', 'output files will be saved as *.gz format (faster)');
else
    strs{end+1, 1} = sprintf('%-25s\t%s', 'gzip option:', 'output files will be saved as input format');
end

if denoise_struct.fil_opt.gsr_nogsr == 1
    strs{end+1, 1} = sprintf('%-25s\t%s', 'GSR option:', 'regression and selected following process will be done with and without GSR');
else
    strs{end+1, 1} = sprintf('%-25s\t%s', 'GSR option:', 'regression and selected following process will be done as selected T components');
end

strs{end+1, 1} = sprintf('%-25s\t%s', 'regression output prefix:', denoise_struct.fil_opt.prefix_reg);
strs{end+1, 1} = sprintf('%-25s\t%s', 'filter output prefix:', denoise_struct.fil_opt.prefix_filter);
cnt = numel(strs);


function reg_strs = get_regressors(mask_struct)
reg_strs = [];
if mask_struct.lin_trend == 1
    reg_strs = [reg_strs, 'linear,'];
end
if mask_struct.quad_trend == 1
    reg_strs = [reg_strs, 'quadratic,'];
end

fns = fieldnames(mask_struct.regressors);
inds = cellfun(@(x) mask_struct.regressors.(x) == 1, fns);
use_fns = fns(inds);
if ~isempty(use_fns)
    use_fns = cellfun(@(x) strrep(strrep(x, '_prime', ''''), '_square', '^2'), use_fns, 'UniformOutput', false);
    reg_strs = [reg_strs, sprintf('%s,', use_fns{:})];
    reg_strs(end) = '';
end




function [mask_fns, mask_strs] = get_mask_str(masks, mask_struct)

mask_strs_tmp = cellfun(@(x) mask_struct.(x).string, masks, 'UniformOutput', false);
mask_inds = cellfun(@(x) mask_struct.(x).ind == 1, masks);
mask_strs = mask_strs_tmp(mask_inds);
mask_fns = masks(mask_inds);



