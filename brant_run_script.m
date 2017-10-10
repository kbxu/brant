function brant_run_script(fn)
% fn: fullpath of saved GUI parameters

gui_info = load(fn);

% version control
brant_ver = brant('version');
if (strcmpi(gui_info.gui_version, brant_ver) == 0)
    warning(['Version not matched. The function may not work well!',...
             sprintf('\nVersion of loaded file:%s\nVersion of current BRANT:%s\n', gui_info.gui_version, brant_ver)]);
end

gui_info.gui_func(gui_info.gui_parameters{:});
