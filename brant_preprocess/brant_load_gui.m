function brant_load_gui(obj, evd) %#ok<INUSD>
% obj: object of the 'S' button
% evd: event of the current operation

[fn, pth] = uigetfile('*.mat', 'Choose saved parameters for the current GUI');

if isnumeric(fn)
    if fn == 0
        return;
    end
end

gui_info = load(fullfile(pth, fn));

% version control
brant_ver = brant('version');
if (strcmpi(gui_info.gui_version, brant_ver) == 0)
    warning(['Version not matched. The function may not work well!',...
             sprintf('\nVersion of loaded file:%s\nVersion of current BRANT:%s\n', gui_info.gui_version, brant_ver)]);
end

% delete old GUI
if ishandle(obj)
    parent_obj = get(obj, 'Parent');
    if strcmpi(get(parent_obj, 'Name'), gui_info.gui_fn) == 0
        error('Current GUI doesn''t match the loaded *.mat!')
    else
        delete(parent_obj);
    end
end

% generate new GUI
switch(gui_info.gui_fn)
    case 'brant_Preprocessing'
        brant_preprocess('reload', gui_info.gui_parameters{1})
    otherwise
        [jobman, ui_strucs, process_fun] = brant_postprocess_defaults(gui_info.gui_fn); %#ok<ASGLU>
        brant_postprocesses_sub(gui_info.gui_fn, gui_info.gui_parameters{1}, ui_strucs, process_fun);
end