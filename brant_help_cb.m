function brant_help_cb(obj, evd, hfig_inputdlg, dlg_title) %#ok<*INUSL>

fig_nm = ['brant help window:', dlg_title];

help_strs = brant_help_information(dlg_title);
size_help_strs = size(help_strs);

h_help = findobj(0, 'Name', fig_nm);
if isempty(h_help)
    set(hfig_inputdlg, 'Units', 'characters');
    pos_fig = get(hfig_inputdlg, 'Position');
    
    h_help = figure(...
        'MenuBar',          'none',...
        'NumberTitle',      'off',...
        'Units',             'characters',...
        'Position',         [pos_fig(1:2), 120, min(size_help_strs(1) + 10, 30)],...
        'Name',             ['brant help window:', dlg_title]);
else
    figure(h_help);
    return;
end

if ~isempty(help_strs)
    set(h_help, 'Unit', 'characters');
    pos_help_win = get(h_help, 'Position');
    %     size_help_info = size(help_strs) + [2, 0];
    h_text = uicontrol(...
        'Parent', h_help,...
        'style', 'edit',...
        'Units', 'characters',...
        'HorizontalAlignment','left',...
        'position', [5, 5, pos_help_win(3) - 10, pos_help_win(4) - 7],...
        'fontsize', 10,...
        'string', help_strs);
    
    set(h_text, 'Enable', 'inactive');
    set(h_text, 'Value', 1);
    set(h_text, 'Min', 1);
    set(h_text, 'Max', 3);
    try
        jEdit1 = findjobj(h_text);
        jEditbox1 = jEdit1.getViewport().getComponent(0);
        jEditbox1.setWrapping(false);                % turn off word-wrapping
        jEditbox1.setEditable(false);                % non-editable
        set(jEdit1, 'HorizontalScrollBarPolicy', 30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
    catch
    end
    
    set(h_text, 'Units', 'pixel');
    h_text_pos = get(h_text, 'Position');
    
    set(h_help, 'Units', 'pixel');
    pos_fig_help = get(h_help, 'Position');
    
    uicontrol(...
        'Parent', h_help,...
        'style', 'pushbutton',...
        'Units', 'pixel',...
        'fontsize', 8,...
        'HorizontalAlignment','left',...
        'position', [pos_fig_help(3) / 2 - 30, h_text_pos(2) - 30, 60, 20],...
        'string', 'OK',...
        'callback', {@ok_cb, h_help});
    
    set(hfig_inputdlg, 'Units', 'characters');
    brant_config_figure(h_help, 'Normalized', h_text);
else
    delete(h_help);
end

function ok_cb(obj, evt, h_help)
delete(h_help);
