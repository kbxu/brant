function brant_postprocess_ui(dlg_title, prompt)

figColor = [0.94, 0.94, 0.94];

current_pos.x = 30;
current_pos.y = 30;
current_pos.length = 120;
current_pos.height = 30;
dis_interval = 10;

fig.x = 400;
fig.y = 200;
fig.len = current_pos.length + 2 * current_pos.x;
fig.height = length(prompt) * current_pos.height + (length(prompt) - 1) * dis_interval + current_pos.y * 2;
fig_pos = [fig.x, fig.y, fig.len, fig.height];

h_brant = findobj(0, 'Tag', 'figBRANT');
pos_brant = get(h_brant, 'Position');
pos_tmp = [pos_brant(1), pos_brant(2) - fig_pos(4) - 39, fig_pos(3:4)];

hfig_inputdlg = figure(...
    'IntegerHandle',    'off',...
    'Position',         pos_tmp,...
    'Color',            figColor,...
    'Name',             dlg_title,...
    'UserData',         '',...
    'NumberTitle',      'off',...
    'Tag',              ['fig_', dlg_title],...	
    'Units',            'pixels',...
    'Resize',           'off',...	
    'MenuBar',          'none',...    
    'Visible',          'on',...
    'CloseRequestFcn',  @close_fig,...
    'DeleteFcn',        @close_fig);

h_sub = cell(length(prompt), 1);
for m = length(prompt):-1:1
    h_sub{m} = uicontrol(...
                    'Parent',               hfig_inputdlg,...
                    'String',               prompt{m},...
                    'UserData',             '',...
                    'Tag',                  prompt{m},...
                    'Position',             [current_pos.x, current_pos.y, current_pos.length, current_pos.height],...
                    'Style',                'pushbutton',...
                    'BackgroundColor',      figColor,...
                    'Callback',             @doCallback);
    current_pos.y = current_pos.y + current_pos.height + dis_interval;
end

set(findall(hfig_inputdlg, '-property', 'FontSize'), 'FontSize', 8);

function doCallback(obj, evd) %#ok

userdata = get(obj, 'Tag');
h_board = findobj(0, 'Tag', userdata, 'Name', userdata);
if isempty(h_board)    
    [jobman, ui_strucs, process_fun] = brant_postprocess_defaults(userdata);
    brant_postprocesses_sub(userdata, jobman, ui_strucs, process_fun);
else
    brant_config_figure(h_board, 'pixel');
    h_parent = get(obj, 'Parent');
    pos_par = get(h_parent, 'Position');
    pos_curr = get(h_board, 'Position');
    fig_pos = [pos_par(1) + pos_par(3) + 15, pos_par(4) + pos_par(2) - pos_curr(4), pos_curr(3), pos_curr(4)];
    set(h_board, 'Position', fig_pos);

    brant_config_figure(h_board, 'Normalized');
    figure(h_board);
end


function close_fig(obj, evd) %#ok<INUSD>
userdata = get(obj,'Tag');
func_type = userdata(5:end);
window_names = brant_postprocess_funcions(func_type);

h_all_fig = findobj(0, 'Type', 'fig');
nm_all_fig = arrayfun(@(x) get(x, 'Name'), h_all_fig, 'UniformOutput', false);

h_brant_ind = cellfun(@(x) any(strcmpi(x, window_names)), nm_all_fig);
delete(h_all_fig(h_brant_ind));
delete(obj);
