function brant_inputdlg_new(dlg_title, dlg_rstbtn, sub_title_field, prompt, defAns, calc_type, h_prep_main)
% dlg_title, dlg_rstbtn, sub_title_field, prompt, defAns, calc_type, h_prep_main
ncols = numel(prompt);

figColor = 0.9 * [1 1 1];
% figColor = 0.9 * rand(1, 3);

cols = cellfun(@(x) size(x, 1), prompt);
comp = ncols == 1;

figsize.x = 40 + 120 * (ncols+comp) + (ncols-1+comp)*20 - comp*(1-dlg_rstbtn)*110 + (ncols == 1) * 60 - (comp == 1) * 40;  % width
figsize.y = 45*(max(cols) + 1) + 120;   % height
btn_bkgColor = [0.94 0.94 0.94];

h_main = findobj(0,  'Name',             'brant_Preprocessing',...
                     'Tag',              'brant_preprocess_main');
pos_main = get(h_main, 'Position');

hfig_inputdlg = figure(...
    'IntegerHandle',    'off',...
    'Position',         [pos_main(1) + pos_main(3) + 16, pos_main(2) + pos_main(4) - figsize.y, figsize.x, figsize.y],...
    'Color',            figColor,...
    'Name',             dlg_title,...
    'CloseRequestFcn',  @cancel_cb,...
    'UserData',         'fig_inputdlg',...
    'NumberTitle',      'off',...
    'Tag',              'figInput',...	
    'Units',            'pixels',...
    'Resize',           'off',...	
    'MenuBar',          'none',...    
    'Visible',          'on');

h_panel = zeros(ncols, 1);
panel_hight = zeros(ncols, 1);
% labels and input boxes
for m = 1:ncols
    
    panel_hight(m) = cols(m) * 45 + 30;
    
    if ~isempty(sub_title_field{1, m})
        h_panel(m) = uipanel(...
                    'Parent',           hfig_inputdlg,...
                    'Units',            'pixels',...
                    'Title',            sub_title_field{1, m},...
                    'TitlePosition',    'lefttop',...
                    'Position',         [20+140*(m-1)+comp*(figsize.x/2 - 70), figsize.y - 45 - panel_hight(m), 120, panel_hight(m)],...
                    'Tag',              sub_title_field{2, m},...
                    'Visible',          'on',...
                    'BackgroundColor',  figColor,...
                    'BorderType',       'none');
                    ...'BorderWidth',      2);
        
    else
        h_panel(m) = h_panel(m - 1);
        panel_hight(m) = panel_hight(m - 1);
        set(h_panel(m), 'Position', [20, figsize.y - 45 - panel_hight(m), figsize.x - 40, panel_hight(m)]);
    end
end

for m = 1:ncols
    
    shift_col = isempty(sub_title_field{1, m});
    box_panel_exist = 0;
    
    for n = 1:size(prompt{m}, 1)

        if ~isempty(sub_title_field{2, m})
            val_ui = defAns.(sub_title_field{2, m}).(prompt{m}{n, 3});
        else
            val_ui = defAns.(prompt{m}{n, 3});
        end
        
        val_tag = prompt{m}{n, 3};
        val_type = prompt{m}{n, 2};
        val_str = prompt{m}{n, 1};
        
        switch(val_type)
            case {'empty'}
            case {'numeric','string'}
                if strcmp(val_type, 'numeric')
                    str_edit = num2str(val_ui);
                    if size(str_edit, 1) > 1
                        str_cell = cellstr(str_edit);
                        str_tmp = sprintf('%s;',str_cell{:});
                        str_edit = str_tmp(1:end-1);
                    end
                    str_edit = regexprep(str_edit, ';\s+', ';');
                    str_edit = regexprep(str_edit, '\s+', ',');
                else
                    str_edit = val_ui;
                end

                uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_str,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n, 120, 15],... 
                    'Style',                'text',...
                    'HorizontalAlignment',  'left',...
                    'FontSize',             8,...
                    'BackgroundColor',      figColor);

                h_edit = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               str_edit,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n-15, 120, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1]);

            case {'popup'}
                [pop_str, pop_pos] = specific_pops(dlg_title, val_ui);
                uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_str,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n, 120, 15],...
                    'Style',                'text',...
                    'HorizontalAlignment',  'left',...
                    'FontSize',             8,...
                    'BackgroundColor',      figColor);

                h_popup = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               pop_str,...
                    'Value',                pop_pos,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n-15, 120, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'popupmenu',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1]);

            case {'file', 'file_txt', 'file_img', 'file_img_*'}
                
                uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_str,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n, 120, 15],... 
                    'Style',                'text',...
                    'HorizontalAlignment',  'left',...
                    'FontSize',             8,...
                    'BackgroundColor',      figColor);

                h_edit = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_ui,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n-15, 104, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1],...
                    'Callback',             {@check_edit, val_type, val_ui, []});

                uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               '...',...
                    'UserData',             h_edit,...
                    'Position',             [105, panel_hight(m)-45*n-15, 15, 15],...
                    'Style',                'pushbutton',...
                    'BackgroundColor',      btn_bkgColor,...
                    'Callback',             {@btn_cb, h_edit, val_type});

            case {'box_file_txt', 'box_file_img', 'box_file_img_*'}
                h_edit = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_ui,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n-15, 104, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1],...
                    'Callback',             {@check_edit, val_type, val_ui, []});

                h_pushbutton = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               '...',...
                    'UserData',             h_edit,...
                    'Position',             [105, panel_hight(m)-45*n-15, 15, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'pushbutton',...
                    'BackgroundColor',      btn_bkgColor,...
                    'Callback',             {@btn_cb, h_edit, val_type});
                
                h_chb = uicontrol(...
                    'Parent',           h_panel(m),...
                    'String',           val_str,...
                    'Position',         [shift_col*140, panel_hight(m)-45*n, 120, 18],...
                    'Tag',              val_tag,...
                    'Userdata',         [h_edit, h_pushbutton],...
                    'Style',            'checkbox',...
                    'Value',            ~isempty(val_ui),...
                    'BackgroundColor',  figColor,...
                    'Callback',         {@chb_cb, h_edit, h_pushbutton});
                
                set(h_edit, 'Callback', {@check_edit, val_type, val_ui, h_chb})
                
                val = ~isempty(val_ui);
                if val == 1
                    set(h_edit, 'Enable', 'on');
                    set(h_pushbutton, 'Enable', 'on');
                else
                    set(h_edit, 'Enable', 'off');
                    set(h_pushbutton, 'Enable', 'off');
                end

                brant_resize_ui(h_chb);

            case 'box_numeric'
                h_edit = uicontrol(...
                    'Parent',               h_panel(m),...
                    'String',               val_ui,...
                    'Position',             [shift_col*140, panel_hight(m)-45*n-15, 84, 15],...
                    'Tag',                  val_tag,...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1 1 1]);
                
                h_chb = uicontrol(...
                    'Parent',           h_panel(m),...
                    'String',           val_str,...
                    'Position',         [shift_col*140, panel_hight(m)-45*n, 120, 18],...
                    'Tag',              val_tag,...
                    'Userdata',         h_edit,...
                    'Style',            'checkbox',...
                    'Value',            ~isempty(val_ui),...
                    'BackgroundColor',  figColor,...
                    'Callback',         {@chb_cb, h_edit, []});
                
                val = ~isempty(val_ui);
                if val == 1
                    set(h_edit, 'Enable', 'on');
%                     set(h_pushbutton, 'Enable', 'on');
                else
                    set(h_edit, 'Enable', 'off');
%                     set(h_pushbutton, 'Enable', 'off');
                end
                
                brant_resize_ui(h_chb);
                
            case 'box'
                h_chb = uicontrol(...
                    'Parent',           h_panel(m),...
                    'String',           val_str,...
                    'Position',         [shift_col*140, panel_hight(m)-45*n-15, 120, 19],...
                    'Tag',              val_tag,...
                    'Style',            'checkbox',...
                    'Value',            val_ui,...
                    'BackgroundColor',  figColor);
                brant_resize_ui(h_chb);

            case 'box_panel'
                box_panel_exist = 1;
                h_chb_box_panel = uicontrol(...
                    'Parent',           h_panel(m),...
                    'String',           val_str,...
                    'Position',         [shift_col*140, panel_hight(m)-45*n-15, 120, 19],...
                    'Tag',              val_tag,...
                    'Style',            'checkbox',...
                    'Value',            val_ui,...
                    'BackgroundColor',  figColor,...
                    'Callback',         {@box_panel_cb, h_panel(m)});
                brant_resize_ui(h_chb_box_panel);
                
            case {'radio'}

                h_rb = uicontrol(...
                    'Parent',           h_panel(m),...
                    'String',           val_str,...
                    'Position',         [shift_col*140, panel_hight(m)-45*n-15, 120, 25],...
                    'Tag',              val_tag,...
                    'Style',            'radiobutton',...
                    'Value',            val_ui,...
                    'BackgroundColor',  figColor,...
                    'Callback',         @singleSelection);
                brant_resize_ui(h_rb);
        end
        
        if exist('h_edit', 'var') == 1
            set(h_edit, 'Position', get(h_edit, 'Position') + [1, 0, -1, 0]);
            clear('h_edit');
        end
        
        if exist('h_popup', 'var') == 1
            set(h_popup, 'Position', get(h_popup, 'Position') + [1, 0, -1, 0]);
            clear('h_popup');
        end
    end
    
    if box_panel_exist == 1
        box_panel_cb(h_chb_box_panel, [], h_panel(m));
    end
end

btnpos.x = figsize.x/2 - 30 + (1-dlg_rstbtn)*25;
btnpos.y = 60;

btnOpt = {...
    'OK',       [btnpos.x - 70 + (1-dlg_rstbtn)*10,	btnpos.y,  60, 20],     'ok_btn',       {@ok_cb, dlg_title, sub_title_field, prompt, defAns, h_prep_main};...
    'Cancel',	[btnpos.x + 70 - (1-dlg_rstbtn)*60,	btnpos.y,  60, 20],     'cancel_btn',   @cancel_cb;...
	'?',        [btnpos.x + 140 - (1-dlg_rstbtn)*60, btnpos.y,  20, 20],     'help_btn',      {@brant_help_cb, hfig_inputdlg, dlg_title}};

for m = 1:3
    h.btn(m) = uicontrol(...
        'Parent',           hfig_inputdlg,...
        'String',           btnOpt{m, 1},...
        'UserData',         btnOpt{m, 1},...
        'Position',         btnOpt{m, 2},...
        'Tag',              btnOpt{m, 3},...
        'Style',            'pushbutton',...
        'BackgroundColor',  btn_bkgColor,...
        'Callback',         btnOpt{m, 4});
end

function box_panel_cb(obj, evd, h_panel)

val = get(obj, 'Value');

h_panel_obj = setdiff(get(h_panel, 'Children'), obj);

obj_data_old = get(h_panel_obj, 'Enable');

if val == 1
    obj_data = get(obj, 'Userdata');
    if isempty(obj_data)
        obj_data = obj_data_old;
    end
    for m = 1:numel(h_panel_obj)
        set(h_panel_obj(m), 'Enable', obj_data{m});
    end
else
    set(h_panel_obj, 'Enable', 'off');
    set(obj, 'Userdata', obj_data_old);
end

obj_gs = findobj(h_panel, 'Tag', 'gs', 'Style', 'Checkbox');
if ~isempty(obj_gs)
    except_control(obj_gs);
end

function check_edit(obj, evd, datatype, val_ui, h_chb)

str = get(obj, 'String');
enable_ind = 0;

if ~isempty(str)
    switch(datatype)
        case {'file','file_txt','file_img', 'file_img_tmp', 'file_img_*', 'box_file_txt', 'box_file_img', 'box_file_img_*'}
            if exist(str, 'file') ~= 2
                set(obj, 'String', val_ui);
            	warndlg(sprintf('Input file not found:\n%s\nSet to last input:\n%s', str, val_ui));
            else
                enable_ind = 1;
            end
    end
end

if ~isempty(h_chb)
    set(h_chb, 'Value', enable_ind == 1);
end

% exceptions
% if strcmpi(evd, 'manual') == 0
str_tag = get(obj, 'Tag');
switch(str_tag)
    case 'gs'
        except_control(obj);
end

function chb_cb(obj, evd, h_edit, h_pb)
val = get(obj, 'Value');

if ~isempty(h_edit)
    if val == 1
        set(h_edit, 'Enable', 'on');
    else
        set(h_edit, 'Enable', 'off');
    end
end

if ~isempty(h_pb)
    if val == 1
        set(h_pb, 'Enable', 'on');
    else
        set(h_pb, 'Enable', 'off');
    end
end

if strcmp(evd, 'manual') == 0
    except_control(obj);
end

function ok_cb(obj, evd, dlg_title, sub_title_field, prompt, defAns, h_prep_main) %#ok<*INUSL>

h_input = get(obj, 'Parent');
data_fig = get(h_prep_main, 'Userdata');
outAns = data_fig.(dlg_title);

switch(dlg_title)
    case {'normalise', 'normalise12', 'coregister', 'denoise', 'realign'}
        sub_fields_1 = fieldnames(defAns);
        for m = 1:numel(sub_fields_1)
            h_panel = findobj(h_input, 'Tag', sub_fields_1{m}, 'Type', 'uipanel');
            for n = 1:size(prompt{m}, 1)
                sub_field_2 = prompt{m}{n, 3};
                outAns.(sub_fields_1{m}).(sub_field_2) = get_vals(h_panel, sub_field_2, prompt{m}{n, 2});
            end
        end
    case {'slicetiming', 'filter', 'smooth'}
        h_panel = findobj(h_input, 'Type', 'uipanel');
        for m = 1:numel(prompt)
            for n = 1:size(prompt{m}, 1)
                sub_field_2 = prompt{m}{n, 3};
                outAns.(sub_field_2) = get_vals(h_panel, sub_field_2, prompt{m}{n, 2});
            end
        end
end


data_fig.(dlg_title) = outAns;
if data_fig.pref.sync == 1
    data_fig = brant_prep_sync(data_fig, dlg_title);
end

h_curr_chb = findobj(h_prep_main, 'Tag', [dlg_title, '_chb']);
set(h_curr_chb, 'Value', 1);
data_fig.ind.(dlg_title) = 1;

set(h_prep_main, 'Userdata', data_fig);
delete(gcf);
brant_update_pre_disp;

function val_out = get_vals(h_panel, field_nm, datatype)

h_obj = findobj(h_panel, 'Tag', field_nm);
switch(datatype)
    case {'file','file_txt','file_img', 'file_img_tmp', 'file_img_*', 'string'}
        val_out = get(h_obj,'String');
    case {'numeric'}
        val_out_tmp = get(h_obj,'String');
        val_out = str2num(val_out_tmp); %#ok<ST2NM>
    case 'popup'
        itemnum = get(h_obj,'Value');
        totstr = get(h_obj,'String');
        val_out = totstr{itemnum};
    case {'box', 'box_must', 'radio', 'box_panel'}
        val_out = get(h_obj, 'Value');
    case 'box_numeric'
        h_chb = findobj(h_panel, 'Tag', field_nm, 'Style', 'checkbox');
        if get(h_chb,'Value') == 1
            h_edit = findobj(h_panel, 'Tag', field_nm, 'Style', 'edit');
            val_out_tmp = get(h_edit,'String');
            val_out = str2num(val_out_tmp); %#ok<ST2NM>
        else
            val_out = [];
        end       
    case {'box_file_txt', 'box_file_img', 'box_file_img_*'}
        h_chb = findobj(h_panel, 'Tag', field_nm, 'Style', 'checkbox');
        if get(h_chb,'Value') == 1
            h_edit = findobj(h_panel, 'Tag', field_nm, 'Style', 'edit');
            val_out = get(h_edit,'String');
        else
            val_out = '';
        end
end

function cancel_cb(obj, evd) %#ok<*INUSD>
delete(gcf);
        
function btn_cb(obj, evd, h_edit, val_type)

val = get(h_edit, 'String');
switch(val_type)
    case {'file', 'file_img', 'file_img_tmp', 'file_img_*', 'box_file_img', 'box_file_img_*'}
        [file_input, sts] = cfg_getfile(1, '^.*\.(nii|img)$', '', {val}, '');
        if sts == 1
            set(h_edit, 'String', file_input{1});
        end
    case {'file_txt', 'box_file_txt'}
        [file_input, sts] = cfg_getfile(1, '^.*\.(txt)$', '', {val}, '');
        if sts == 1
            set(h_edit, 'String', file_input{1});
        end
end

function singleSelection(obj, evd)
obj_parent = get(obj, 'Parent');
radiobox = findobj(obj_parent, 'Style', 'radiobutton');

arrayfun(@(x) set(x, 'Value', 0), radiobox);
set(obj, 'Value', 1);

except_control(obj);


function except_control(obj)
% for global signal regression case only

obj_parent = get(obj, 'Parent');
obj_type = get(obj, 'Style');

switch(obj_type)
    case 'radiobutton'
        str = get(obj, 'String');
        
        switch(str)
            case {'GSR', 'GSR and no GSR', 'no GSR'}
                h_fig = get(obj_parent, 'Parent');
                h_gs = findobj(h_fig, 'Style', 'checkbox', 'Tag', 'gs');
                h_gs_edit = findobj(h_fig, 'Style', 'edit', 'Tag', 'gs');
                h_gs_pb = findobj(h_fig, 'Style', 'pushbutton', 'Tag', 'gs');
                
                if strcmp(get(h_gs, 'Enable'), 'on')
                    if strcmp(str, 'no GSR')
                        set(h_gs, 'Value', 0);
                        chb_cb(h_gs, 'manual', h_gs_edit, h_gs_pb);
                    else
                        set(h_gs, 'Value', 1);
                        chb_cb(h_gs, 'manual', h_gs_edit, h_gs_pb);
                    end
                else
                    except_control(h_gs);
                end
        end
        
    case {'checkbox', 'edit'}
        
        if strcmp(obj_type, 'edit')
            str = get(obj, 'Tag');
            val = ~isempty(get(obj, 'String'));
        else
            str = get(obj, 'String');
            val_tmp = get(obj, 'Value');
            ena_ind = strcmp(get(obj, 'Enable'), 'on');
            val = val_tmp & ena_ind;
        end
        
        switch(str)
            case {'global signal mask', 'gs'}
                h_fig = get(get(obj, 'Parent'), 'Parent');
                h_gsr = findobj(h_fig, 'Style', 'radio', 'Tag', 'gsr');
                h_nogsr = findobj(h_fig, 'Style', 'radio', 'Tag', 'nogsr');
                h_bothgsr = findobj(h_fig, 'Style', 'radio', 'Tag', 'bothgsr');
                
                val_nogsr = get(h_nogsr, 'Value');
                if val == 1 && val_nogsr == 1
                    set(h_gsr, 'Value', 1);
                    set(h_nogsr, 'Value', 0);
                    set(h_bothgsr, 'Value', 0);
                elseif val == 0
                    set(h_gsr, 'Value', 0);
                    set(h_nogsr, 'Value', 1);
                    set(h_bothgsr, 'Value', 0);
                end
        end
end



function [pop_str, pop_pos] = specific_pops(dlg_title, val)
switch(dlg_title)
    case 'coregister'
        pop_str = {'mi','nmi','ecc','ncc'};
        pop_pos = find(strcmp(pop_str, val));
    case 'normalise'
        pop_str = {'mni','imni','rigid','subj','eastern','none'};
        pop_pos = find(strcmp(pop_str, val)); % find(cellfun(@(x) strcmp(x, val), pop_str));
    case 'normalise12'
        pop_str = {'mni', 'subj', 'eastern', 'none', ''};
        pop_pos = find(strcmp(pop_str, val)); % find(cellfun(@(x) strcmp(x, val), pop_str));
    case {'denoise', 'filter'}
        pop_str = {'group tsnr', 'none'};
        pop_pos = find(strcmp(pop_str, val));
end
