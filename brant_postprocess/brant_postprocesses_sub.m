function brant_postprocesses_sub(dlg_title, jobman, ui_strucs, process_fun)

prompt = ui_strucs;
figColor = [0.94 0.94 0.94];

fig.x = 400;
fig.y = 200;
fig.len = 250;
fig.height = 50 + 60 + 30;

[fig, prompt] = figure_height(prompt, fig);

screen_size = get(0, 'Screensize');

h_btn = findobj(0, 'String', dlg_title, 'Style', 'pushbutton');
if isempty(h_btn)
    pos_par = [400 + fig.len, screen_size(4) - 50, 100, 0];
else
    h_parent = get(h_btn, 'Parent');
    pos_par = get(h_parent, 'Position');
end
fig_pos = [pos_par(1) + pos_par(3) + 15, pos_par(4) + pos_par(2) - fig.height, fig.len, fig.height];

h_fig = findobj(0, 'Name', dlg_title, 'Tag', dlg_title);
if ~isempty(h_fig)
    brant_config_figure(h_fig, 'pixels');
    pos_size_fig = get(h_fig, 'Position');
    set(h_fig, 'Position', [fig_pos(1:2), pos_size_fig(3:4)]);
    brant_config_figure(h_fig, 'normalized');
    figure(h_fig);
    return;
end
    
hfig_inputdlg = figure(...
    'IntegerHandle',    'off',...
    'Position',         fig_pos,...
    'Color',            figColor,...
    'Name',             dlg_title,...
    'UserData',         jobman,...
    'NumberTitle',      'off',...
    'Tag',              dlg_title,...
    'Units',            'pixels',...
    'Resize',           'off',...
    'MenuBar',          'none',...
    'Visible',          'on');

% configures for roi list elements
current_pos.x = 20;
current_pos.y = 50;

% [text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size;
disp_size = [210, 75];
button_len = 51;

ui_buttons = {...
  'run',   [current_pos.x + (disp_size(1) - button_len) / 2 - button_len - 1 / 2 * ((disp_size(1) - button_len) / 2 - button_len), current_pos.y - 20, button_len, 20],    {@run_cb, process_fun};...
  'S',  [current_pos.x + (disp_size(1) - button_len) / 2 - button_len - 1 / 2 * ((disp_size(1) - button_len) / 2 - button_len) + button_len + 5, current_pos.y - 20, 20, 20],  {@brant_save_gui, process_fun, []};...
  'L',  [current_pos.x + (disp_size(1) - button_len) / 2 - button_len - 1 / 2 * ((disp_size(1) - button_len) / 2 - button_len) + button_len + 30, current_pos.y - 20, 20, 20],  {@brant_load_gui};...
  '?',  [current_pos.x + (disp_size(1) - button_len) / 2 - button_len - 1 / 2 * ((disp_size(1) - button_len) / 2 - button_len) + button_len + 55, current_pos.y - 20, 20, 20],  {@brant_help_cb, hfig_inputdlg, dlg_title};...
  'cancel',   [current_pos.x + (disp_size(1) + button_len) / 2 + 1 / 2 * ((disp_size(1) - button_len) / 2 - button_len), current_pos.y - 20, button_len, 20], @close_window
  };

ui_fontsize = 12;
for m = 1:size(ui_buttons, 1)
    uicontrol(...
            'Parent',               hfig_inputdlg,...
            'String',               ui_buttons{m, 1},...
            'UserData',             '',...
            'Tag',                  dlg_title,...
            'Position',             ui_buttons{m, 2},...
            'Fontsize',             ui_fontsize,...
            'Style',                'pushbutton',...
            'BackgroundColor',      figColor,...
            'Callback',             ui_buttons{m, 3});
end

current_pos.y = fig.height - 60;

logo_fn = fullfile(fileparts(which('brant')), 'logo_resize.png');
if (exist(logo_fn, 'file') == 2)
    create_logo(hfig_inputdlg, current_pos, logo_fn);
end

create_elements(hfig_inputdlg, prompt, [current_pos.x, current_pos.y], jobman); % create functional elements
brant_except_ui(hfig_inputdlg);

function create_logo(hfig_inputdlg, current_pos, logo_fn)

h_btn = uicontrol(...
        'Parent',       hfig_inputdlg,...
        'Style',        'pushbutton',...
        'Position',     [current_pos.x, current_pos.y, 210, 50],... % 210, 50
        'ForegroundColor', [1, 1, 1],... %[0.2 0.4 0.8]
        'BackgroundColor', [1, 1, 1],... %[0.2 0.4 0.8]
        'CData',        imread(logo_fn),...
        'Callback',     @brant_fun_web);

function brant_fun_web(obj, evd)
web('http://brant.brainnetome.org/', '-browser');

function brant_except_ui(hfig_inputdlg)
% set ui control events for specific uis

ui_name = get(hfig_inputdlg, 'Name');
lw_uiname = lower(ui_name);
exp_col_ind = 1;
switch(lw_uiname)
    case 'roi signal calculation'
        h_roi = findobj(hfig_inputdlg, 'String', 'check: roi-wise | uncheck: voxel-wise'); % add {} to checkbox ui elements!
        if (get(h_roi, 'Value') == 1)
            obj_strs{1} = {''}; % dual
            obj_strs{2} = {'rois', 'roi_info', 'roi_thres', 'ext_mean', 'roi2roi', 'roi2wb', 'sm_ind', 'fwhm'}; % self
        else
            obj_strs{1} = {'rois', 'roi_info', 'roi_thres', 'ext_mean', 'roi2roi', 'roi2wb', 'sm_ind', 'fwhm'}; % dual
            obj_strs{2} = {''}; % self
        end
    case 'roi coordinates'
        h_sep_c = findobj(hfig_inputdlg, 'String', 'seperated binary clusters');
        if (get(h_sep_c, 'Value') == 1)
            obj_strs{1} = {'template_info'}; % dual
            obj_strs{2} = {''}; % self
        else
            obj_strs{1} = {''}; % self
            obj_strs{2} = {'template_info'}; % dual
        end
        
    case 'dicom convert'
        h_del = findobj(hfig_inputdlg, 'style', 'radiobutton', 'string', 'delete');
        val_del = get(h_del, 'Value');
        
        if (val_del == 1)
            obj_strs{1} = {'_cvt:', '_cvt.'}; % dual
            obj_strs{2} = {'_del:', '_del.'}; % self
        else
            obj_strs{1} = {'_del:', '_del.'}; % dual
            obj_strs{2} = {'_cvt:', '_cvt.'}; % self
        end
    case 'gzip/gunzip files'
        h_gzip = findobj(hfig_inputdlg, 'tag', 'gzip:radio');
        val_gzip = get(h_gzip, 'Value');
        if (val_gzip == 1)
            obj_strs{1} = {'input_gunzip'}; % dual
            obj_strs{2} = {'input_gzip'}; % self
        else
            obj_strs{1} = {'input_gzip'}; % dual
            obj_strs{2} = {'input_gunzip'}; % self
        end
        
    case {'delete timepoints', 'reslice'}
        h_out = findobj(hfig_inputdlg, 'string', 'output to another directory');
        val_out = get(h_out, 'Value');
        if (val_out == 1)
            obj_strs{1} = {''}; % dual
            obj_strs{2} = {'out_dir'}; % self
        else
            obj_strs{1} = {'out_dir'}; % dual
            obj_strs{2} = {''}; % self
        end
    case 't-tests' %'statistics'
        h_mat = findobj(hfig_inputdlg, 'string', 'matrix');
        val_mat = get(h_mat, 'Value');
        if (val_mat == 1)
            obj_strs{1} = {'input_nifti'}; % dual
            obj_strs{2} = {'sym_ind', 'mat_vox2vox', 'input_matrix'}; % self
        else
            obj_strs{1} = {'sym_ind', 'mat_vox2vox', 'input_matrix'}; % dual
            obj_strs{2} = {'input_nifti'}; % self
        end
    case 'draw rois'
        h_maual = findobj(hfig_inputdlg, 'string', 'manual');
        val_maual = get(h_maual, 'Value');
        if (val_maual == 1)
            obj_strs{1} = {'coords_file:'}; % dual
            obj_strs{2} = {'coords:'}; % self
        else
            obj_strs{1} = {'coords:'}; % dual
            obj_strs{2} = {'coords_file:'}; % self
        end
    case 'merge/extract rois'
        h_merge = findobj(hfig_inputdlg, 'string', 'merge');
        val_merge = get(h_merge, 'Value');
        if (val_merge == 1)
            obj_strs{1} = {'rois:', 'roi_info:', 'roi_vec', 'out2single'}; % dual
            obj_strs{2} = {'input_nifti.', 'out_fn'}; % self
        else
            obj_strs{1} = {'input_nifti.', 'out_fn'}; % dual
            obj_strs{2} = {'rois:', 'roi_info:', 'roi_vec', 'out2single'}; % self
        end
    case 'ibma'
        h_mat = findobj(hfig_inputdlg, 'string', 'matrix');
        val_mat = get(h_mat, 'Value');
        if (val_mat == 1)
            obj_strs{1} = {'num_subjs_tbl', 'input_nifti'}; % dual
            obj_strs{2} = {'input_matrix'}; % self
        else
            obj_strs{1} = {'input_matrix'}; % dual
            obj_strs{2} = {'num_subjs_tbl', 'input_nifti'}; % self
        end
    case {'extract value'}
        h_mat = findobj(hfig_inputdlg, 'string', 'matrix');
        val_mat = get(h_mat, 'Value');
        if (val_mat == 1)
            obj_strs{1} = {'input_nifti.', 'rois:', 'roi_index'}; % dual
            obj_strs{2} = {'input_matrix.', 'sym_ind', 'corr_mask', 'roi_info'}; % self
        else
            obj_strs{1} = {'input_matrix.', 'sym_ind', 'corr_mask', 'roi_info'}; % dual
            obj_strs{2} = {'input_nifti.', 'rois:', 'roi_index'}; % self
        end
    case 'roi mapping'
        h_rand = findobj(hfig_inputdlg, 'string', 'random');
        val_rand = get(h_rand, 'Value');
        if (val_rand == 1)
            obj_strs{1} = {'color_input'}; % dual
            obj_strs{2} = {'output_color', 'out_dir'}; % self
        else
            obj_strs{1} = {'output_color', 'out_dir'}; % dual
            obj_strs{2} = {'color_input'}; % self
        end
    otherwise
        exp_col_ind = 0;
%         return;
end

h_objs = get(hfig_inputdlg, 'Children');
tag_objs = arrayfun(@(x) get(x,'tag'), h_objs, 'UniformOutput', false);
    
if (exp_col_ind == 1)
    brant_config_figure(hfig_inputdlg, 'pixel');
    vis_states = {'on', 'off'};
    vis_set_states = {'off', 'on'};

    obj_ind = cell(2, 1);
    for m = 1:numel(obj_strs)
        obj_ind{m} = false;
        for n = 1:numel(obj_strs{m})
           obj_ind{m} = obj_ind{m} | cellfun(@(x) ~isempty(strfind(x, obj_strs{m}{n})), tag_objs);
        end
    end

    obj_ind_all = obj_ind{1} | obj_ind{2};

    enb_uis = {'roi signal calculation', 'roi mapping', 'del timepoints', 'reslice'};

    if any(strcmpi(lw_uiname, enb_uis))
        % disable ui elements
        arrayfun(@(x) set(x, 'enable', 'off'), h_objs(obj_ind{1}));
        arrayfun(@(x) set(x, 'enable', 'on'), h_objs(obj_ind{2}));
    else
        % move ui elements
        pos_obj_tmp = arrayfun(@(x) get(x, 'Position'), h_objs, 'UniformOutput', false);
        pos_obj_all = cat(1, pos_obj_tmp{:});

        % get min y location of moveable elements
        move_obj_ind = (pos_obj_all(:, 2) >= min(pos_obj_all(obj_ind_all, 2))) & (~obj_ind_all);
        move_pos_min = min(pos_obj_all(move_obj_ind, 2));

        % get min location of dual and self elements
        min_pos_ds = min(pos_obj_all(obj_ind_all, 2));

        % set dual elements to invisible
        arrayfun(@(x) set(x, 'visible', 'off'), h_objs(obj_ind{1}));

        % get min y location of self elements
        self_pos = pos_obj_all(obj_ind{2}, :);
        if ~isempty(self_pos)
            [self_pos_max, max_loc] = max(self_pos(:, 2));
            self_pos_min = min(pos_obj_all(obj_ind{2}, 2));
            self_height = self_pos_max - self_pos_min + self_pos(max_loc, 4) + 10;

            % calculate distance between global min and self elements
            dist_tmp = min_pos_ds - self_pos_min;

            % move self elements
            arrayfun(@(x, y) set(x, 'Position', y{1} + [0, dist_tmp, 0, 0]), h_objs(obj_ind{2}), pos_obj_tmp(obj_ind{2}));

            % set self elements to visible
            arrayfun(@(x) set(x, 'visible', 'on'), h_objs(obj_ind{2}));
        else
            self_height = 0;
        end

        % calculate distance between moveable elements and top of self elements
        dist_tmp = min_pos_ds - move_pos_min + self_height;

        % move moveable elements to the top of self elements
        arrayfun(@(x, y) set(x, 'Position', y{1} + [0, dist_tmp, 0, 0]), h_objs(move_obj_ind), pos_obj_tmp(move_obj_ind));

        % adjust figure height
        set(hfig_inputdlg, 'Position', get(hfig_inputdlg, 'Position') + [0, -1 * dist_tmp, 0, dist_tmp]);
    end
end


% more exceptions
switch(lw_uiname)
    case 't-tests'%'statistics'
        h_vox2vox_ind = findobj(hfig_inputdlg, 'tag', 'mat_vox2vox:checkbox');
        obj_strs = {'input_matrix.filetype:edit', 'input_matrix.nm_pos:edit', 'fdr', 'bonf'};
        obj_ind = false;
        for n = 1:numel(obj_strs)
           obj_ind = obj_ind | cellfun(@(x) ~isempty(strfind(x, obj_strs{n})), tag_objs);
        end
        val_vox2vox = get(h_vox2vox_ind, 'Value');
        if (val_vox2vox == 1)
            arrayfun(@(x) set(x, 'Enable', 'off'), h_objs(obj_ind));
        else
            arrayfun(@(x) set(x, 'Enable', 'on'), h_objs(obj_ind));
        end
    case {'am', 'reho', 'alff/falff', 'roi signal calculation'}
        h_sm_ind = findobj(hfig_inputdlg, 'tag', 'sm_ind:checkbox');
        obj_strs = {'fwhm:edit'};
        obj_ind = false;
        for n = 1:numel(obj_strs)
           obj_ind = obj_ind | cellfun(@(x) ~isempty(strfind(x, obj_strs{n})), tag_objs);
        end
        val_sm_ind = get(h_sm_ind, 'Value');
        if strcmpi(lw_uiname, 'roi signal calculation')
            val_sm_ind = val_sm_ind && get(h_roi, 'Value');
        end
        if (val_sm_ind == 1)
            arrayfun(@(x) set(x, 'Enable', 'on'), h_objs(obj_ind));
        else
            arrayfun(@(x) set(x, 'Enable', 'off'), h_objs(obj_ind));
        end
    case 'gzip/gunzip files'
        h_out = findobj(hfig_inputdlg, 'string', 'output to another directory');
        val_out = get(h_out, 'Value');
        
        obj_strs = {'out_dir'};
        obj_ind = false;
        for n = 1:numel(obj_strs)
            obj_ind = obj_ind | cellfun(@(x) ~isempty(strfind(x, obj_strs{n})), tag_objs);
        end
        
        if (val_out == 1)
            arrayfun(@(x) set(x, 'Enable', 'on'), h_objs(obj_ind));
        else
            arrayfun(@(x) set(x, 'Enable', 'off'), h_objs(obj_ind));
        end
        
    case 'dicom convert'
        h_cvt_ind = findobj(hfig_inputdlg, 'tag', 'convert:radio');
        if (get(h_cvt_ind, 'Value') == 1)
            obj_strs = {'del_N_cvt', 'filetype_cvt'};
            obj_ind = false;
        else
            obj_strs = {'out_dir_del:text', 'out_dir_del:edit'};
            obj_ind = false;
        end
        
        for n = 1:numel(obj_strs)
            obj_ind = obj_ind | cellfun(@(x) ~isempty(strfind(x, obj_strs{n})), tag_objs);
        end
            
        if (get(h_cvt_ind, 'Value') == 1)
            h_del_ind_cvt_ind = findobj(hfig_inputdlg, 'tag', 'del_ind_cvt:checkbox');
            if get(h_del_ind_cvt_ind, 'Value') == 1
                arrayfun(@(x) set(x, 'Enable', 'on'), h_objs(obj_ind));
            else
                arrayfun(@(x) set(x, 'Enable', 'off'), h_objs(obj_ind));
            end
        else
            h_out_dir_del_ind = findobj(hfig_inputdlg, 'tag', 'out_ind_del:checkbox');
            if get(h_out_dir_del_ind, 'Value') == 1
                arrayfun(@(x) set(x, 'Enable', 'on'), h_objs(obj_ind));
            else
                arrayfun(@(x) set(x, 'Enable', 'off'), h_objs(obj_ind));
            end
        end
end

brant_config_figure(hfig_inputdlg, 'Normalized');

function [fig, prompt] = figure_height(prompt, fig)

% [text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size;
disp_size = [210, 75];

for m = 1:size(prompt, 1)
    if strcmp(prompt{m, 1}{2}, 'vert_node_color')
        fig.height = fig.height + 55;
    elseif strcmp(prompt{m, 1}{2}, 'vert_node_color_three')
        fig.height = fig.height + 60;
    elseif ~isempty(strfind(prompt{m, 1}{1}, 'radio'))
        if strfind(prompt{m, 1}{2}, 'vert_two')
            fig.height = fig.height + 45;
        else
            fig.height = fig.height + 25;
        end
    elseif ~isempty(strfind(prompt{m, 1}{1}, 'edit'))
        if ~isempty(strfind(prompt{m, 1}{2}, 'disp_coordinates'))
            fig.height = fig.height + disp_size(2) / 2 + 20 + 15;
        elseif ~isempty(strfind(prompt{m, 1}{2}, 'disp'))
            fig.height = fig.height + disp_size(2) + 20 + 15;
        else
            fig.height = fig.height + 25;
        end
    elseif ~isempty(strfind(prompt{m, 1}{1}, 'popupmenu'))
        fig.height = fig.height + 28;
    else
        fig.height = fig.height + 25;
    end
end

function [text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size
text_size = [55, 15];
edit_size = [125, 15];
numeric_size = [80, 15];
pushbtn_size = [15, 15];
disp_size = [210, 75];
info_size = [65, 15];

function [sub_eles, pos_shift, block_shift, ui_tags, ui_ctrls, ui_strs, ui_colors] = sub_elements(ui_types, ui_fields, ui_strs_all)

[text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size; %#ok<ASGLU>
popupmenu_height = 23; % in pixel

if (numel(ui_fields) == 1)
    tag_str = ui_fields{1};
elseif numel(ui_fields) == 2
    tag_str = strcat(ui_fields{1}, '.', ui_fields{2});
else
    tag_str = ui_fields;
end

% only works for radio now
ui_strs = {ui_strs_all};
ui_colors = [];

switch(ui_types{1})
    case 'chb'
        switch(ui_types{2})
            case {'num_bin'}
                sub_eles = {'checkbox'};
                pos_shift = [   0,                  0, text_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {{ui_fields}};
            
            case {'num_bin_triple_hor'}
                sub_eles = {'checkbox', 'checkbox', 'checkbox'};
                pos_shift = [0, 0, text_size(1) / 3, text_size(2);...
                             70, 0, text_size(1) / 3, text_size(2);...
                             140, 0, text_size(1) / 3, text_size(2)];
                block_shift = -1 * (text_size(2) + 10 + 1);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = ui_fields;
                
            case 'num_bin_num_edit'
                sub_eles = {'checkbox', 'edit'};
                pos_shift = [   0,                  0, text_size + [text_size(1), 0];...
                                disp_size(1) - numeric_size(1) - 25, 0, numeric_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {{'enable_edit', ui_tags{2}}, {ui_fields}};
        end
        
    case {'popupmenu', 'popupmenu_left', 'popupmenu_right'}
        
            sub_eles = {'text', 'popupmenu'};
            pos_shift = [ 0,                  2, text_size;...
                        disp_size(1) - numeric_size(1) - 25,2, numeric_size(1), popupmenu_height - (popupmenu_height - edit_size(2)) / 2];
            block_shift = -1 * (edit_size(2) + 14);
            ui_tags = strcat(tag_str{1}, ':', sub_eles);
            
            switch(ui_types{1})
                case 'popupmenu_left'
                case 'popupmenu_right'
                    pos_shift(2, 1) = disp_size(1) - edit_size(1);
                    pos_shift(2, 3) = edit_size(1);
                otherwise
                    if strcmp(ui_types{2}, 'disp_view_opts')
                        pos_shift(2, 1) = text_size(1) + 5;
                        pos_shift(2, 3) = disp_size(1) - text_size(1) - 5;
                    end
            end
            
            ui_strs = {ui_strs_all, tag_str(2:end)};
        switch(ui_types{2})
            case 'num_neighbours_pts'
                ui_ctrls = {'', {'set_val_num', ui_tags{2}, tag_str{1}}};
            case 'disp_view_opts'
                ui_ctrls = {'', {'set_val_str', ui_tags{2}, tag_str{1}}};
        end
        
    case {'edit'}
        switch(ui_types{2})
            case {'num_short_right', 'str_filetype_nifti', 'str_filetype_mat', 'str_filetype_txt', 'num_coords', 'str_short_right'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0,                  0, text_size + [text_size(1), 0];...
                                disp_size(1) - numeric_size(1) - 25, 0, numeric_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}};
                
            case {'num_short_left', 'str_short_left'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0,                  0, text_size + [text_size(1), 0];...
                                text_size(1) + 5, 0, numeric_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}};

            case {'disp_dirs_nii'}
                sub_eles = {'text', 'checkbox_0_txt', 'pushbutton', 'disp'};
                pos_shift = [   0,                  disp_size(2) + 5, text_size(1) + edit_size(1), text_size(2);...
                                70, disp_size(2) + 5, 120, text_size(2);...
                                disp_size(1) - 15,  disp_size(2) + 5, pushbtn_size;...
                                0, 0, disp_size];
                block_shift = -1 * (disp_size(2) + 5 + text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', '', {'disp_inputs', ui_tags{4}}, {ui_fields}};
            
            case {'disp_net_calcs'}
                sub_eles = {'text', 'pushbutton', 'disp'};
                pos_shift = [   0,                  disp_size(2) + 5, text_size(1) + edit_size(1), text_size(2);...
                                disp_size(1) - 15,  disp_size(2) + 5, pushbtn_size;...
                                0, 0, disp_size];
                block_shift = -1 * (disp_size(2) + 5 + text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {'disp_inputs', ui_tags{3}}, {ui_fields}};
                
            case 'disp_coordinates'
                sub_eles = {'text', 'pushbutton', 'disp'};
                pos_shift = [   0,  disp_size(2) / 2 + 5, text_size(1) + edit_size(1), text_size(2);...
                                disp_size(1) - 15,  disp_size(2) / 2 + 5, pushbtn_size;...
                                0, 0, disp_size(1), disp_size(2) / 2];
                block_shift = -1 * (disp_size(2) / 2 + 5 + text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {'disp_input', ui_tags{3}}, {ui_fields}};
                
            case {'str_dir', 'str_nifti', 'str_mat', 'str_surf', 'str_node', 'str_edge', 'str_csv'}
                sub_eles = {'text', 'edit', 'pushbutton'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, edit_size;...
                                disp_size(1) - 15,  0, pushbtn_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}, {'disp_input', ui_tags{2}}};
                
            case {'str_long_left'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, edit_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}};
                
            case {'str_long_right', 'num_long'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0, 0, disp_size(1) - edit_size(1), text_size(2);...
                                disp_size(1) - edit_size(1),0, edit_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}};
            case {'num_longest', 'str_thr_parse'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0, 0, disp_size(1) - edit_size(1), text_size(2);...
                                text_size(1) + 5,0, edit_size];
                block_shift = -1 * (text_size(2) + 10);
                ui_tags = strcat(tag_str, ':', sub_eles);
                ui_ctrls = {'', {ui_fields}};
        end
    
    case 'radio'
        switch(ui_types{2})
            case {'vert_two'}
                sub_eles = {'radio', 'radio'};
                pos_shift = [   0,text_size(2) + 10 + 1, numeric_size;...
                                0,0, numeric_size];
                block_shift = -2 * (text_size(2) + 10 + 1);
                ui_tags = {[ui_fields{1}, ':radio'],...
                           [ui_fields{2}, ':radio']};
                ui_ctrls = {{'get_val', ui_tags{1}, ui_fields(1);'set_val', ui_tags{2}, ui_fields(2)},...
                            {'get_val', ui_tags{2}, ui_fields(2);'set_val', ui_tags{1}, ui_fields(1)}};
               ui_strs = ui_strs_all;
               
            case {'hor_two'}
                sub_eles = {'radio', 'radio'};
                pos_shift = [   0,0, numeric_size ./ [2, 1];...
                                numeric_size(1) / 2,0, numeric_size ./ [2, 1]];
                block_shift = -2 * (text_size(2) + 10 + 1);
                ui_tags = {[ui_fields{1}, ':radio'],...
                           [ui_fields{2}, ':radio']};
                ui_ctrls = {{'get_val', ui_tags{1}, ui_fields(1);'set_val', ui_tags{2}, ui_fields(2)},...
                            {'get_val', ui_tags{2}, ui_fields(2);'set_val', ui_tags{1}, ui_fields(1)}};
               ui_strs = ui_strs_all;
               
            case {'hor_txt'}
                sub_eles = {'text', 'radio', 'radio'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, numeric_size;...
                                text_size(1) + 5 + edit_size(1) / 2,0, numeric_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
                ui_tags = {[tag_str{1}, '_', tag_str{2}, ':text'],...
                           [tag_str{1}, ':radio'],...
                           [tag_str{2}, ':radio']};
               if (numel(ui_fields) == 1)
                    ui_ctrls = {'', {'get_val', ui_tags{2}, ui_fields{1}(1);'set_val', ui_tags{3}, ui_fields{1}(2)},...
                                    {'get_val', ui_tags{3}, ui_fields{1}(2);'set_val', ui_tags{2}, ui_fields{1}(1)}};
               elseif (numel(ui_fields) == 2)
                    ui_ctrls = {'', {'get_val', ui_tags{2}, {ui_fields{1}, ui_fields{2}{1}};'set_val', ui_tags{3}, {ui_fields{1}, ui_fields{2}{2}}},...
                                    {'get_val', ui_tags{3}, {ui_fields{1}, ui_fields{2}{2}};'set_val', ui_tags{2}, {ui_fields{1}, ui_fields{2}{1}}}};
               end
                
               ui_strs = {ui_strs_all, tag_str{1}, tag_str{2}};
               
            case 'vert_node_color_three'
                sub_eles = {'radio', 'radio', 'text', 'radio', 'popupmenu', 'text'};
                pos_shift = [   0,  2 * (text_size(2) + 10 + 1), text_size(1) + edit_size(1), text_size(2);...
                                0,  text_size(2) + 10 + 1, text_size(1) + edit_size(1), text_size(2);...
                                disp_size(1) - 15,  text_size(2) + 10 + 1, pushbtn_size;...
                                0,  0, edit_size(1), text_size(2);...
                                edit_size(1) + 5,  5, text_size;...
                                disp_size(1) - 15,  0, pushbtn_size;...
                                ];
                block_shift = -3 * (text_size(2) + 10 + 1);
                ui_tags = {[tag_str{1}{1}, ':radio'],...
                           [tag_str{2}{1}, ':radio'],...
                           [tag_str{3}{1}, ':text'],...
                           [tag_str{4}{1}, ':radio']...
                           [tag_str{5}{1}{1}, ':popupmenu']...
                           [tag_str{6}{1}, ':text']...
                           };
                ui_ctrls = { {'get_val', ui_tags{1}, ui_fields{1};...
                              'set_val', ui_tags{2}, ui_fields{2};...
                              'set_val', ui_tags{4}, ui_fields{4}},...
                              {'get_val', ui_tags{2}, ui_fields{2};...
                              'set_val', ui_tags{1}, ui_fields{1};...
                              'set_val', ui_tags{4}, ui_fields{4};...
                              'set_module_str_color_same', ui_tags{3}, ui_fields{3}},...
                             {'set_color', ui_tags{3}, ui_fields{3}},...
                             {'get_val', ui_tags{4}, ui_fields{4};...
                              'set_val', ui_tags{1}, ui_fields{1};...
                              'set_val', ui_tags{2}, ui_fields{2};...
                              'set_module_str_color_diff', {ui_tags{5}, ui_tags{6}}, {ui_fields{5}{1}{1}, ui_fields{6}{1}}},...
                             {'set_val_str', ui_tags{5}, ui_fields{5}{1};...
                              'set_color', ui_tags{6}, ui_fields{6}},...
                             {'get_val_ind', ui_tags{5}, ui_fields{5}{1};...
                              'set_color', ui_tags{6}, ui_fields{6}},...
                             }; 
                 ui_strs = {ui_strs_all{1}, ui_strs_all{2}, '', ui_strs_all{3}, ui_fields{5}(2:end), ''};
                 ui_colors = {[], [], [1, 0, 0], [], [], [1, 0, 0]};
                 
            case 'vert_node_color'
                sub_eles = {'radio', 'text', 'radio', 'popupmenu', 'text'};
                pos_shift = [   0,  text_size(2) + 10 + 1, text_size(1) + edit_size(1), text_size(2);...
                                disp_size(1) - 15,  text_size(2) + 10 + 1, pushbtn_size;...
                                0,  0, edit_size(1), text_size(2);...
                                edit_size(1) + 5,  5, text_size;...
                                disp_size(1) - 15,  0, pushbtn_size;...
                                ];
                block_shift = -2 * (text_size(2) + 10 + 1);
                ui_tags = {[tag_str{1}{1}, ':radio'],...
                           [tag_str{2}{1}, ':text'],...
                           [tag_str{3}{1}, ':radio']...
                           [tag_str{4}{1}{1}, ':popupmenu']...
                           [tag_str{5}{1}, ':text']...
                           };
                ui_ctrls = { {'get_val', ui_tags{1}, ui_fields{1};...
                              'set_val', ui_tags{3}, ui_fields{3};...
                              'set_module_str_color_same', ui_tags{2}, ui_fields{2}},...
                             {'set_color', ui_tags{2}, ui_fields{2}},...
                             {'get_val', ui_tags{3}, ui_fields{3};...
                              'set_val', ui_tags{1}, ui_fields{1};...
                              'set_module_str_color_diff', {ui_tags{4}, ui_tags{5}}, {ui_fields{4}{1}{1}, ui_fields{5}{1}}},...
                             {'set_val_str', ui_tags{4}, ui_fields{4}{1};...
                              'set_color', ui_tags{5}, ui_fields{5}},...
                             {'get_val_ind', ui_tags{4}, ui_fields{4}{1};...
                              'set_color', ui_tags{5}, ui_fields{5}},...
                             }; 
                 ui_strs = {ui_strs_all{1}, '', ui_strs_all{2}, ui_fields{4}(2:end), ''};
                 ui_colors = {[], [1, 0, 0], [], [], [1, 0, 0]};
        end
    case 'seperator'
        switch(ui_types{2})
            case {'str'}
                sub_eles = {'text'};
                pos_shift = [ 0, 0, disp_size(1), edit_size(2) ];
                block_shift = -1 * (edit_size(2) + 10);
                ui_tags = {''};
                ui_ctrls = {''};
        end
    case 'pushbutton'
        switch(ui_types{2})
            case {'color_hor_dual'}
                sub_eles = {'text', 'text', 'text', 'text'};
                pos_shift = [0, 0, disp_size(1) / 2 - 30, text_size(2);...
                             disp_size(1) / 2 - 30, 0, pushbtn_size;...
                             disp_size(1) / 2, 0, disp_size(1) / 2 - 30, text_size(2);...
                             disp_size(1) - 30, 0, pushbtn_size];
                block_shift = -1 * (edit_size(2) + 10);
                ui_tags = {[ui_strs_all{1}, '_title:text'],...
                           [ui_strs_all{1}, '_color:text'],...
                           [ui_strs_all{2}, '_title:text'],...
                           [ui_strs_all{2}, '_color:text']};
                ui_ctrls = {'', {'set_color', ui_tags{2}, ui_fields{2}}, '', {'set_color', ui_tags{4}, ui_fields{4}}};
                ui_strs = {ui_strs_all{1}, '', ui_strs_all{2}, ''};
                ui_colors = {[], [1, 0, 0], [], [0, 1, 1]};
        end
end

function edit_str_out = edit_str_cvt(edit_str, edit_type)


if strcmp(edit_type, 'num_coords')
    edit_str_tmp = '';
    for o = 1:size(edit_str, 1)
        edit_str_tmp = [edit_str_tmp, sprintf('%d,%d,%d;', edit_str(o, :))]; %#ok<AGROW>
    end
    edit_str_out = edit_str_tmp;
else
    if (length(edit_str) > 1)
        if (all(edit_str == fix(edit_str)))
            edit_str_out = num2str(edit_str, '%d,');
            edit_str_out(end) = '';
        else
%             edit_str_out = num2str(edit_str, '%.3f,');
            edit_str_out = num2str(edit_str, '%g,');
            edit_str_out(end) = '';
        end
    else
        if all(edit_str == fix(edit_str))
            edit_str_out = num2str(edit_str, '%d');
        else
            edit_str_out = num2str(edit_str);
        end
    end
end


function pos = create_elements(h_fig, prompt, pos, jobman) % create functional elements

% jobman = get(h_fig, 'Userdata');   %#ok<*NASGU> % do not mask this line! YOU SHALL NOT PASS!
figColor = [0.94 0.94 0.94];

for m = 1:size(prompt, 1)
    [sub_eles{m}, pos_shift{m}, block_shift{m}, ui_tags{m}, ui_ctrls{m}, ui_strs{m}, ui_colors{m}] = sub_elements(prompt{m, 1}, prompt{m, 3}, prompt{m, 2}); %#ok<AGROW>
end

len_tmp = 5;
ui_fontsize = 10;

for m = 1:size(prompt, 1)
        
    ele_pps = prompt{m, 1};
    pos(2) = pos(2) + block_shift{m};
    
    for n = 1:numel(sub_eles{m})
        switch(sub_eles{m}{n})
            case 'text'
                text_strs = ui_strs{m}{n}; %prompt{m, 2};
                
                h_text = uicontrol(...
                    'Parent',               h_fig,...
                    'String',               text_strs,...
                    'Position',             pos_shift{m}(n, :) + [pos, 0, 0],...
                    'Style',                'text',...
                    'Fontsize',             ui_fontsize,...
                    'Tag',                  ui_tags{m}{n},...
                    'Userdata',             ui_ctrls{m}{n},...
                    'HorizontalAlignment',  'Left',...
                    'BackgroundColor',      figColor);
                
                if ~isempty(ui_colors{m})
                    if ~isempty(ui_colors{m}{n})
                        if isfield(jobman, prompt{m, 3}{n}{1})
                            text_color = jobman.(prompt{m, 3}{n}{1});
                        else
                            text_color = ui_colors{m}{n};
                        end
                        set(h_text, 'BackgroundColor', text_color);
                        set(h_text, 'ButtonDownFcn', @set_color_cb);
                    end
                end
            
            case {'edit', 'disp'}
                
                if (numel(prompt{m, 3}) == 1)
                    edit_str = jobman.(prompt{m, 3}{1});
                elseif (numel(prompt{m, 3}) == 2)
                    edit_str = jobman.(prompt{m, 3}{1}).(prompt{m, 3}{2});
                end

                edit_enable = 'on';
                if (any(strcmp(ele_pps{2}, {'num_bin_num_edit'})) && isempty(edit_str))
                    edit_enable = 'off';
                end
                
                if isnumeric(edit_str)
                    edit_str = edit_str_cvt(edit_str, prompt{m, 1}{2});
                end
                
                if strcmpi(prompt{m, 1}{2}, 'disp_net_calcs')
                    field_tmp = fieldnames(edit_str);
                    struct_ind = cellfun(@(x) ~isstruct(edit_str.(x)), field_tmp);
                    field_tmp2 = field_tmp(struct_ind);
                    sel_ind = cellfun(@(x) edit_str.(x) == 1, field_tmp2);
                    
                    edit_str = sprintf('%s\n', field_tmp2{sel_ind});
                end
                
                h = uicontrol(...
                    'Parent',               h_fig,...
                    'String',               edit_str,...
                    'Tag',                  ui_tags{m}{n},...
                    'Userdata',             ui_ctrls{m}{n},...
                    'Position',             pos_shift{m}(n, :) + [pos, 0, 0],...
                    'Fontsize',             ui_fontsize,...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1, 1, 1],...
                    'Callback',             {@edit_cb, prompt{m, 1}{2}},...
                    'Enable',               edit_enable);
                
            if strcmp(sub_eles{m}{n}, 'disp')
                % enable horizontal scrolling
                set(h, 'Enable', 'inactive');
                set(h, 'Value', 1);
                set(h, 'Min', 1);
                set(h, 'Max', 3);
                try
                    jEdit1 = findjobj(h);
                    jEditbox1 = jEdit1.getViewport().getComponent(0);
                    jEditbox1.setWrapping(false);                % turn off word-wrapping
                    jEditbox1.setEditable(false);                % non-editable
                    set(jEdit1, 'HorizontalScrollBarPolicy', 30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
                catch
                end
            end
            
            case 'pushbutton'
                
                h_push = uicontrol(...
                        'Parent',               h_fig,...
                        'String',               '...',...
                        'Tag',                  ui_tags{m}{n},...
                        'Userdata',             ui_ctrls{m}{n},...
                        'Position',             pos_shift{m}(n, :) + [pos, 0, 0],...
                        'Fontsize',             ui_fontsize,...
                        'Style',                'pushbutton',...
                        'BackgroundColor',      figColor,...
                        'Callback',             {@pushbutton_cb, prompt{m, 1}{2}});
                        
                if ~isempty(ui_colors{m})
                    set(h_push, 'String', '');
                    set(h_push, 'BackgroundColor', ui_colors{m}{n});
                    set(h_push, 'Callback', {@set_color_cb, ui_ctrls{m}{n}});
                end
                
            case 'popupmenu'
                
                if any(numel(prompt{m, 3}) == [5, 6]) % for a special case of radio color
                    prompt_tmp = prompt{m, 3}(n);
                else
                    prompt_tmp = prompt{m, 3};
                end
                
                if any(strcmpi({'mode_display:popupmenu', 'modules_info:popupmenu',...
                                'color_type_pos:popupmenu', 'color_type_neg:popupmenu', 'material_type:popupmenu',...
                                'stat_type:popupmenu', 'shading_type:popupmenu',...
                                'lighting_type:popupmenu', 'matrix_type:popupmenu', 'mask_color:popupmenu', 'view:popupmenu',...
                                'metrics:popupmenu'}, ui_tags{m}{n}))
                    pop_str = prompt_tmp{1}(2:end);
                    pop_val_ind = find(strcmpi(jobman.(prompt_tmp{1}{1}{1}), pop_str));
                else
                    if (numel(prompt_tmp) == 1)
                        pop_val = jobman.(prompt_tmp{1}{1});
                        pop_str = prompt_tmp{1}(2:end);
                    elseif (numel(prompt{m, 3}) == 2)
                        pop_val = jobman.(prompt_tmp{1}).(prompt_tmp{2}{1});
                        pop_str = prompt_tmp{2}{1}(2:end);
                    end
                    
                    if isnumeric(pop_val)
                        pop_val = num2str(pop_val);
                    end

                    if ~iscell(pop_val)
                        pop_val = cellstr(pop_val);
                    end
                    
                    pop_val_ind = find(cellfun(@(x) strcmp(x, pop_val), ui_strs{m}{n}));
                end
                
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               pop_str,...
                    'Tag',                  ui_tags{m}{n},...
                    'Userdata',             ui_ctrls{m}{n},...
                    'Value',                pop_val_ind,...
                    'Fontsize',             ui_fontsize,...
                    'Position',             pos_shift{m}(n, :) + [pos, 0, 0],...
                    'Style',                'popupmenu',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1],...
                    'Callback',             {@popupmenu_cb, ele_pps{2}});
            
            case 'checkbox'
                
                if (strcmpi(prompt{m, 1}{2}, 'num_bin_triple_hor') == 1)
                    chb_val = field_vals(jobman, {prompt{m, 3}{1}(n)});
                    chb_ctrls = {ui_ctrls{m}{1}(n)};
                    
                    pos_chb_tmp = [pos_shift{m}(n, 1), 0, 0, 0] + [pos, len_tmp, pos_shift{m}(n, 4) + 1];
                    chb_str = prompt{m, 2}{n};
                else
                    chb_val = field_vals(jobman, prompt(m, 3));
                    chb_ctrls = ui_ctrls{m}{n};
                    pos_chb_tmp = [pos, len_tmp, pos_shift{m}(n, 4) + 1];
                    chb_str = prompt{m, 2};
                end
                
                if ischar(chb_val)
                    if isempty(chb_val)
                        chb_val = 0;
                    else
                        chb_val = 1;
                    end
                elseif isnumeric(chb_val)
                    if any(chb_val)
                        chb_val = 1;
                    else
                        chb_val = 0;
                    end
                end
                
                h = uicontrol(...
                    'Parent',               h_fig,...
                    'String',               chb_str,...
                    'Position',             [pos_chb_tmp(1:2), 5, pos_chb_tmp(4)],...
                    'Fontsize',             ui_fontsize,...
                    'Tag',                  ui_tags{m}{n},...
                    'Userdata',             chb_ctrls,...
                    'Style',                'checkbox',...
                    'Value',                chb_val,...
                    'BackgroundColor',      figColor,...
                    'Callback',             {@chb_cb, ele_pps{2}});

                brant_resize_ui(h);
                
            case 'checkbox_1'
                h = uicontrol(...
                        'Parent',               h_fig,...
                        'String',               prompt{m, 2},...
                        'Position',             [pos + pos_shift{m}(n, 1:2), len_tmp, pos_shift{m}(n, 4) + 1],...
                        'Fontsize',             ui_fontsize,...
                        'Tag',                  ui_tags{m}{n},...
                        'Userdata',             ui_ctrls{m}{n},...
                        'Style',                'checkbox',...
                        'Value',                1,...
                        'BackgroundColor',      figColor,...
                        'Callback',             {@chb_cb, ele_pps{2}});
                brant_resize_ui(h);
                
            case 'checkbox_0'
                h = uicontrol(...
                    'Parent',               h_fig,...
                    'String',               prompt{m, 2},...
                    'Position',             [pos + pos_shift{m}(n, 1:2), len_tmp, pos_shift{m}(n, 4) + 1],...
                    'Fontsize',             ui_fontsize,...
                    'Tag',                  ui_tags{m}{n},...
                    'Userdata',             ui_ctrls{m}{n},...
                    'Style',                'checkbox',...
                    'Value',                0,...
                    'BackgroundColor',      figColor,...
                    'Callback',             {@chb_cb, ele_pps{2}});
                brant_resize_ui(h);
                
            case 'checkbox_0_txt'
                h = uicontrol(...
                        'Parent',               h_fig,...
                        'String',               'from text file',...
                        'Position',             [pos + pos_shift{m}(n, 1:2), len_tmp, pos_shift{m}(n, 4) + 1],...
                        'Fontsize',             ui_fontsize,...
                        'Tag',                  ui_tags{m}{n},...
                        'Userdata',             ui_ctrls{m}{n},...
                        'Style',                'checkbox',...
                        'Value',                0,...
                        'BackgroundColor',      figColor,...
                        'Callback',             '');
                brant_resize_ui(h);
                
            case {'radio'}
                
                radio_str = ui_strs{m}{n};
                
                radio_val = field_vals_radio(jobman, prompt{m, 1}{2}, prompt{m, 3}, n); %#ok<*NASGU>
                h = uicontrol(...
                            'Parent',               h_fig,...
                            'String',               radio_str,...
                            'Position',             [pos(1:2) + pos_shift{m}(n, 1:2), len_tmp, 1 + pos_shift{m}(n, 4)],...
                            'Fontsize',             ui_fontsize,...
                            'Tag',                  ui_tags{m}{n},...
                            'Userdata',             ui_ctrls{m}{n},...
                            'Style',                'radiobutton',...
                            'Value',                radio_val,...
                            'BackgroundColor',      figColor,...
                            'Callback',             @radio_cb);
                brant_resize_ui(h);
        end
    end
end

set(findall(h_fig,'-property','FontSize'), 'FontSize', 8);
brant_config_figure(h_fig, 'Normalized');

function chb_cb(obj, evd, mode)

h_parent = get(obj, 'Parent');
chb_data = get(obj, 'Userdata');
jobman = get(h_parent, 'Userdata');
val = get(obj, 'Value');

switch(mode)
    case 'num_bin_num_edit'
        if (val == 1)
            for m = 1:size(chb_data)
                if strcmp(chb_data{m, 1}, 'enable_edit')
                    h_edit = findobj(h_parent, 'Tag', chb_data{m, 2});
                    set(h_edit, 'Enable', 'on');
                    edit_str = get(h_edit, 'String');
                    edit_field = get(h_edit, 'Userdata');
                    set_field_vals(h_parent, jobman, edit_field, str2num(edit_str));
                end
            end
        else
            for m = 1:size(chb_data)
                if strcmp(chb_data{m, 1}, 'enable_edit')
                    h_edit = findobj(h_parent, 'Tag', chb_data{m, 2});
                    set(h_edit, 'Enable', 'off');
                    edit_field = get(h_edit, 'Userdata');
                    set_field_vals(h_parent, jobman, edit_field, []);
                end
            end
        end
    otherwise
        set_field_vals(h_parent, jobman, chb_data, val);
end

brant_except_ui(h_parent);

function popupmenu_cb(obj, evd, mode)
h_parent = get(obj,'Parent');
val = get(obj, 'Value');
curr_field = get(obj, 'Userdata');
opts = get(obj, 'String');
jobman = get(h_parent, 'Userdata');

for m = 1:size(curr_field, 1)
    switch(curr_field{m, 1})
        case 'set_val_num'
            jobman = set_field_vals(h_parent, jobman, {curr_field(m, 3)}, str2num(opts{val}));
        case 'set_color'
            h_color = findobj(h_parent, 'Tag', curr_field{m, 2});
            color_modules = field_vals(jobman, curr_field(m, 3));
            set(h_color, 'BackgroundColor', color_modules(val, :));
        case 'set_val_str'
            jobman = set_field_vals(h_parent, jobman, curr_field(m, 3), opts{val});
    end
end

function radio_cb(obj, evd, btns, mode) %#ok<*INUSD>

h_parent = get(obj, 'Parent');
jobman = get(h_parent, 'Userdata');

set(obj, 'Value', 1);
curr_field = get(obj, 'Userdata');

for m = 1:size(curr_field, 1)
    
    switch(curr_field{m, 1})
        case 'get_val'
            val = 1;
            jobman = set_field_vals(h_parent, jobman, curr_field(m, 3), val);
        case 'set_val'
            h_get = findobj(h_parent, 'Tag', curr_field{m, 2});
            set(h_get, 'Value', 0);
            val = 0;
            jobman = set_field_vals(h_parent, jobman, curr_field(m, 3), val);
        case 'set_module_str_color_same'
            h_get = findobj(h_parent, 'Tag', curr_field{m, 2});
            color_same = jobman.(curr_field{m, 3}{1});
            
            set(h_get, 'BackgroundColor', color_same);
        case 'set_module_str_color_diff'
            h_get = findobj(h_parent, 'Tag', curr_field{m, 2}{1});
            
%             jobman_val = jobman.(curr_field{m, 3}{1});
            
            if (isempty(jobman.node_txt{1}) == 1)
                pop_str = get(h_get, 'String');
            else
                pop_str = unique(jobman.node.module);
            end
            pop_val = get(h_get, 'Value');
            
            if isnumeric(pop_str)
                pop_str = num2str(pop_str);
            end
            
            if ~iscell(pop_str)
                pop_str = cellstr(pop_str);
            end
            
            set(h_get, 'String', pop_str);
            set(h_get, 'Value', pop_val);
            h_get = findobj(h_parent, 'Tag', curr_field{m, 2}{2});
            set(h_get, 'BackgroundColor', jobman.(curr_field{m, 3}{2})(pop_val, :));
        otherwise
    end
    
%     str_radios = curr_field{m, 3};
%     
%     if numel(str_radios) == 1
%         jobman.(str_radios{1}) = val;
%     elseif numel(str_radios) == 2
%         jobman.(str_radios{1}).(str_radios{2}) = val;
%     end
end
% set(h_parent, 'Userdata', jobman);
brant_except_ui(h_parent);
  
function val = field_vals_radio(jobman, radio_type, radio_fields, n)

switch(radio_type)
%     case {'vert_two', 'hor_two'}
%         val = field_vals(jobman, radio_fields(n));
%         str = '';
    case {'vert_two', 'hor_two'}
        val = jobman.(radio_fields{n});
        str = radio_fields{n};
    case {'hor_txt'}
        if (numel(radio_fields) == 1)
            val = jobman.(radio_fields{1}{n - 1});
%             str = radio_fields{1}{n - 1};
        else
            val = jobman.(radio_fields{1}).(radio_fields{2}{n - 1});
%             str = radio_fields{2}{n - 1};
        end
    case {'vert_node_color', 'vert_node_color_three'}
        if (numel(radio_fields{n}) == 1)
            val = jobman.(radio_fields{n}{1});
%             str = radio_fields{n}{1};
        else
            val = jobman.(radio_fields{n}{1}).(radio_fields{n}{2});
%             str = radio_fields{n}{2};
        end
end

function val = field_vals(jobman, fns)

% if ~iscell(fns{1})
%     fns = {fns};
% end

if (numel(fns{1}) == 1)
    val = jobman.(fns{1}{1});
else
    val = jobman.(fns{1}{1}).(fns{1}{2});
end


function jobman = set_field_vals(h_par, jobman, fns, val)

if iscell(fns{1})
    if (numel(fns{1}) == 1)
        jobman.(fns{1}{1}) = val;
    else
        jobman.(fns{1}{1}).(fns{1}{2}) = val;
    end
end
set(h_par, 'Userdata', jobman);

function set_color_cb(obj, evd, mode)

h_parent = get(obj, 'Parent');
ui_ctrl = get(obj, 'Userdata');

for m = 1:size(ui_ctrl, 1)
    switch(ui_ctrl{m, 1})
        case 'get_val_ind'
            h_val = findobj(h_parent, 'Tag', ui_ctrl{m, 2});
            module_val = get(h_val, 'Value');     
        case 'set_color'
            h_color = findobj(h_parent, 'Tag', ui_ctrl{m, 2});
            old_color = get(h_color, 'BackgroundColor');
            new_color = uisetcolor(old_color, 'Set Color');
            set(h_color, 'BackgroundColor', new_color);

            jobman = get(h_parent, 'Userdata');
            
            if ((exist('module_val', 'var') == 1) && isfield(jobman, 'node'))
                old_val = field_vals(jobman, ui_ctrl(m, 3));
                old_val(module_val, :) = new_color;
                set_field_vals(h_parent, jobman, ui_ctrl(m, 3), old_val);
            else
                set_field_vals(h_parent, jobman, ui_ctrl(m, 3), new_color);
            end
    end
end


function pushbutton_cb(obj, evd, mode)

h_parent = get(obj, 'Parent');

if isempty(h_parent)
    return;
end

jobman = get(h_parent, 'Userdata');
ui_ctrl = get(obj, 'Userdata');

% disp_unk_ind = cell2mat(cellfun(@(x) strcmp('disp_unknown', x), ui_ctrl, 'UniformOutput', false));
disp_unk_ind = cell2mat(cellfun(@(x) strcmp('multi_single', x), ui_ctrl, 'UniformOutput', false));

% disp_contents_ind = cell2mat(cellfun(@(x) strcmp('disp_contents', x), ui_ctrl, 'UniformOutput', false));
org_mode = mode;

disp_input_ind = cell2mat(cellfun(@(x) strcmp('disp_input', x), ui_ctrl, 'UniformOutput', false));
disp_inputs_ind = cell2mat(cellfun(@(x) strcmp('disp_inputs', x), ui_ctrl, 'UniformOutput', false));
    
if any(cellfun(@(x) strcmp(mode, x), {'str_nifti', 'str_mat', 'str_dir', 'str_mat', 'str_csv',...
                                      'disp_coordinates', 'str_surf', 'str_edge', 'str_node'}))
    img_ind = find(disp_input_ind(:, 1), 1);
    h_input = findobj(h_parent, 'Tag', ui_ctrl{img_ind, 2});
    field_nms = get(h_input, 'Userdata');
    val = field_vals(jobman, field_nms);
    
    sel_one_file = 1;
else
    img_ind = find(disp_inputs_ind(:, 1), 1);
    h_input = findobj(h_parent, 'Tag', ui_ctrl{img_ind, 2});
    field_nms = get(h_input, 'Userdata');
    val = field_vals(jobman, field_nms);
    
    sel_one_file = 0;
end

table_support = '^.*\.(|CSV|csv|txt|TXT)$';
nifti_support = '^.*\.(nii|img|nii.gz|NII|IMG|NII.GZ)$';

switch(mode)
    % single file input below
    case 'str_nifti'
        [disp_input, sts] = cfg_getfile(1, nifti_support, '', val);
    case 'str_csv'
        [disp_input, sts] = cfg_getfile([0 1], table_support, '', val, '');
    case 'str_mat'
        [disp_input, sts] = cfg_getfile(1, '^.*\.mat$', '', val);
    case 'str_surf'
        surf_pth = fullfile(fileparts(which('brant')), 'brant_surface');
        [disp_input, sts] = cfg_getfile(1, '^.*\.(txt|nii|img|nii.gz)$', '', val, surf_pth);
    case 'str_edge'
        [disp_input, sts] = cfg_getfile([0, 1], table_support, '', val);
    case 'str_node'
        [disp_input, sts] = cfg_getfile(1, table_support, '', val);
        if sts == 1
            jobman = parse_node_input(h_parent, jobman, disp_input{1});
        end
    case 'disp_coordinates'
        [disp_input, sts] = cfg_getfile([0 1], table_support, '', val, '');
    case 'str_dir'
        [disp_input, sts] = cfg_getfile(1, 'dir', '', val);
   
    case 'disp_dirs_nii'
        ui_tag = get(obj, 'Tag');
        chb_tag = strrep(ui_tag, 'pushbutton', 'checkbox_0_txt');
        chb_h = findobj(h_parent, 'Tag', chb_tag);
        if ~isempty(chb_h)
            chb_val = get(chb_h, 'Value');
            if (chb_val == 1)
                [text_input, sts] = cfg_getfile(1, '^.*\.txt$', '', '', pwd, '.*.txt');
                if (sts == 1)
                    disp_input = importdata(text_input{1}, '\n');
                
                    if ~isstruct(disp_input)
                        dir_ind = cellfun(@(x) exist(x, 'dir') == 7, disp_input);
                        if all(dir_ind)
                            sts = 1;
                        else
                            dir_not_ok = disp_input(~dir_ind);
                            sprintf('Listed directories do not exist!\n')
                            error(sprintf('\t%s\n', dir_not_ok{:})); %#ok<SPERR>
                        end
                    else
                        error('Bad or broken file detected, Please check.')
                    end
                end
            else
                [disp_input, sts] = cfg_getfile([1, Inf], 'dir', '', val, pwd, '^[^.].*$');
            end
        else
            [disp_input, sts] = cfg_getfile([1, Inf], 'dir', '', val, pwd, '^[^.].*$');
        end
        
        
    case 'disp_net_calcs'
        nm_tmp = findobj(0, 'Name', 'Brant Net Measure Options', 'Type', 'Figure');
        if isempty(nm_tmp)
            hfig_inputdlg = brant_net_measures_setup(h_parent);
            set(h_parent, 'DeleteFcn', {@delete_figure, hfig_inputdlg});
        else
            figure(nm_tmp);
        end
        
        net_disp_tmp = get(h_parent, 'UserData');
        net_disp = net_disp_tmp.net_calcs;

        field_tmp = fieldnames(net_disp);
        struct_ind = cellfun(@(x) ~isstruct(net_disp.(x)), field_tmp);
        field_tmp2 = field_tmp(struct_ind);
        sel_ind = cellfun(@(x) net_disp.(x) == 1, field_tmp2);

        disp_str = sprintf('%s\n', field_tmp2{sel_ind});

        set(h_input, 'String', disp_str);
        sts = 0;
end

if sts == 1
    if (sel_one_file == 1)
        set(h_input, 'String', disp_input);
        set_field_vals(h_parent, jobman, field_nms, disp_input);
    else
        [ooo, in_index] = unique(disp_input); %#ok<ASGLU>
        disp_input_uni = disp_input(sort(in_index));
        set(h_input, 'String', disp_input_uni);
        set_field_vals(h_parent, jobman, field_nms, disp_input_uni);
    end
end

function jobman = parse_node_input(h_parent, jobman, node_file)

jobman.node = brant_parse_node(node_file);                

h_label = findobj(h_parent, 'Tag', 'show_label:checkbox');
if (isfield(jobman.node, 'label') == 0)
    jobman.show_label = 0;
    set(h_label, 'Value', 0);
else
    jobman.show_label = 1;
    set(h_label, 'Value', 1);
end


h_size = findobj(h_parent, 'Tag', 'node_size:checkbox');
h_size_txt = findobj(h_parent, 'Tag', 'node_size:edit');
if isfield(jobman.node, 'size')
    jobman.node_size = [];
    
    set(h_size, 'Value', 0);
    set(h_size_txt, 'enable', 'off');
else
    jobman.node_size = str2num(get(h_size_txt, 'String'));
    set(h_size, 'Value', 1);
    set(h_size_txt, 'enable', 'on');
end


uni_modules = unique(jobman.node.module);
jobman.modules_info = uni_modules{1};
jobman.all_modules = uni_modules;

num_modules = numel(uni_modules);
color_tmp = rand(num_modules, 3);

num_module = numel(uni_modules);
modules_ind = cellfun(@(x) find(strcmp(x, uni_modules)), jobman.node.module);
jobman.color_modules = color_tmp;

if all(isfield(jobman.node, {'r', 'g', 'b'}))
    h_user_define = findobj(h_parent, 'Tag', 'user_color:radio');
    set(h_user_define, 'Value', 1);
    
    h_same_color = findobj(h_parent, 'Tag', 'same_color:radio');
    set(h_same_color, 'Value', 0);
    
    h_diff_color = findobj(h_parent, 'Tag', 'diff_color:radio');
    set(h_diff_color, 'Value', 0);
    
    jobman.user_color = 1;
    jobman.same_color = 0;
    jobman.diff_color = 0;
    jobman.color_nodes = [jobman.node.r, jobman.node.g, jobman.node.b];
else
    jobman.user_color = 0;
    jobman.same_color = 1;
    jobman.diff_color = 0;
    jobman.color_nodes = color_tmp(modules_ind, :);
    jobman.color_same = [0.8147 0.9058 0.1270]; %color_tmp(1, :);
    h_same_color = findobj(h_parent, 'Tag', 'color_same:text');
    set(h_same_color, 'BackgroundColor', jobman.color_same);
    
    h_user_define = findobj(h_parent, 'Tag', 'user_color:radio');
    set(h_user_define, 'Value', 0);
    
    h_same_color = findobj(h_parent, 'Tag', 'same_color:radio');
    set(h_same_color, 'Value', 1);
    
    h_diff_color = findobj(h_parent, 'Tag', 'diff_color:radio');
    set(h_diff_color, 'Value', 0);
end

if ~isempty(jobman.modules_info)
    h_module = findobj(h_parent, 'Tag', 'modules_info:popupmenu');
    set(h_module, 'String', uni_modules, 'Value', 1);
    
    h_module_color = findobj(h_parent, 'Tag', 'color_modules:text');
    set(h_module_color, 'BackgroundColor', color_tmp(1, :));
end

function s = setsubfield(s, fields, val)

if ischar(fields)
    fields = regexp(fields, '\.', 'split'); % split into cell array of sub-fields
end

if (length(fields) == 1)
    s.(fields{1}) = val;
else
    try
        subfield = s.(fields{1}); % see if subfield already exists
    catch
        subfield = struct([]); % if not, create it
    end
    s.(fields{1}) = setsubfield(subfield, fields(2:end), val);
end

function edit_cb(obj, evd, mode) %#ok<*INUSL>
h_parent = get(obj, 'Parent');
h_parent_name = get(h_parent, 'Name');

jobman = get(h_parent, 'Userdata');

field_name = get(obj, 'Userdata');
str = get(obj, 'String');

table_support = '^.*\.(csv|txt)$';
nifti_support = '^.*\.(nii|hdr|img|nii.gz)$';

switch(mode)
    case {'num_short_right', 'num_short_left', 'num_coords', 'num_long', 'num_longest', 'num_bin_num_edit'}
        num = str2num(str); %#ok<ST2NM> %do not use str2double! 
        if (~isempty(num)) || (strcmpi(h_parent_name, 'roi mapping') && isempty(num))
            set_field_vals(h_parent, jobman, field_name, num);
        else
            val = field_vals(jobman, field_name);
            cb_obj = get(obj, 'Callback');
            val = edit_str_cvt(val, cb_obj{2});
            set(obj, 'String', val);
        end
    case 'str_dir'
        if ~iscell(str)
            str = {str};
        end
        set_field_vals(h_parent, jobman, field_name, str);
    case {'str_long_right', 'str_long_left', 'str_short_right', 'str_thr_parse', 'str_short_left'}
        set_field_vals(h_parent, jobman, field_name, str);
    case {'str_nifti', 'str_mat', 'str_surf', 'str_edge', 'str_csv'}
        if ~iscell(str)
            str = {str};
        end
        
        if ~isempty(str{1})
            if (exist(str{1}, 'file') ~= 2)
                warning('File %s not found!', str{1});
                str{1} = '';
                set(obj, 'String', str{1});
            end
        end
        
        set_field_vals(h_parent, jobman, field_name, str);
        
    case 'str_node'
        if ~iscell(str)
            str = {str};
        end
        
        if (exist(str{1}, 'file') == 2)
            file_ext = regexpi(str{1}, table_support, 'match');
            
            jobman = parse_node_input(h_parent, jobman, str{1});
            
            set_field_vals(h_parent, jobman, field_name, str);
        else
            val = field_vals(jobman, field_name);
            set_field_vals(h_parent, jobman, field_name, val);
            set(obj, 'String', val);
        end
    case 'str_filetype_nifti'
        
%         valid_nifti_filetype = {'.nii', '.nii.gz', '.img', '.hdr'};
        nifti_ind = regexpi(str, nifti_support, 'match');
        
        if ~isempty(nifti_ind)
            set_field_vals(h_parent, jobman, field_name, str);
        else
            val = field_vals(jobman, field_name);
            set(obj, 'String', val);
            error([sprintf('\t%s is not a valid nifti/mat filetype!\n', str),...
                   sprintf('\tPlease use one of the file types listed below\n'),...
                   sprintf('\t.nii .nii.gz .img .hdr')]);
        end
        
    case 'str_filetype_mat'
        
%         valid_nifti_filetype = {'.mat'};
        matrix_ind = regexpi(str, '.(mat)$', 'match');
        
        if ~isempty(matrix_ind)
            set_field_vals(h_parent, jobman, field_name, str);
        else
            val = field_vals(jobman, field_name);
            set(obj, 'String', val);
            error([sprintf('\t%s is not a valid nifti/mat filetype!\n', str),...
                   sprintf('\tPlease use one of the file types listed below\n'),...
                   sprintf('\t.mat')]);
        end
        
    case 'str_filetype_txt'
%         valid_nifti_filetype = {'.txt'};
        nifti_ind = regexpi(str, '.(txt)$', 'match');
        if ~isempty(nifti_ind)
            set_field_vals(h_parent, jobman, field_name, str);
        else
            val = field_vals(jobman, field_name);
            set(obj, 'String', val);
            error([sprintf('\t%s is not a valid text file!', str),...
                   sprintf('\tPlease use the file types listed below\n\t'),...
                   sprintf('\t.txt')]);
        end
end

function run_cb(obj, evd, process_fun)
h_parent = get(obj, 'Parent');
jobman = get(h_parent, 'Userdata');
dlg_title = get(h_parent, 'Name');

if isfield(jobman, 'out_dir')
    if ~isfield(jobman, 'out_ind')
        if isempty(jobman.out_dir{1}), error('Please input a directory for output!'); end
        if exist(jobman.out_dir{1}, 'dir') ~= 7, mkdir(jobman.out_dir{1}); end
    else
        if (jobman.out_ind == 1)
            if isempty(jobman.out_dir{1}), error('Please input a directory for output!'); end
            if exist(jobman.out_dir{1}, 'dir') ~= 7, mkdir(jobman.out_dir{1}); end
        end
    end
end
% process_fun

func_need_hcon = {'network visualization', 'roi mapping', 'surface mapping'};

try
%     save parameters directly to the output dir or wkdir
%     brant_save_gui(obj, evd, process_fun, [])
    if any(strcmpi(dlg_title, func_need_hcon))
        process_fun(jobman, h_parent);
    else
        process_fun(jobman);
    end
catch err
    rethrow(err);
end

function delete_figure(obj, evd, varargin)
if nargin > 2
    % delete whatever handle send to this function
    if ishandle(varargin{1})
        delete(varargin{1});
    end
end

function close_window(obj, evd, varargin)
h_parent = get(obj, 'Parent');
delete(h_parent);




