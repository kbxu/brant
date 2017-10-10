function brant_save_gui(obj, evd, gui_func, varargin) %#ok<INUSL>
% obj: object of the 'S' button
% evd: event of the current operation
% gui_func: runtime function of the current GUI, as a function handle
% varargin: parameters of gui_func, written in cells

h_parent = get(obj, 'Parent');
gui_fn = get(h_parent, 'Name');
gui_fn_out = regexprep(gui_fn, '[\s\\/]+', '_');
[fn, pth] = uiputfile([gui_fn_out, '.mat'],'Save GUI Parameters');

if isnumeric(fn)
    if fn == 0
        return;
    end
end

brant_ver = brant('version');
gui_version = brant_ver;
if nargin(gui_func) == 1
    gui_parameters = {get(h_parent, 'Userdata')}; %#ok<*NASGU>
else
    gui_parameters = [{get(h_parent, 'Userdata')}, varargin]; %#ok<*NASGU>
end
read_me = sprintf('Usage in script:\n\tload(''%s'');\n\tgui_func(gui_parameters{:});\nOr simply run:\n\tbrant_run_script(''%s'')', fullfile(pth, fn), fullfile(pth, fn));
disp(read_me); %#ok<DSPS>
save(fullfile(pth, fn), 'gui_parameters', 'gui_fn', 'gui_func', 'gui_version', 'read_me');