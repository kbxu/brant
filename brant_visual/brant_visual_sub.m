function brant_visual_sub(dlg_title, prompt)

ncols = size(prompt, 1);



figColor = [0.94 0.94 0.94];

fig.x = 400;
fig.y = 200;
fig.len = 250;
fig.height = 50 + 60;

for m = 1:ncols
    if ~isempty(prompt{m, 2})
        ele_pps = regexp(prompt{m, 1}, '\w+', 'match');
        if strcmp(ele_pps{1}, 'radio')
            radio_btns = regexp(prompt{m, 2}, '\w+', 'match');
            for n = 1:numel(radio_btns)
                prompt_sub = brant_postprocess_parameters(radio_btns{n});
                if isempty(prompt_sub)
                    jobman.(radio_btns{n}) = prompt{m, 3}(n);
                else
                    jobman.(radio_btns{n}) = prompt{m, 3}(n);
                    for nn = 1:size(prompt_sub, 1)
                        if isempty(strfind(prompt_sub{nn, 1}, 'disp'))
                            radio_btns_sub = regexp(prompt_sub{nn, 2}, '\w+', 'match');
                            for nnn = 1:numel(radio_btns_sub)
                                jobman.([radio_btns{n}, '_struc']).(radio_btns_sub{nnn}) = prompt_sub{nn, 3};
                            end
                        else
                            radio_btns_sub = regexp(prompt_sub{nn, 2}, '\w+', 'match');
                            for nnn = 1:numel(radio_btns_sub)
                                jobman.([radio_btns{n}, '_struc']).(radio_btns_sub{nnn}).inputfile = prompt_sub{nn, 3};
                                jobman.([radio_btns{n}, '_struc']).(radio_btns_sub{nnn}).subjs = '';
                            end
                        end
                    end
                end
            end
        elseif strcmp(ele_pps{1}, 'pop')
                    jobman.(prompt{m, 2}) = str2num(prompt{m, 3}{1});
        else
            if strfind(ele_pps{2}, 'disp')
                jobman.(prompt{m, 2}).inputfile = prompt{m, 3};
                jobman.(prompt{m, 2}).subjs = '';
            else
                if strcmp(ele_pps{2}, 'num_short')
                    ui_field = regexp(prompt{m, 2}, '\w+', 'match');
                    for i = 1: size(ui_field, 2)
                        jobman.(ui_field{i}) = prompt{m, 3}(i);
                    end
                elseif strcmp(ele_pps{2}, 'view')
                    jobman.(prompt{m, 2}) = 1;
                elseif ~strcmp(ele_pps{2}, 'text_color')
                    jobman.(prompt{m, 2}) = prompt{m, 3};
                end
            end
        end
    end
end

    

fig = figure_height(prompt, fig);

h_parent = get(findobj(0, 'String', dlg_title), 'Parent');
pos_par = get(h_parent, 'Position');
fig_pos = [pos_par(1) + pos_par(3) + 15, pos_par(4) + pos_par(2) - fig.height, fig.len, fig.height];

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
current_pos.y = 20;

[text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size;

button_len = 51;
uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               'apply',...
    'UserData',             '',...
    'Tag',                  dlg_title,...
    'Position',             [current_pos.x, current_pos.y, button_len, 20],...
    'Style',                'pushbutton',...
    'BackgroundColor',      figColor,...
    'Callback',             @run_cb);
uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               'reset',...
    'UserData',             jobman,...
    'Tag',                  dlg_title,...
    'Position',             [current_pos.x + (button_len + 2) * 1+ 28, current_pos.y, button_len, 20],...
    'Style',                'pushbutton',...
    'BackgroundColor',      figColor,...
    'Callback',             @reset_cb);
uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               'cancel',...
    'UserData',             '',...
    'Position',             [current_pos.x + (button_len + 2) * 3, current_pos.y, button_len, 20],...
    'Style',                'pushbutton',...
    'BackgroundColor',      figColor,...
    'Callback',             @close_window);

current_pos.y = fig.height - 80;

create_elements(hfig_inputdlg, prompt, [current_pos.x, current_pos.y], 'jobman'); % create functional elements

function fig = figure_height(prompt, fig)

[text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size] = macro_size;
for m = 1:size(prompt, 1)
    if ~isempty(strfind(prompt{m, 1}, 'radio'))
        if ~isempty(strfind(prompt{m, 1}, 'vertical'))
            fig.height = fig.height + 25 * 2;
            ele_pps = regexp(prompt{m, 2}, '\w+', 'match');
            prompt_sub = brant_postprocess_parameters(ele_pps{find(prompt{m, 3})}); %#ok<*FNDSB>
            if ~isempty(prompt_sub)
                fig = figure_height(prompt_sub, fig);
            end
        elseif ~isempty(strfind(prompt{m, 1}, 'horizontal'))
            fig.height = fig.height + 25 + 8;
        end
    elseif ~isempty(strfind(prompt{m, 1}, 'edit'))
        if ~isempty(strfind(prompt{m, 1}, 'disp'))
            fig.height = fig.height + disp_size(2) + 20 + 15;
        else
            fig.height = fig.height + 25;
        end
    elseif ~isempty(strfind(prompt{m, 1}, 'pop')) || ~isempty(strfind(prompt{m, 1}, 'chb'))
        fig.height = fig.height + 25 + 8;
    else
        fig.height = fig.height + 25;
    end
end

function [text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size, pop_size] = macro_size
text_size = [55, 15];
edit_size = [125, 15];
numeric_size = [30, 15];
pushbtn_size = [15, 15];
disp_size = [210, 75];
info_size = [65, 15];
pop_size = [100, 23];

function strlen = strlen_table(str)

strlen_table_ind = {'parallel computing (cpu)',                 134		160		;...
                    'workers',                                  50		50		;...
                    'num chk',                                  50		50		;...
                    '(optional)',                               60		60		;...
                    'adjust edge color',                        102		133		;...
                    'convert to 4d',                            83		98		;...
                    'node size equal',                          96		103		;...
                    'edge size equal',                          96		103		;...
                    'r value to z value transform',             152		178		;...
                    'normalize transform',                      115		137		;...
                    'medial and lateral',                       102		133		;...
                    'matlab',                                   50		50		;...
                    'spm',                                      40		40		;...
                    'Data in different directories',            150		180		;...                    
                    'Data in one directory',                    119		143		;...
                    'node color for module',                    124		143		;...
                    'edge color for module',                    124		143		;...
                    'MNI',                                      40		42		;...
                    'TAL',                                      40		42		;...
                    'box',                                      40		41		;...
                    'sphere',                                   55		60		;...
                    'mm',                                       35		41		;...
                    'vox',                                      37		41		;...
                    'mask roi afterwards',                      117		135		;...
                    'delete timepoints only',                   119		119		;...
                    'same color for all nodes',                 135		133;...
                    'same color for all edges',                 135		133};

str_pos = strcmp(strlen_table_ind(:, 1), str);

if str_pos == 0
    strlen = 70;
    return;
end

switch(computer)
    case {'PCWIN', 'PCWIN64'}
        strlen = strlen_table_ind{str_pos, 2};
    case {'GLNX86', 'GLNXA64', 'MACI64'}
        strlen = strlen_table_ind{str_pos, 3};  
    otherwise
        strlen = strlen_table_ind{str_pos, 3};
        warning('We don''t know what operation system you are working on, and took a guss for gui size.');
end

function [sub_eles, pos_shift, block_shift] = sub_elements(ele_type, judge)

[text_size, edit_size, info_size, numeric_size, pushbtn_size, disp_size, pop_size] = macro_size;
ele_pps = regexp(ele_type, '\w+', 'match');
popupmenu_height = 23; % in pixel

switch(ele_pps{1})
    case {'edit'}
        switch(ele_pps{2})
            case {'num_short'}
                switch judge
                    case ''
                        sub_eles = {'edit'};
                    otherwise
                        sub_eles = {'text', 'edit'};
                end
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, numeric_size];
                block_shift = -1 * (text_size(2) + 10);
            case 'view'
                sub_eles = {'popupmenu', 'text', 'edit', 'text', 'edit'};
                pos_shift = [   0,                  -5, pop_size;...
                                pop_size(1) + 5,-5, text_size(1) - 25, text_size(2)+5;...
                                text_size(1) + pop_size(1) - 28,   -5, text_size(1) - 25, text_size(2)+5;...
                                text_size(1)*2 + pop_size(1)-45, -5, text_size(1) - 25, text_size(2)+5;...
                                text_size(1)*3 + pop_size(1)-80,-5, text_size(1) - 25, text_size(2)+5];
                block_shift = -1 * (text_size(2) + 10);
            case 'text_color'
                sub_eles = {'text', 'text_color', 'text', 'text_color'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, pushbtn_size;...
                                disp_size(1) / 2,   0, text_size;...
                                disp_size(1) / 2 + text_size(1) + 5,0, pushbtn_size];
                block_shift = -1 * (text_size(2) + 10);
            case {'num_short_infos'}
                sub_eles = {'text', 'edit', 'text'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5, 0, numeric_size;...
                                text_size(1) + 5 + numeric_size(1) + 5, 0, info_size];
                block_shift = -1 * (text_size(2) + 10);
            case 'str_short'
                sub_eles = {'text', 'edit'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,   0, numeric_size];
                block_shift = -1 * (text_size(2) + 10);
            case {'str_dir', 'str_img', 'str_txt'}
                sub_eles = {'text', 'edit', 'pushbtn'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, edit_size;...
                                disp_size(1) - 15,  0, pushbtn_size];
                block_shift = -1 * (text_size(2) + 10);
            case {'num_vec', 'str_long'}
                sub_eles = {'text', 'edit'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, edit_size];
                block_shift = -1 * (text_size(2) + 10);
            case 'str_long_btn'
                sub_eles = {'text', 'edit', 'pushbtn'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, edit_size;...
                                disp_size(1) - 15,  0, pushbtn_size];
                block_shift = -1 * (text_size(2) + 10);
            case 'num_short_btn'
                sub_eles = {'text', 'edit', 'pushbtn'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, numeric_size;...
                                disp_size(1) - 15,  0, pushbtn_size];
                block_shift = -1 * (text_size(2) + 10);
            case {'disp_dirs', 'disp_files', 'disp_dirs_txt'}
                sub_eles = {'text', 'edit', 'pushbtn', 'disp'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,   0, edit_size;...
                                disp_size(1) - 15,  0, pushbtn_size;...
                                0, - 10 - disp_size(2), disp_size];
                block_shift = -1 * (disp_size(2) + 10 + text_size(2) + 10);
        end     
    case 'chb'
        switch(ele_pps{2})
            case {'num_bin'}
                sub_eles = {'checkbox'};
                pos_shift = [   0,                  0, text_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
            case 'num_short'
                sub_eles = {'checkbox', 'edit'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 50,   0, numeric_size;...
                                text_size(1) + 5 + numeric_size(1) + 5, 0, info_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
            case 'num_bin_edit_text'
                sub_eles = {'checkbox', 'edit', 'text'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,   0, numeric_size;...
                                text_size(1) + 5 + numeric_size(1) + 5, 0, info_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
        end
    case 'radio'
        switch(ele_pps{2})
            case {'horizontal_txt'}
                sub_eles = {'text', 'radio'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, numeric_size;...
                                text_size(1) + 5 + edit_size(1) / 2,0, numeric_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
            case {'horizontal'}
                sub_eles = {'radio'};
                pos_shift = [   0,                  0, text_size;...
                                text_size(1) + 5,0, numeric_size;...
                                text_size(1) + 5 + edit_size(1) / 2,0, numeric_size];
                block_shift = -1 * (text_size(2) + 10 + 1);
            case {'vertical'}
                sub_eles = {'radio'};
                pos_shift = [   0,                  0, text_size;...
                                0, 0, numeric_size;...                                
                                0, -1 * (text_size(2) + 10 + 1), numeric_size];
                block_shift = -2 * (text_size(2) + 10 + 1);
            case {'vertical_color'}
                sub_eles = {'radio', 'text_color', 'popupmenu', 'text_color'};
                pos_shift = [   0,                  0, text_size;...
                                0, 0, numeric_size;...                                
                                0, -1 * (text_size(2) + 10 + 1), numeric_size;...
                                disp_size(1) - 15, 0, pushbtn_size;...
                                text_size(1) + 5 + edit_size(1) - 50, -1 * (text_size(2) + 10 + 1), 50, popupmenu_height - (popupmenu_height - edit_size(2)) / 2;...
                                disp_size(1) - 15, -1 * (text_size(2) + 10 + 1), pushbtn_size];
                block_shift = -2 * (text_size(2) + 10 + 1);
            case {'vertical_color_pn'}
                sub_eles = {'radio', 'text_color', 'text_color'};
                pos_shift = [   0,                  0, text_size;...
                                0, 0, numeric_size;...                                
                                0, -1 * (text_size(2) + 10 + 1), numeric_size;...
                                disp_size(1) - 15, 0, pushbtn_size;...
                                disp_size(1) - 15, -1 * (text_size(2) + 10 + 1), pushbtn_size];
                block_shift = -2 * (text_size(2) + 10 + 1);
        end
    case 'seperator'
        switch(ele_pps{2})
            case {'str'}
                sub_eles = {'text'};
                pos_shift = [ 0, 0, disp_size(1), edit_size(2) ];
                block_shift = -1 * (edit_size(2) + 10);
        end
    case 'pop'
        switch(ele_pps{2})
            case {'num3_6_18_27'}
                sub_eles = {'text', 'popupmenu'};
                pos_shift = [ 0,                  0, text_size;...
                            text_size(1) + 5,0, numeric_size(1), popupmenu_height - (popupmenu_height - edit_size(2)) / 2];
                block_shift = -1 * (edit_size(2) + 10);
        end
end

function pos = create_elements(h_fig, prompt, pos, sub_field) % create functional elements

jobman = get(h_fig, 'Userdata');   %#ok<*NASGU> % do not mask this line! YOU SHALL NOT PASS!
figColor = [0.94 0.94 0.94];

for m = 1:size(prompt, 1)
    
    [sub_eles, pos_shift, block_shift] = sub_elements(prompt{m, 1}, prompt{m, 4});
    ele_pps = regexp(prompt{m, 1}, '\w+', 'match');
    if ~strcmp(sub_field, 'jobman')
        ui_field = [sub_field, '.', prompt{m, 2}];
    else
        ui_field = prompt{m, 2};
    end
    
    if ~isempty(strfind(prompt{m, 1}, 'disp')) && isstruct(prompt{m, 3})
        edit_str = eval(['jobman.', ui_field, '.inputfile']);
        disp_str = eval(['jobman.', ui_field, '.subjs']);
    else
        edit_str = prompt{m, 3};
        disp_str = '';
    end
    
    get_radio = 1;
    cnt_text = 1;
    for n = 1:numel(sub_eles)
        switch(sub_eles{n})
            case 'text'
                txt_strs = textscan(prompt{m, 4}, '%s', 'delimiter', ':');
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               txt_strs{1}{cnt_text},...
                    'Position',             pos_shift(n, :) + [pos, 0, 0],...
                    'Style',                'text',...
                    'Tag',                  [prompt{m, 2}, '_', sub_eles{n}],...
                    'Userdata',             ui_field,...
                    'HorizontalAlignment',  'Left',...
                    'BackgroundColor',      figColor);
                cnt_text = cnt_text + 1;
            case 'text_color'
                sub_text_color = regexp(prompt{m , 2}, '\w+', 'match');
                sub_text_handle = findobj(h_fig, 'Tag', [sub_text_color{1, 1}, '_', sub_eles{n}]);
                if isempty(sub_text_handle)
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               '',...
                    'Position',             pos_shift(n + get_radio - 1, :) + [pos, 0, 0],...
                    'Style',                'text',...
                    'Tag',                  [sub_text_color{1, 1}, '_', sub_eles{n}],...
                    'Userdata',             ui_field,...
                    'HorizontalAlignment',  'Left',...
                    'BackgroundColor',      [1 0 0],...
                    'ButtonDownFcn',        @setcolor_cb);
                else
                    uicontrol(...
                    'Parent',               h_fig,...
                    'String',               '',...
                    'Position',             pos_shift(n + get_radio - 1, :) + [pos, 0, 0],...
                    'Style',                'text',...
                    'Tag',                  [sub_text_color{1, 2}, '_', sub_eles{n}],...
                    'Userdata',             ui_field,...
                    'HorizontalAlignment',  'Left',...
                    'BackgroundColor',      [1 0 0],...
                    'ButtonDownFcn',        @setcolor_cb);
                end
                
                
                cnt_text = cnt_text + 1;
            case 'edit'
                if n > 1                                       
                    if strcmp(sub_eles{n - 1}, 'checkbox')
                        edit_str = prompt{m, 3}(n);
                    elseif strcmp(sub_eles{1}, 'popupmenu')
                        edit_str = 0;                        
                    end
                end
                sub_tag = regexp(prompt{m, 2}, '\w+', 'match');
                if numel(sub_tag)>1
                    ui_tag = sub_tag{2};
                    ui_field = sub_tag{2};
                else
                    ui_tag = prompt{m, 2};
                end
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               edit_str,...
                    'UserData',             ui_field,...
                    'Tag',                  [ui_tag, '_', sub_eles{n}],...
                    'Position',             pos_shift(n, :) + [pos, 0, 0],...
                    'Style',                'edit',...
                    'HorizontalAlignment',  'left',...
                    'BackgroundColor',      [1, 1, 1],...
                    'Callback',             {@edit_cb, ele_pps{2}});                                                        
            case 'popupmenu'
                pop_tag = regexp(prompt{m, 2}, '\w+', 'match');
                num = size(pop_tag, 2);
                field = regexp(ui_field, '\w+', 'match');
                num_field = size(field, 2);
                if num_field == 2
                    ui_field = field{2};
                end
                switch num
                    case 2
                        uicontrol(...
                            'Parent',               h_fig,...
                            'String',               prompt{m, 3},...
                            'UserData',             ui_field,...
                            'Tag',                  [pop_tag{2}, '_pop'],...
                            'Value',                1,...
                            'Position',             pos_shift(n + get_radio - 1, :) + [pos, 0, 0],...
                            'Style',                'popupmenu',...
                            'HorizontalAlignment',  'left',...
                            'BackgroundColor',      [1 1 1],...
                            'Callback',             {@popupmenu_cb, ele_pps{2}});
                    otherwise
                        uicontrol(...
                            'Parent',               h_fig,...
                            'String',               prompt{m, 3},...
                            'UserData',             ui_field,...
                            'Tag',                  [pop_tag{1}, '_pop'],...
                            'Value',                1,...
                            'Position',             pos_shift(n + get_radio - 1, :) + [pos, 0, 0],...
                            'Style',                'popupmenu',...
                            'HorizontalAlignment',  'left',...
                            'BackgroundColor',      [1 1 1],...
                            'Callback',             {@popupmenu_cb, ele_pps{2}});
                end
            case 'pushbtn'
                if strcmp(prompt{m, 2}, 'threshold_str')
                    str = '?';
                else
                    str = '...';
                end
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               str,...
                    'UserData',             ui_field,...
                    'Tag',                  [prompt{m, 2}, '_', sub_eles{n}],...
                    'Position',             pos_shift(n, :) + [pos, 0, 0],...
                    'Style',                'pushbutton',...
                    'BackgroundColor',      figColor,...
                    'Callback',             {@input_cb, ele_pps{2}});
            case 'checkbox'
                chb_strs = textscan(prompt{m, 4}, '%s', 'delimiter', ':');
                len_label = strlen_table(chb_strs{1}{cnt_text});
                if isvector(prompt{m, 3})
                    val = prompt{m, 3}(1);
                else
                    val = prompt{m, 3};
                end
                sub_tag = regexp(prompt{m, 2}, '\w+', 'match');
                if numel(sub_tag) > 1
                    ui_tag = sub_tag{1};
                    ui_field = sub_tag{1};
                else
                    ui_tag = prompt{m, 2};
                end
                uicontrol(...
                    'Parent',               h_fig,...
                    'String',               prompt{m, 4},...
                    'Position',             [pos, len_label, pos_shift(n, 4) + 1],...
                    'Tag',                  [ui_tag, '_', sub_eles{n}],...
                    'Userdata',             ui_field,...
                    'Style',                'checkbox',...
                    'Value',                val,...
                    'BackgroundColor',      figColor,...
                    'Callback',             {@chb_cb, ele_pps{2}});
                cnt_text = cnt_text + 1;
            case 'radio'
                radio_tags = regexp(prompt{m, 2}, '\w+', 'match');
                radio_btns = textscan(prompt{m, 4}, '%s', 'delimiter', ':');
                radio_btns = radio_btns{1};
%                 radio_btns = textscan(prompt{m, 4}, '%s', 'delimiter', ':');
                for o = 2:numel(radio_btns)
                    len_label = strlen_table(radio_btns{o});
                    uicontrol(...
                        'Parent',               h_fig,...
                        'String',               radio_btns{o},...
                        'Position',             [pos + pos_shift(o, 1:2), len_label, pos_shift(o, 4) + 1],...
                        'Tag',                  radio_tags{o - 1},...
                        'Style',                'radiobutton',...
                        'Value',                prompt{m, 3}(o - 1),...
                        'BackgroundColor',      figColor,...
                        'Userdata',             [sub_field, '.', radio_tags{o - 1}],...
                        'Callback',             {@radio_cb, radio_tags, 'asign'});
                end
                get_radio = numel(radio_btns);
            case 'disp'
                % display directories
                h_disp = uicontrol(...
                    'Parent',       h_fig,...
                    'Style',        'edit',...
                    'Position',     pos_shift(n, :) + [pos, 0, 0],...
                    'string',       disp_str,...
                    'Tag',          [prompt{m, 2}, '_', sub_eles{n}],...
                    'Userdata',     ui_field,...
                    'Horiz',        'left',...
                    'Value',        1,...
                    'Min',          1,...
                    'Max',          3,...
                    'Enable',       'on');

                % enable horizontal scrolling
                try
                    jEdit1 = findjobj(h_disp);
                    jEditbox1 = jEdit1.getViewport().getComponent(0);
                    jEditbox1.setWrapping(false);                % turn off word-wrapping
                    jEditbox1.setEditable(false);                % non-editable
                    set(jEdit1,'HorizontalScrollBarPolicy',30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
                catch
                end
        end
    end
    pos(2) = pos(2) + block_shift;
    
    if ~isempty(strfind(prompt{m, 1}, 'radio'))
        struct_tags = regexp(prompt{m, 2}, '\w+', 'match');
        curr_tag = struct_tags{find(prompt{m, 3})};
        prompt_sub = brant_postprocess_parameters(curr_tag); %#ok<*FNDSB>
        if ~isempty(prompt_sub)
            pos = create_elements(h_fig, prompt_sub, pos, [curr_tag, '_struc']);
        end
    end

end
h_angle = findobj(0, 'Tag', 'select_view_edit');
set(h_angle, 'Enable', 'inactive')
h_node_size = findobj(0, 'Tag', 'node_size_edit');
set(h_node_size, 'Enable', 'inactive')
h_pop_view = findobj(0, 'Tag', 'select_view_pop');
set(h_pop_view, 'String', {'-select view-'; 'left lateral'; 'left medial'; 'right lateral'; 'right medial'; 'lateral and medial'}, 'FontSize', 8)


function chb_cb(obj, evd, mode)
h_parent = get(obj,'Parent');
val = get(obj, 'Value');
h_edit = findobj(h_parent, 'Tag', 'node_size_edit');
val_node_size = get(findobj(h_parent, 'Tag', 'node_size_eq_checkbox'), 'Value');
switch val_node_size
    case 0

        set(h_edit, 'Enable', 'inactive')
    case 1
        set(h_edit, 'Enable', 'on')
end
jobman = get(h_parent, 'Userdata');
h_size = findobj(h_parent, 'Tag', 'node_size_edit');
field_size = get(h_size, 'Userdata');
node_val = (get(h_size, 'String'));
jobman.(field_size) = str2num(node_val);
curr_field = get(obj, 'Userdata');

jobman.(curr_field) = val;
set(h_parent, 'Userdata', jobman);

function setcolor_cb(obj, evd)
h_parent = get(obj, 'Parent');
jobman = get(h_parent, 'Userdata');
h_module_color = findobj(h_parent, 'Tag', 'node_module_pop');
h_node_module = findobj(h_parent, 'Tag', 'node_module');
val_node_module = get(h_node_module, 'Value');
tag_name = get(obj, 'Tag');
h_obj = gco;
post_c = get(gco, 'BackgroundColor');
c = uisetcolor(post_c, 'Set Color');
set(h_obj, 'BackgroundColor', c)
if val_node_module == 1
    val = get(h_module_color, 'Value');
    jobman.node_module_color{val} = get(findobj(h_parent, 'Tag', 'node_module_text_color'), 'BackgroundColor');
end
set(h_parent, 'Userdata', jobman)


% set(h_parent, 'Userdata', jobman)

function popupmenu_cb(obj, evd, mode)
h_parent = get(obj,'Parent');
val = get(obj, 'Value');
curr_field = get(obj, 'Userdata');
opts = get(obj, 'String');

if strcmp(mode, 'reset')
    h_module_color = findobj(h_parent, 'Tag', 'node_module_text_color');
    h_node_color = findobj(h_parent, 'Tag', 'node_same_color_text_color');
    h_module = findobj(h_parent, 'Tag', 'node_module_pop');
    set(h_module_color, 'BackgroundColor', [1 0 0])
    set(h_node_color, 'BackgroundColor', [1 0 0])
    set(h_module, 'Value', 1)
    set(h_module, 'String', {'1', '0'})
else
    jobman = get(h_parent, 'Userdata');
    if isfield(jobman, 'node_module_color') == 1
        h_module_color = findobj(h_parent, 'Tag', 'node_module_text_color');
        h_module = findobj(h_parent, 'Tag', 'node_module_pop');
        color_val = get(h_module, 'Value');
%         module_color = get(h_module_color, 'BackgroundColor');
        if size(jobman.node_module_color{color_val}, 2) ~= 3
            set(h_module_color, 'BackgroundColor', [1 1 1]);
%         for i = 1: size(jobman.node_module_color, 1)
%             color_num(i) = ~isempty(jobman.node_module_color{i});
%         end
%         if sum(color_num) < size(jobman.node_module_color, 1)
%             jobman.node_module_color{color_val} = module_color;
        else
%         elseif sum(color_num) == size(jobman.node_module_color, 1)
            set(h_module_color, 'BackgroundColor', jobman.node_module_color{color_val});
%         end
        end
    end
        h_view_pop = findobj(h_parent, 'Tag', 'select_view_pop');
        view_val = get(h_view_pop, 'Value');
        jobman.select_view = view_val;
        set(h_parent, 'Userdata', jobman);
end

function radio_cb(obj, evd, btns, mode) %#ok<*INUSD>
h_parent = get(obj,'Parent');

set(obj, 'Value', 1);
self_btn = get(obj, 'Tag');
curr_field = get(obj, 'Userdata');

    

if strcmp(mode, 'reset')
    jobman = get(findobj(h_parent, 'String', 'reset', 'Style', 'pushbutton'), 'Userdata');
else
    jobman = get(h_parent, 'Userdata');
end
switch self_btn
    case 'whole_brain'
        h_angle = findobj(0, 'Tag', 'select_view_edit');
        set(h_angle, 'Enable', 'on')
        h_pop_view = findobj(0, 'Tag', 'select_view_pop');
        set(h_pop_view, 'String', {'-select view-';'left'; 'right'; 'axial'; 'coronal'; 'custom'}, 'FontSize', 8)
    case 'brain_halves'
        h_angle = findobj(0, 'Tag', 'select_view_edit');
        set(h_angle, 'Enable', 'inactive')
        h_pop_view = findobj(0, 'Tag', 'select_view_pop');
        set(h_pop_view, 'String', {'-select view-';'left lateral'; 'left medial'; 'right lateral'; 'right medial'; 'lateral and medial'}, 'FontSize', 8)
end
if strcmp(self_btn, 'brain_halves') || strcmp(self_btn, 'whole_brain')
    set(findobj(0, 'Tag', 'select_view_pop'), 'Value', 2)
    jobman.select_view = get(findobj(0, 'Tag', 'select_view_pop'), 'value');
end

            
        

if numel(btns) > 0
    for m = 1:numel(btns)
        if ~strcmpi(btns{m}, self_btn)
            set(findobj(h_parent, 'Tag', lower(btns{m}), 'Style', 'radiobutton'), 'Value', 0);
            jobman.(btns{m}) = 0;

            if jobman.(self_btn) ~= 1 || strcmp(mode, 'reset')

                jobman.(self_btn) = 1;
                prompt = brant_postprocess_parameters(btns{m});
                if ~isempty(prompt)
                    for n = 1:size(prompt, 1)
                        ele_name = regexp(prompt{n, 2}, '\:', 'split');
                        for nn = 1:numel(ele_name)
                            pos{n} = delete_elements(h_parent, prompt{n, 1}, ele_name{nn}, [btns{m}, '_struc']);
                        end
                    end
                    if ~isempty(pos{1})
                        prompt = brant_postprocess_parameters(self_btn);
                        for n = 1:size(prompt, 1)
                            prompt{n, 3} = jobman.([self_btn, '_struc']).(prompt{n, 2});
                        end
                        create_elements(h_parent, prompt, pos{1}(1:2), [self_btn, '_struc']);
                    end
                end
            else
                prompt = brant_postprocess_parameters(self_btn);

                for n = 1:size(prompt, 1)
                    ele_name = regexp(prompt{n, 2}, '\:', 'split');
                    ele_type = regexp(prompt{n, 1}, '\:', 'split');
                    for nn = 1:numel(ele_name)
                        val_tmp = eval([curr_field, '_struc.', ele_name{nn}]);
                        if isstruct(val_tmp)
                            obj_edit = findobj(h_parent, 'Tag', [prompt{n, 2}, '_edit']);
                            obj_disp = findobj(h_parent, 'Tag', [prompt{n, 2}, '_disp']);
                            set(obj_edit, 'String', val_tmp.inputfile);
                            set(obj_edit, 'String', val_tmp.subjs);
                        else
                            obj_tmp = findobj(h_parent, 'Tag', [prompt{n, 2}, '_', ele_type{1}]);
                            set(obj_tmp, 'String', val_tmp);
                        end
                    end
                end
            end
        end
    end
end



h_node_module = findobj(h_parent, 'Tag', 'node_module');
val_node_module = get(h_node_module, 'Value');
h_module_pop = findobj(0, 'Tag', 'node_module_pop');
h_module_color = findobj(0, 'Tag', 'node_module_text_color');
switch val_node_module
    case 0        
        set(h_module_pop, 'Enable', 'inactive')        
    case 1        
        set(h_module_pop, 'Enable', 'on')
        if ~isempty(jobman.node)
            [node, label] = load_node(jobman.node);
            row_num = size(node, 2);
            if row_num<=4
                error('Please add a row customing node modules.')
            else
                value = max(node(:, 5));
                
                str = cell(value, 1);
                for i = 1: value
                    str{i} = eval(['''',['m' num2str(i)], '''']);
                end
                set(h_module_pop, 'string', str)
            end
            field = fields(jobman);
            temp = strcmp(field, 'node_module_color');
            if sum(temp) == 0
                jobman.node_module_color = cell(value, 1);
            end
        end
end

set(h_parent, 'Userdata', jobman);
               
function pos = delete_elements(h_parent, ele_type, ele_name, curr_field)
[sub_eles, pos_shift, block_shift] = sub_elements(ele_type); %#ok<*ASGLU>
for m = 1:numel(sub_eles)
    h_tmp = findobj(h_parent, 'Tag', [ele_name, '_', sub_eles{m}], 'Userdata', [curr_field, '.', ele_name]);
    
    if ~isempty(h_tmp)
        if m == 1
            pos = get(h_tmp, 'Position');
        end
        delete(h_tmp);
    else
        pos = '';
    end
end

function input_cb(obj, evd, mode)
h_parent = get(obj, 'Parent');
field_name = get(obj, 'Userdata');
tmp_pos = strfind(field_name, '.');
if ~isempty(tmp_pos)
    tag_name = field_name(tmp_pos(end)+1:end);
else
    tag_name = field_name;
end
obj_edit = findobj(h_parent, 'Tag', [tag_name, '_edit']);

switch(mode)
    case 'str_img'
        brant_tmp = fullfile(fileparts(which('brant')), 'template');
        [filename, pathname] = uigetfile({'*.nii;*.img', 'image files(*.nii, *.img)'}, 'Select a file', ['', brant_tmp, '']);
        if ~isnumeric(filename) % cancel pressed
            tmp_file = fullfile(pathname, filename);
            set(obj_edit, 'String', tmp_file);
        end
    case {'str_dir', 'disp_files'}
        folder_name = uigetdir;
        if ~isnumeric(folder_name)
            set(obj_edit, 'String', folder_name);
        end
    case {'disp_dirs', 'disp_dirs_txt', 'str_txt'}
        [filename, pathname] = uigetfile({'*.txt', 'txt file'});
        if ~isnumeric(filename)
            tmp_file = fullfile(pathname, filename);
            set(obj_edit, 'String', tmp_file);
        end
    case 'str_long_btn'
        h_help = helpdlg({'edge < 0.5 && edge > 0.1'; 'edge > 0.5 || edge < -0.5'}, 'Matlab Syntax');
        
end
edit_cb(obj_edit, evd, mode)

function s = setsubfield(s, fields, val)

if ischar(fields)
    fields = regexp(fields, '\.', 'split'); % split into cell array of sub-fields
end

if length(fields) == 1
    s.(fields{1}) = val;
else
    try
        subfield = s.(fields{1}); % see if subfield already exists
    catch
        subfield = struct([]); % if not, create it
    end
    s.(fields{1}) = setsubfield(subfield, fields(2:end), val);
end

function [obj_edit, obj_disp] = get_linked_obj(h_parent, field_name)

switch(field_name)
    case 'roi_filetype'
        obj_edit = findobj(h_parent, 'Tag', 'roi_list_edit', 'Userdata', field_name);
        obj_disp = findobj(h_parent, 'Tag', 'roi_list_disp', 'Userdata', field_name);
    case 'filetype'
        obj_edit = findobj(h_parent, 'Tag', 'subj_list_edit', 'Userdata', field_name);
        obj_disp = findobj(h_parent, 'Tag', 'subj_list_disp', 'Userdata', field_name);
end

function edit_cb(obj, evd, mode) %#ok<*INUSL>
h_parent = get(obj, 'Parent');
jobman = get(h_parent, 'Userdata');

field_name = get(obj, 'Userdata');
str = get(obj, 'String');

switch(mode)
    case {'str_long', 'str_dir', 'str_short', 'str_txt'}%%%
        jobman = setsubfield(jobman, field_name, str);
    case {'num_short', 'num_short_infos'}
        if ~isempty(str)
            num = str2num(str);
            if ~isempty(num)
                jobman = setsubfield(jobman, field_name, num);
            else
                num_str = eval(['jobman.', field_name]);
                set(obj, 'String', num2str(num_str));
                errordlg('Please enter a number !');
                return;
            end
        else
            jobman = setsubfield(jobman, field_name, str);
        end
    case 'num_vec'
        if ~isempty(str)
            num = str2num(str);
            if ~isempty(num)
                jobman = setsubfield(jobman, field_name, str);
            else
                num_str = eval(['jobman.', field_name]);
                set(obj, 'String', num_str);
                errordlg('Please enter a valid vector or matrix seperated by '';''');
                return;
            end
        else
            jobman = setsubfield(jobman, field_name, str);
        end
    case 'str_img'
        if ~isempty(str)
            if exist(str, 'file') == 2
                jobman = setsubfield(jobman, field_name, str);
            else
                str = eval(['jobman.', field_name]);
                set(obj, 'String', str);
                errordlg(sprintf('File %s not found!', str));
                return;
            end
        else
            jobman = setsubfield(jobman, field_name, str);
        end
    case{'disp_dirs', 'disp_dirs_txt'}
        if ~isempty(str)
            if exist(str, 'file') == 2
                fid = fopen(str, 'rt');
                C = textscan(fid, '%s', 'delimiter', '\n');
                fclose(fid);
                C_tmp = strtrim(C{1});
                cnt = 1;
                for n = 1:numel(C_tmp)
                    if ~isempty(C_tmp{n})
                        subjs{cnt} = C_tmp{n};
                        cnt = cnt + 1;
                    end
                end
                for n = 1:numel(subjs)
                    if strcmp(mode, 'disp_dirs')
                        if exist(subjs{n}, 'dir') ~= 7
                            str_tmp = eval(['jobman.', field_name, '.inputfile']);
                            set(obj, 'String', str_tmp);
                            errordlg(sprintf('Not a valid folder %s!', subjs{n}));
                            return;
                        end
                    elseif strcmp(mode, 'disp_dirs_txt')
                        if exist(subjs{n}, 'file') ~= 2
                            
                            str_tmp = eval(['jobman.', field_name, '.inputfile']);
                            set(obj, 'String', str_tmp);
                            errordlg(sprintf('Subject description files in %s not found!', str));
                            return;
                        end
                    else
                        if exist(subjs{n}, 'file') ~= 2
                            set(obj, 'String', jobman.(field_name).inputfile);
                            errordlg(sprintf('File %s not found!', str));
                            return;
                        end
                    end
                end
                jobman = setsubfield(jobman, [field_name, '.inputfile'], str);
                jobman = setsubfield(jobman, [field_name, '.subjs'], subjs);
                
                disp_tag = regexp(field_name, '\.', 'split');
                set(findobj(h_parent, 'Tag', [disp_tag{end}, '_disp']), 'String', subjs);
            else
                str_tmp = eval(['jobman.', field_name, '.inputfile']);
                set(obj, 'String', str_tmp);
                errordlg(sprintf('File %s not found!', str));
                return;
            end
        else
            jobman = setsubfield(jobman, [field_name, '.inputfile'], str);
            jobman = setsubfield(jobman, [field_name, '.subjs'], '');
            
            disp_tag = regexp(field_name, '\.', 'split');
            set(findobj(h_parent, 'Tag', [disp_tag{end}, '_disp']), 'String', '');
        end
    case 'disp_files'
        if ~isempty(str)
            if exist(str, 'dir') == 7
                rois = dir(fullfile(str, jobman.roi_filetype));
                if numel(rois) ~= 0
                    jobman = setsubfield(jobman, [field_name, '.inputfile'], str);
                    
                    subj_tmp = cell(numel(rois), 1);
                    for n = 1:numel(rois)
                        subj_tmp{n} = fullfile(str, rois(n).name);
                    end
                    set(findobj(h_parent, 'Tag', [field_name, '_disp']), 'String', subj_tmp);
                    jobman = setsubfield(jobman, [field_name, '.subjs'], subj_tmp);
                else
                    str_tmp = eval(['jobman.', field_name, '.inputfile']);
                    set(obj, 'String', str_tmp);
                    errordlg(sprintf('No roi file of %s are found in %s!', jobman.roi_filetype, str));
                    return;
                end
            else
                str_tmp = eval(['jobman.', field_name, '.inputfile']);
                set(obj, 'String', str_tmp);
                errordlg(sprintf('File %s not found!', str));
                return;
            end
        else
            jobman = setsubfield(jobman, [field_name, '.inputfile'], str);
            jobman = setsubfield(jobman, [field_name, '.subjs'], '');
            
            disp_tag = regexp(field_name, '\.', 'split');
            set(findobj(h_parent, 'Tag', [disp_tag{end}, '_disp']), 'String', '');
        end
end
set(h_parent, 'Userdata', jobman);

function load_cb(obj, evd)

[filename, pathname] = uigetfile({'*.mat', 'mat file'});

if filename ~= 0
    jobman_load = load(fullfile(pathname, filename));
    dlg_title = get(obj, 'Tag');
    if strcmpi(jobman_load.jobman.dlg_title, dlg_title)
        new_jobman = rmfield(jobman_load.jobman, {'dlg_title', 'subj_infos'});   

        h_parent = get(obj, 'Parent');
        h_reset = findobj(h_parent, 'String', 'reset');
        jobman_raw = get(h_reset, 'Userdata');
        set(h_reset, 'Userdata', new_jobman);
        reset_cb(h_reset, '');
        set(h_reset, 'Userdata', jobman_raw);
    else
        errordlg('Loaded .mat file doesn''t match with current operations!')
        return;
    end
end


function reset_cb(obj, evd)
h_parent = get(obj, 'Parent');
dlg_title = get(h_parent, 'Name');
jobman = get(obj, 'Userdata');
set(h_parent, 'Userdata', jobman);  % don't put this line in the end

prompt = brant_postprocess_parameters(dlg_title);

for m = 1:size(prompt, 1)
    if ~isempty(prompt{m, 2})
        ui_tag = regexp(prompt{m, 2}, '\:', 'split');
        ui_type = regexp(prompt{m, 1}, '\:', 'split');
        switch(ui_type{1})
            case 'radio'
                radio_tags = regexp(prompt{m, 2}, '\w+', 'match');
                for n = 1:numel(radio_tags)
                    h_ui = findobj(h_parent, 'Tag', ui_tag{n}, 'Style', 'radiobutton');
                    if eval(get(h_ui, 'Userdata')) == 1
                        radio_cb(h_ui, '', radio_tags, 'reset');
                        break;
                    end
                end
                if strcmp(ui_type{2}, 'vertical_color')
                    h_pop = findobj(h_parent, 'Tag', 'node_module_pop', 'Style', 'popupmenu');
                    popupmenu_cb(h_pop, '','reset')
                end
            case 'edit'
                if ~isempty(strfind(ui_type{2}, 'disp'))
                    h_edit = findobj(h_parent, 'Tag', [ui_tag{end}, '_edit'], 'Style', 'edit');
                    h_disp = findobj(h_parent, 'Tag', [ui_tag{end}, '_disp'], 'Style', 'edit');
                    val_edit = eval(['jobman.', get(h_edit, 'Userdata'), '.inputfile']);
                    val_disp = eval(['jobman.', get(h_disp, 'Userdata'), '.subjs']);
                    set(h_edit, 'String', val_edit);
                    set(h_disp, 'String', val_disp);
                elseif strcmp(ui_type{2}, 'view')
                    h_pop = findobj(h_parent, 'Tag', [ui_tag{end}, '_pop'], 'Style', 'popupmenu');
                    val_tmp = eval(['jobman.', get(h_pop, 'Userdata')]);
                    h_edit = findobj(h_parent, 'Tag', [ui_tag{end}, '_edit'], 'Style', 'edit');
                    if numel(h_edit) ~= 1
                        for i = 1: numel(h_edit)
                            
                            set(h_edit(i), 'String', '0');
                        end
                    end                                        
                    set(h_pop, 'Value', val_tmp); 
               elseif strcmp(ui_type{2}, 'text_color')
                    h_pos = findobj(h_parent, 'Tag', [ui_tag{1}, '_text_color'], 'Style', 'text');
                    
                    h_neg = findobj(h_parent, 'Tag', [ui_tag{end}, '_text_color'], 'Style', 'text');                                                          
                    set(h_pos, 'BackgroundColor', [1 0 0]);
                    set(h_neg, 'BackgroundColor', [1 0 0]);
                else
                    h_ui = findobj(h_parent, 'Tag', [ui_tag{end}, '_edit'], 'Style', 'edit');
                    val_tmp = eval(['jobman.', get(h_ui, 'Userdata')]);
                    if isnumeric(val_tmp)
                        val_tmp = num2str(val_tmp);
                    end
                    set(h_ui, 'String', val_tmp);
                end
            case 'chb'
                if numel(ui_tag) ~= 1
                    h_ui_chb = findobj(h_parent, 'Tag', [ui_tag{1}, '_checkbox'], 'Style', 'checkbox');
                    h_ui_edit = findobj(h_parent, 'Tag', [ui_tag{2}, '_edit'], 'Style', 'edit');
                    val_tmp = eval(['jobman.', get(h_ui_chb, 'Userdata')]);
                    set(h_ui_chb, 'Value', val_tmp);
                    val_edit = eval(['jobman.', get(h_ui_edit, 'Userdata')]);
                    set(h_ui_edit, 'String', val_edit);
                    set(h_ui_edit, 'Enable', 'inactive');
                else
                    h_ui = findobj(h_parent, 'Tag', [ui_tag{end}, '_checkbox'], 'Style', 'checkbox');
                    val_tmp = eval(['jobman.', get(h_ui, 'Userdata')]);
                    set(h_ui, 'Value', val_tmp);
                end
            case 'pop'
                h_ui = findobj(h_parent, 'Tag', [ui_tag{end}, '_pop'], 'Style', 'popupmenu');
                val_tmp = eval(['jobman.', get(h_ui, 'Userdata')]);
                opts = get(h_ui, 'String');
                for n = 1:numel(opts)
                    if strcmp(opts{n}, num2str(val_tmp))
                        set(h_ui, 'Value', n);
                        break;
                    end
                end
        end
    end
end

function run_cb(obj, evd)
h_parent = get(obj, 'Parent');
jobman = get(h_parent, 'Userdata');
dlg_title = get(h_parent, 'Name');

% jobman.subj_infos = brant_get_subjs(jobman, dlg_title);
jobman.dlg_title = dlg_title;

fn = lower(regexprep(dlg_title, '\W', '_'));

if isfield(jobman, 'out_dir')
    if isempty(jobman.out_dir)
        fprintf('Output directory is set to the current working directory!\n');
        save([pwd, filesep, 'brant_', fn, '.mat'], 'jobman');
    else
        save([jobman.out_dir, filesep, 'brant_', fn, '.mat'], 'jobman');
    end
% else
%     save(['brant_', fn, '.mat'], 'jobman');
end

switch(dlg_title)
    case 'Draw ROI'
        brant_draw_rois(jobman);
    case 'Head Motion Estimate'
        brant_hm_est(jobman);
    case 'TSNR'
        brant_tsnr(jobman);
    case 'Visual Check'
        brant_visual_check(jobman);
    case 'ROI - Whole Brain'
        brant_roi2wb(jobman);
    case 'ROI - ROI'
        brant_roi2roi(jobman);
    case 'AM'
        brant_am(jobman);
    case 'ALFF'
        brant_alff(jobman);
    case 'fGn'
        brant_fgn(jobman);
    case 'ReHo'
        brant_reho(jobman);
    case 'Dicom Convert'
        brant_dicom2nii(jobman);
    case 'Voxel Based'
        brant_statistics_vox(jobman)
    case 'Visual'
        brant_visual(jobman)
end

function close_window(obj, evd)
h_parent = get(obj,'Parent');
delete(h_parent);
