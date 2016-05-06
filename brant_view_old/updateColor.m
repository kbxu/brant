function [color_last, color_last_on, color, color_on] = updateColor(hObject, handles)
[color_last, color_last_on] = computeColor(handles);
color = color_last;
color_on = color_last_on;
handles.color = color;
handles.color_on = color_on;
setColor(hObject, handles);