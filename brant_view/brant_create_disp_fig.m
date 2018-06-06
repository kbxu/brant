function h_fig = brant_create_disp_fig(h_con, title)

h_fig = findobj(0, 'Name', title);
if ~isempty(h_fig)
    h_axes = findobj(h_fig, 'Type', 'axes');
    
    if ~isempty(h_axes)
        delete(h_axes);
    end
    set(0, 'CurrentFigure', h_fig);
    figure(h_fig);
else
    h_fig = figure('Name', title, 'Position', [50, 50, 950, 750]);
end

if ~isempty(h_con)
    set(h_con, 'DeleteFcn', {@close_win, h_fig});
    h_cancel = findobj(h_con, 'Style', 'pushbutton', 'String', 'cancel');
    set(h_cancel, 'ButtonDownFcn', {@cancel_fun, h_fig});
end
set(h_fig, 'WindowButtonUpFcn', {@clickfn, h_fig});

function clickfn(obj, evd, h_fig) %#ok<*INUSL>

axes_tag = get(gca, 'Tag');
h_light = findobj(h_fig, 'type', 'light', 'Tag', axes_tag);

if isempty(h_light)
    h_light = findobj(h_fig, 'type', 'light');
end
set(h_light, 'Position', campos);

function close_win(obj, evd, h_disp)
try
    delete(h_disp);
end

function cancel_fun(obj, evd, h_disp)
h_con = get(obj, 'Parent');
delete(h_con);
try %#ok<*TRYNC>
    delete(h_disp);
end