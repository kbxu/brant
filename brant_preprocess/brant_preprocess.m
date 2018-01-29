function brant_preprocess(varargin)

% Last modified 2013-09-30 15:00
if(nargin<1 || isempty(varargin{1}))
    varargin{1} = 'Init';
end

switch upper(varargin{1})
    case {'INIT', 'RELOAD'}, %#ok<*NOCOL> % initialization
        
        hPreprocess = findobj(0, 'Tag', 'brant_preprocess_main');
        if strcmpi(varargin{1}, 'init')
            brant_pps = brant_preprocess_defaults;
        else
            brant_pps = varargin{2}; % input paramters from brant_load_gui
            delete(hPreprocess);
        end                
        
        if isempty(hPreprocess) || ~ishandle(hPreprocess) % check valid
            % Version check
            if str2double(strtok(version,'.')) < 7
                error('The version of MATLAT mustn''t be lower than 7.0');
            end
            
            brant_preprocess_gui(brant_pps);
        else
            % newly edited on 20140219 begin
            brant_config_figure(hPreprocess, 'pixels');
            h_Pr_pos = get(hPreprocess, 'Position');
            [pos_fp, pos_cb] = brant_interface_pos(h_Pr_pos(3:4));
            set(hPreprocess, 'Position', pos_fp);
            brant_config_figure(hPreprocess, 'normalized');
            figure(hPreprocess);
            hCheckBoard = findobj(0,'Tag','brant_preprocess_check');
            if(strcmp(get(hCheckBoard,'Visible'),'on'))
                brant_config_figure(hCheckBoard, 'pixels');
                set(hCheckBoard, 'Position', pos_cb);
                brant_config_figure(hCheckBoard, 'normalized');
                figure(hCheckBoard);
            end
            % newly edited on 20140219 end
        end        
    case {'QUIT', 'CANCEL_BTN'}, % quit
        hPreprocess = findobj(0, 'Tag', 'brant_preprocess_main');
        hCheckBoard = findobj(0, 'Tag', 'brant_preprocess_check');
        hInput = findobj(0, 'Tag', 'figInput');
        
        if ishandle(hCheckBoard)
            delete(hCheckBoard);
        end
        
        if ishandle(hPreprocess)
            delete(hPreprocess);
        end
        
        if ishandle(hInput)
            delete(hInput);
        end
end

function rst_cb_fake(obj, evd)

h_data = get(gcf, 'Userdata');
processes = h_data.pref.order;
for n = 1:length(processes)
    set(findobj(gcf, 'Tag', [processes{n}, '_chb']), 'Value', 0);
    h_data.ind.(processes{n}) = 0;
end
set(findobj(gcf, 'Tag', 'run_btn'), 'Enable', 'on');
set(gcf, 'Userdata', h_data);
brant_update_pre_disp;

function dir_out_cb(obj, evd, h_fig) %#ok<*INUSL>
fig_opts = get(h_fig, 'Userdata');

h_infile = findobj(h_fig, 'Tag', 'dir_out_text_edit');
ui_type = get(obj, 'Style');

if strcmpi(ui_type, 'pushbutton')
    [dir_out, sts] = cfg_getfile(1, 'dir', 'Select data path(s)', {fig_opts.subj.out.dir}, pwd);
    if sts == 1
        fig_opts.subj.out.dir = dir_out{1};
        set(h_infile, 'String', dir_out{1});
        set(h_fig, 'Userdata', fig_opts);
    end
else
    dir_text = get(obj, 'String');
    if exist(dir_text, 'dir') ~= 7
        try
            mkdir(dir_text);
            fprintf('\tNew directory created %s\n', dir_text);
        catch err
            fig_opts.subj.out.dir = '';
            set(h_infile, 'String', '');
            set(h_fig, 'Userdata', fig_opts);
            rethrow(err);
        end
    end
    
    fig_opts.subj.out.dir = dir_text;
    set(h_fig, 'Userdata', fig_opts);
end

function dir_cb(obj, evd) %#ok<*INUSL>

h_fig = gcf;

h_chbd_chb = findobj(h_fig, 'Tag', 'chbd_chb');
fig_opts = get(h_fig, 'Userdata');
h_chbd = findobj(0, 'Tag', 'brant_preprocess_check');
h_dirs = findobj(h_chbd, 'Tag', 'dirboard_label_chbd');

if fig_opts.pref.dirs_in_text == 0
    [dir_paths, sts] = cfg_getfile(Inf, 'dir', 'Select data path(s)', fig_opts.subj.spm.dirs, pwd, '^[^.].*$');
    if sts == 1
        [ooo, in_index] = unique(dir_paths); %#ok<ASGLU>
        fig_opts.subj.spm.dirs = dir_paths(sort(in_index));
        set(h_dirs, 'String', fig_opts.subj.spm.dirs);
        set(h_fig, 'Userdata', fig_opts);
        set(h_chbd, 'Visible', 'on');
        set(h_chbd_chb, 'Value', 1);
    end
else
    if isempty(fig_opts.subj.text.inputfile)
        wd = pwd;
    else
        wd = fileparts(fig_opts.subj.text.inputfile);
    end
    
    [dir_text_tmp, sts] = cfg_getfile(1, 'any', 'Select a text file', {fig_opts.subj.text.inputfile}, wd, '.*\.txt');
    if sts == 1
        dir_text = dir_text_tmp{1};
        
        fig_opts.subj.text.inputfile = dir_text;
        dirs_tmp = importdata(fig_opts.subj.text.inputfile, '\n');
        dirs_tmp = strtrim(dirs_tmp);
        dirs_ind = cellfun(@isempty, dirs_tmp);
        dir_paths = dirs_tmp(~dirs_ind);
        
        dirs_ind_valid = cellfun(@isdir, dirs_tmp);
        
        if all(dirs_ind_valid)
            fig_opts.subj.text.dirs = dir_paths;
            set(h_dirs, 'String', dir_paths);
            set(h_fig, 'Userdata', fig_opts);
            set(h_chbd, 'Visible', 'on');
            set(h_chbd_chb, 'Value', 1);
        else
            error_msgs = strcat('\t', ['Error: the following path(s) are not valid!'; dirs_tmp(~dirs_ind_valid)], '\n');
            error(sprintf([error_msgs{:}])); %#ok<SPERR>
        end
    end
end

function spm12_norm_chb_cb(obj, evd)

h_fig = gcf;
obj_val = get(obj, 'Value');
fig_opts = get(h_fig, 'Userdata');

if fig_opts.pref.norm12_ind == 1
    win_str = 'normalise12';
else
    win_str = 'normalise';
end

h_win = findobj(0, 'Name', win_str);
if ~isempty(h_win)
    figure(h_win);
    set(obj, 'Value', fig_opts.pref.norm12_ind);
    return;
end

if obj_val == 1
    h_opt = findobj(h_fig, 'Tag', 'normalise_input');
    set(h_opt, 'Tag', 'normalise12_input');
    h_opt_chb = findobj(h_fig, 'Tag', 'normalise_chb');
    set(h_opt_chb, 'Tag', 'normalise12_chb');
    norm_ind = cellfun(@(x) strcmp(x, 'normalise') | strcmp(x, 'normalise12'), fig_opts.pref.order);
    fig_opts.pref.order{norm_ind} = 'normalise12';
    
    if get(h_opt_chb, 'Value') == 1
        fig_opts.ind.normalise = 0;
        fig_opts.ind.normalise12 = 1;
    end
    fig_opts.pref.norm12_ind = 1;
else
    h_opt = findobj(h_fig, 'Tag', 'normalise12_input');
    set(h_opt, 'Tag', 'normalise_input');
    h_opt_chb = findobj(h_fig, 'Tag', 'normalise12_chb');
    set(h_opt_chb, 'Tag', 'normalise_chb');
    norm_ind = cellfun(@(x) strcmp(x, 'normalise12') | strcmp(x, 'normalise'), fig_opts.pref.order);
    if any(norm_ind)
        fig_opts.pref.order{norm_ind} = 'normalise';
    end
    
    if get(h_opt_chb, 'Value') == 1
        fig_opts.ind.normalise = 1;
        fig_opts.ind.normalise12 = 0;
    end
    fig_opts.pref.norm12_ind = 0;
end

set(h_fig, 'Userdata', fig_opts);
brant_update_pre_disp;

function pre_chb_cb(obj, evd)

h_fig = gcf;
obj_tag = get(obj, 'Tag');
obj_val = get(obj, 'Value');
fig_opts = get(h_fig, 'Userdata');

str = obj_tag(1:end-4);
if ((strcmp(str, 'normalise') || strcmp(str, 'normalise12')) && (obj_val == 0))
    fig_opts.ind.normalise = 0;
    fig_opts.ind.normalise12 = 0;
else
    fig_opts.ind.(obj_tag(1:end-4)) = obj_val;
end

set(h_fig, 'Userdata', fig_opts);
brant_update_pre_disp;

function input_cb(obj, evd)

h_fig = gcf;
tag_input = get(obj, 'Tag');
func_name = tag_input(1:end - 6);

h_in = findobj(0, 'Tag', 'figInput');
% h_in = findobj(0, 'Name', func_name, 'Tag', 'figInput');
if ~isempty(h_in)
    figure(h_in);
else
    dlg_rstbtn = 0;
    data_fig = get(h_fig, 'Userdata');
    
    brant_config_figure(h_fig, 'pixel');
    [dlg_title, sub_title_field, prompt, defAns] = brant_preprocess_parameters(func_name, data_fig);
    brant_inputdlg_new(dlg_title, dlg_rstbtn, sub_title_field, prompt, defAns, func_name, h_fig);
    brant_config_figure(h_fig, 'Normalized');
end

function par_edit(obj, evd)
h_fig = gcf;
fig_opts = get(h_fig, 'Userdata');
par_val = get(obj, 'String');
try
    fig_opts.pref.parallel_workers = str2num(par_val);
    set(h_fig, 'Userdata', fig_opts);
catch
    set(obj, 'String', num2str(fig_opts.pref.parallel_workers));
end


function par_chb(obj, evd)
h_fig = gcf;
fig_opts = get(h_fig, 'Userdata');
par_val = get(obj, 'Value');
if par_val == 1
    fig_opts.pref.parallel = 'on';
else
    fig_opts.pref.parallel = 'off';
end
set(h_fig, 'Userdata', fig_opts);

function sys_chb(obj, evd)

h_fig = gcf;
fig_opts = get(h_fig, 'Userdata');

curr_tag = get(obj, 'Tag');
curr_val = get(obj, 'Value');
fig_opts.pref.(strrep(curr_tag, '_chb', '')) = curr_val;

if (strcmpi(curr_tag, 'sync') && (fig_opts.pref.sync == 1))
    fig_opts = brant_prep_sync(fig_opts, 'initial');
    brant_update_pre_disp;
end

set(h_fig, 'Userdata', fig_opts);

function chbd_cb(obj, evd, h_main) %#ok<*INUSD>

h_chbd = findobj(0, 'Tag', 'brant_preprocess_check');
brant_config_figure(h_chbd, 'pixels');

if strcmp(get(h_chbd, 'Visible'), 'on')
    set(h_chbd, 'Visible', 'off');
    set(obj, 'Value', 0);
else
    brant_config_figure(gcf, 'pixels');
    pos_fp = get(gcf, 'Position');
    brant_config_figure(gcf, 'Normalized');
    
    brant_config_figure(h_chbd, 'pixels');
    screensize = get(0, 'screensize');
    if (screensize(3) - pos_fp(1) - pos_fp(3) > pos_fp(3))
        pos_cb(1) = pos_fp(1) + pos_fp(3) + 16;
    else
        pos_cb(1) = pos_fp(1) - pos_fp(3) - 16;
    end
    set(h_chbd, 'Position', [pos_cb(1), pos_fp(2:4)]);
    figure(h_chbd);
    set(h_chbd, 'Visible', 'on');
    set(obj, 'Value', 1);
    brant_config_figure(h_chbd, 'normalized');
end

function close_chbd(obj, evd)

hCheckBoard = findobj(0,'Tag','brant_preprocess_check');
brant_config_figure(hCheckBoard, 'pixels');
set(hCheckBoard,'Visible','off');
hchbd = findobj(0,'Tag','chbd_chb');
set(hchbd,'Value',0);

function dir_text_cb_new(obj, evd, h_fig)

h_chbd = findobj(0, 'Tag', 'brant_preprocess_check');
h_dirs = findobj(h_chbd, 'Tag', 'dirboard_label_chbd');

fig_opts = get(h_fig, 'Userdata');

dir_in_text = get(obj, 'Value');

if dir_in_text == 0
    fig_opts.pref.dirs_in_text = 0;
    set(h_dirs, 'String', fig_opts.subj.spm.dirs);
else
    fig_opts.pref.dirs_in_text = 1;
    set(h_dirs, 'String', fig_opts.subj.text.dirs);
end

set(h_fig, 'Userdata', fig_opts);

function run_cb(obj, evd)

h_run_btn = obj;
jobman = get(gcf, 'Userdata');
set(h_run_btn, 'Enable', 'off');
brant_preprocess_jobman(jobman, gcf);
set(h_run_btn, 'Enable', 'on');
    
function disp_para_chbd_cb(obj, evd)
brant_update_pre_disp;

function h = brant_preprocess_gui(brant_pps)

set(0,'Units','pixels');    %Handles of main figure
figColor = 0.9 * [1 1 1];
uipColor = [0.925 0.914 0.847];
btn_bkgColor = [0.94 0.94 0.94];

[pos_fp, pos_cb] = brant_interface_pos([340, 511 + 25]); % newly added on 20140219

% brant_pps = brant_preprocess_defaults;
brant_pps_fig = brant_pps;
brant_pps_fig.subj.out.selected = 0;
% Create a new figure
h.fig_Preprocess = figure(...
    'IntegerHandle',    'off',...
    'Position',         pos_fp,...  % newly edited on 20140219
    'Color',            figColor,...
    ...'CloseRequestFcn',  [mfilename,'(''Quit'')'],...
    'DeleteFcn',        [mfilename,'(''Quit'')'],...
    'Name',             'brant_Preprocessing',...
    'NumberTitle',      'off',...
    'Tag',              'brant_preprocess_main',...
    'UserData',         brant_pps_fig,... % edited on 20140221
    'Units',            'pixels',...
    'Resize',           'off',...
    'MenuBar',          'none',...
    'Visible',          'on');

h.fig_CheckBoard = figure(...
    'IntegerHandle',    'off',...
    'Position',         pos_cb,...  % newly edited on 20140219
    'Color',            figColor,...
    'CloseRequestFcn',  @close_chbd,...
    'Name',             'brant_CheckBoard',...
    'NumberTitle',      'off',...
    'Tag',              'brant_preprocess_check',...
    'Units',            'pixels',...
    'Resize',           'off',...
    'MenuBar',          'none',...
    'Visible',          'on');

% display directories
disp_uis = {brant_pps.subj.spm.dirs,	[30, 355 + 10, 280, 110 + 15], 'dirboard_label_chbd', '';...
    '',	[30, 40, 280, 270 + 25], 'info_label_chbd', ''};
create_ui(disp_uis, 'edit_board', h.fig_CheckBoard, uipColor);

labelOpt_chbd = {...
    'Directory',                [20, 470 + 25, 50, 18],     'dir_label_chbd';...
    'Preprocessing Parameters', [20, 315 + 25, 130, 18],     'par_label_chbd'};
h.cb_panel_scrolls = create_ui(labelOpt_chbd, 'text', h.fig_CheckBoard, figColor);

disp_selected_chb = {'Display only selected steps', [160, 317 + 25, 200, 18], 'disp_only_sel_chbd', @disp_para_chbd_cb};
create_ui(disp_selected_chb, 'checkbox', h.fig_CheckBoard, figColor, 1);

ini_panelOpt = {'', [20, 435 + 25, 300, 51],   'prep_panel'};
h_panel_ini = create_ui(ini_panelOpt, 'panel', h.fig_Preprocess, uipColor);

input_btnOpt = {'Output to wk dir'      ,	[10, 28, 134, 18],	'output_sel_chb',    @output_select_cb;...
    'Check Board'           ,	[150, 28, 90, 18],	'chbd_chb',     {@chbd_cb, h.fig_Preprocess};...
    'Sync'                  ,	[10, 5, 50, 18],	'sync_chb',     @sys_chb;...
    'Parallel Workers'      ,	[150, 5, 100, 18],	'parallel_chb', @par_chb};

if strcmpi(brant_pps.pref.parallel, 'off')
    parallel_stat = 0;
else
    parallel_stat = 1;
end
create_ui(input_btnOpt, 'checkbox', h_panel_ini{1}, uipColor, [brant_pps.subj.out.selected, 1, brant_pps.pref.sync, parallel_stat]);

par_workers_Opt = {num2str(brant_pps.pref.parallel_workers)    ,	[255, 5, 30, 18],	'parallel_workers_edit',    @par_edit};
create_ui(par_workers_Opt, 'edit', h_panel_ini{1}, [1, 1, 1], [0, 1, brant_pps.pref.sync, parallel_stat]);

panel_path_simple(h.fig_Preprocess, uipColor, btn_bkgColor);

h_out = findobj(h.fig_Preprocess, 'Tag', 'output_sel_chb');
set(h_out, 'Value', brant_pps.subj.out.selected);
if (brant_pps.subj.out.selected ~= 0)
    output_select_cb(h_out, '');
    set(findobj(h.fig_Preprocess, 'Tag', 'name_pos_out_text_edit'), 'String', num2str(brant_pps.subj.out.nmpos));
end

%
sys_btnOpt = {...
    'Run',  [40, 25, 60, 20],       'run_btn',      @run_cb;...
    'R',    [120, 25, 20, 20],      'rst_btn',      @rst_cb_fake;...
    'S',    [145, 25, 20, 20],      'save_btn',      {@brant_save_gui, @brant_preprocess_jobman, []};... % [] for unused figure handle in script
    'L',    [170, 25, 20, 20],      'load_btn',      {@brant_load_gui};...
    '?',    [195, 25, 20, 20],      'help_btn',      {@brant_help_cb, h.fig_Preprocess, 'Preprocess'};...
    'Cancel',   [240, 25, 60, 20],      'cancel_btn',   [mfilename,'(''Quit'')']};
create_ui(sys_btnOpt, 'pushbutton', h.fig_Preprocess, btn_bkgColor);

prep_panelOpt = {'', [20, 55, 300, 300],   'prep_panel_chbd'};
h_panel_prep = create_ui(prep_panelOpt, 'panel', h.fig_Preprocess, uipColor);

% Create uis for preprocesses
prep_btnOpt = {...
    '> >',      [220, 270, 60, 20],     'slicetiming_input';...
    '> >',      [220, 220, 60, 20],     'realign_input';...
    '> >',      [220, 170, 60, 20],    'coregister_input';...
    '> >',      [220, 120, 60, 20],     'normalise_input';...
    '> >',      [220, 70, 60, 20],     'denoise_input';...
    '> >',      [220, 20, 60, 20],      'smooth_input'};
prep_btnOpt = [prep_btnOpt, repmat({@input_cb}, size(prep_btnOpt, 1), 1)];
create_ui(prep_btnOpt, 'pushbutton', h_panel_prep{1}, btn_bkgColor);

% Create checkbox:  Name    Position    Tag
prep_chbOpt = {...
    'Slice timing',     [10, 270, 100, 20],     'slicetiming_chb';...
    'Realign',          [10, 220, 100, 20],     'realign_chb';...
    'Coregister (Optional)',       [10, 170, 100, 20],     'coregister_chb';...
    'Normalise',        [10, 120, 100, 20],     'normalise_chb';...
    'Denoise',          [10, 70, 100, 20],     'denoise_chb';...
    'Smooth',           [10, 20, 100, 20],      'smooth_chb'};
prep_chbOpt = [prep_chbOpt, repmat({@pre_chb_cb}, size(prep_chbOpt, 1), 1)];
fn_tmp = cellfun(@(x) x(1:end-4), prep_chbOpt(:,3), 'UniformOutput', false);
select_inds = cellfun(@(x) brant_pps.ind.(x) | brant_pps.ind.(strrep(x, 'normalise', 'normalise12')), fn_tmp);
create_ui(prep_chbOpt, 'checkbox', h_panel_prep{1}, uipColor, select_inds);

sel_spm12_ind = strcmp(spm('ver'), 'SPM12') == 1;
norm_spm12_chbOpt = {'spm12', [100, 120, 100, 20], 'norm_spm12_chb', @spm12_norm_chb_cb};
h_spm12 = create_ui(norm_spm12_chbOpt, 'checkbox', h_panel_prep{1}, uipColor, brant_pps.pref.norm12_ind);
if sel_spm12_ind == 1, spm_norm_ena = 'on'; else spm_norm_ena = 'off'; end;
set(h_spm12{1}, 'Enable', spm_norm_ena);
figure(h.fig_Preprocess);
spm12_norm_chb_cb(h_spm12{1}, '');

% checkbox of CheckBoard
h_chbd = findobj(h.fig_Preprocess, 'Tag', 'chbd_chb');
set(allchild(h.fig_Preprocess), 'Units', 'pixels'); % axes and uipanel
set(h_chbd, 'Value', 1);

% 
set(h.fig_Preprocess, 'Visible', 'on');
set(allchild(h.fig_Preprocess), 'Units', 'characters');
set(findall(h.fig_Preprocess, '-property', 'FontSize'), 'FontSize', 8);
brant_config_figure(h.fig_Preprocess, 'Normalized');
brant_config_figure(h.fig_CheckBoard, 'Normalized', h.cb_panel_scrolls);


function h_out = create_ui(uiOpt, uiStyle, uiParent, uiColor, varargin)

h_out = cell(size(uiOpt, 1), 1);
% ui_fontsize = 12;
ui_fontsize = 8;

switch(uiStyle)
    case 'panel'
        for n = 1:size(uiOpt, 1)
            h_out{n} = uipanel(...
                'Parent',           uiParent,...
                'Units',            'pixels',...
                'Position',         uiOpt{n, 2},...
                'Tag',              uiOpt{n, 3},...
                'Title',            '',...
                'Visible',          'on',...
                'BackgroundColor',  uiColor,...
                'BorderType',       'line',...
                'BorderWidth',      2);
        end
    case {'text'}
        for n = 1:size(uiOpt, 1)
            h_out{n} = uicontrol(...
                'Parent',               uiParent,...
                'Units',                'pixels',...
                'String',               uiOpt{n, 1},...
                'Position',             uiOpt{n, 2},...
                'Tag',                  uiOpt{n, 3},...
                'Fontsize',             ui_fontsize,...
                'Style',                uiStyle,...
                'HorizontalAlignment',  'left',...
                'FontSize',             8,...
                'BackgroundColor',      uiColor);
            brant_resize_ui(h_out{n});
        end
    case {'checkbox', 'radiobutton'}
        
        if isempty(varargin)
            vals_tmp = zeros(size(uiOpt, 1), 1);
        else
            vals_tmp = varargin{1};
        end
        
        for n = 1:size(uiOpt, 1)
            if size(uiOpt, 2) == 4
                cb_func = uiOpt{n, 4};
            else
                cb_func = '';
            end
            
            h_out{n} = uicontrol(...
                'Parent',           uiParent,...
                'Units',            'pixels',...
                'HorizontalAlignment',  'left',...
                'String',           uiOpt{n, 1},...
                'Position',         uiOpt{n, 2},...
                'Tag',              uiOpt{n, 3},...
                'Fontsize',         ui_fontsize,...
                'Value',            vals_tmp(n),... % values for rabiobutton and checkbox
                'Style',            uiStyle,...
                'BackgroundColor',  uiColor,...
                'Callback',         cb_func);
            
            brant_resize_ui(h_out{n});
        end
        
        
    case {'pushbutton',  'edit'}
        
        for n = 1:size(uiOpt, 1)
            
            if size(uiOpt, 2) == 4
                cb_func = uiOpt{n, 4};
            else
                cb_func = '';
            end
            
            h_out{n} = uicontrol(...
                'Parent',           uiParent,...
                'Units',            'pixels',...
                'String',           uiOpt{n, 1},...
                'Position',         uiOpt{n, 2},...
                'Tag',              uiOpt{n, 3},...
                'Fontsize',         ui_fontsize,...
                'Style',            uiStyle,...
                'BackgroundColor',  uiColor,...
                'Callback',         cb_func);
        end
    case 'edit_board'
        for n = 1:size(uiOpt, 1)
            
            if size(uiOpt, 2) == 4
                cb_func = uiOpt{n, 4};
            else
                cb_func = '';
            end
            
            h_out{n} = uicontrol(...
                'Parent',           uiParent,...
                'Units',            'pixels',...
                'String',           uiOpt{n, 1},...
                'Position',         uiOpt{n, 2},...
                'Tag',              uiOpt{n, 3},...
                'Fontsize',             ui_fontsize,...
                'Style',            'edit',...
                'horiz',            'left',...
                'Min',              1,...
                'Max',              3,...
                'enable',           'inactive',...
                'BackgroundColor',  uiColor,...
                'Callback',         cb_func);
            
            % enable horizontal scrolling
            try
                % enable horizontal scrolling
                set(h_out{n}, 'Enable', 'inactive');
                set(h_out{n}, 'Value', 1);
                set(h_out{n}, 'Min', 1);
                set(h_out{n}, 'Max', 3);
                
                jEdit2 = findjobj(h_out{n});
                jEditbox2 = jEdit2.getViewport().getComponent(0);
                jEditbox2.setWrapping(false);                % turn off word-wrapping
                jEditbox2.setEditable(false);                % non-editable
                set(jEdit2,'HorizontalScrollBarPolicy',30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
            catch
            end
        end
end

function filetype_cb(obj, evd)
h_main_data = get(gcf, 'Userdata');
filetype = get(obj, 'String');
h_main_data.subj.filetype = filetype;
set(gcf, 'Userdata', h_main_data);

function h_panel = panel_path_simple(h_fig, uipColor, btn_bkgColor)
% Create preprocess uipanel
brant_pps = get(h_fig, 'Userdata');

prep_panelOpt = {'Preprocessing Options', [20, 365, 300, 60 + 25],   'sys_panel_sim'};
h_panel = create_ui(prep_panelOpt, 'panel', h_fig, uipColor);

% Create labels of figPreprocess
labelOpt_pre = {...
    'wk dir',    	[10, 60, 50, 15],      'dir_out';...
    'data dirs',    [10, 35, 50, 15],      'dir_label_pre';...
    'filetype',     [10, 10, 50, 15],      'filetype_label_pre'};

create_ui(labelOpt_pre, 'text', h_panel{1}, uipColor);

textOpt = {...
    brant_pps.subj.filetype,    [75, 10, 50, 15],     'filetype_text',	@filetype_cb;...
    brant_pps.subj.out.dir,     [75, 35 + 25, 170, 15],    'dir_out_text_edit',       {@dir_out_cb, h_fig}};

create_ui(textOpt, 'edit', h_panel{1}, [1 1 1]);

input_btnOpt = {...
    '...', [260, 35, 18, 15], 'dir_btn', @dir_cb;...
    '...', [260, 35 + 25, 18, 15], 'dir_out_btn', {@dir_out_cb, h_fig}};
create_ui(input_btnOpt, 'pushbutton', h_panel{1}, btn_bkgColor);

input_chbOpt = {'from text file', [75, 35, 80, 16], 'dir_in_text', {@dir_text_cb_new, h_fig};...
    'data in 4D', [150, 10, 70, 16], 'is4d', {@is4d_cb, h_fig}};

create_ui(input_chbOpt, 'checkbox', h_panel{1}, uipColor, [brant_pps.pref.dirs_in_text, brant_pps.subj.is4d]);

function is4d_cb(obj, ev, h_fig)
fig_opts = get(h_fig, 'Userdata');
fig_opts.subj.is4d = get(obj, 'Value');
set(h_fig, 'Userdata', fig_opts);

function output_select_cb(obj, ev)

h_fig = findobj(0, 'Name',             'brant_Preprocessing',...
    'Tag',              'brant_preprocess_main');

brant_config_figure(h_fig, 'pixels');

val_out_sel = get(obj, 'Value');
h_ini = get(obj, 'Parent');
set(h_ini, 'units', 'pixels');
brant_pps = get(h_fig, 'Userdata');

fig_pos = get(h_fig, 'Position');

h_sim = findobj(h_fig, 'Tag', 'sys_panel_sim');
set(h_sim, 'Units', 'pixels');

if val_out_sel == 0
    panel_diff = -25;
    h_nm_pos = findobj(h_sim, 'Tag', 'name_pos_out');
    h_nm_pos_text = findobj(h_sim, 'Tag', 'name_pos_out_text_edit');
    brant_pps.subj.out.nmpos = str2double(get(h_nm_pos_text, 'String'));
    delete([h_nm_pos, h_nm_pos_text]);
else
    panel_diff = 25;
end

fig_pos(2) = fig_pos(2) - panel_diff;
fig_pos(4) = fig_pos(4) + panel_diff;
set(h_fig, 'Position', fig_pos);

h_sim_panel_pos = get(h_sim, 'Position');
h_sim_panel_pos(4) = h_sim_panel_pos(4) + panel_diff;
set(h_sim, 'Position', h_sim_panel_pos);

h_sim_all = allchild(h_sim);
h_shift = [h_ini; h_sim_all];

pos_h_sim_all = arrayfun(@(x) get(x, 'Position'), h_shift, 'UniformOutput', false);
arrayfun(@(x, y) set(x, 'Position', y{1} + [0, panel_diff, 0, 0]), h_shift, pos_h_sim_all);

if val_out_sel == 1
    labelOpt_pre = {'id index',     [10, 10, 50, 15],      'name_pos_out'};
    create_ui(labelOpt_pre, 'text', h_sim, [0.925 0.914 0.847]);
    
    textOpt = {num2str(brant_pps.subj.out.nmpos),           [75, 10, 40, 15],     'name_pos_out_text_edit',	{@nm_pos_cb, h_fig}};
    create_ui(textOpt, 'edit', h_sim, [1 1 1]);
end

brant_pps.subj.out.selected = val_out_sel;
set(h_fig, 'Userdata', brant_pps);

function nm_pos_cb(obj, ev, h_fig)
h_main_data = get(h_fig, 'Userdata');
h_main_data.subj.out.nmpos = str2double(get(obj, 'String'));
set(h_fig, 'Userdata', h_main_data);