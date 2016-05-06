function setColor(hObject, handles)

%split
% color_left = handles.color(1:handles.limit_ver, :);
% color_right = handles.color(handles.limit_ver+1:end, :);
[color_left, color_right] = splitVertices(handles.color);
% Set Color
if ~handles.if_whole
    %left lateral
    set(handles.left, 'FaceColor', 'interp', 'FaceVertexCData', color_left, 'EdgeColor','none')
    %right lateral
    set(handles.right, 'FaceColor', 'interp', 'FaceVertexCData', color_right, 'EdgeColor','none')
    %left medial
    set(handles.left_back, 'FaceColor', 'interp', 'FaceVertexCData', color_left, 'EdgeColor','none')
    %right medial
    set(handles.right_back, 'FaceColor', 'interp', 'FaceVertexCData', color_right, 'EdgeColor','none')
else
    %set whole brain
    set(handles.left_whole, 'FaceColor', 'interp', 'FaceVertexCData', handles.color, 'EdgeColor', 'none')
    set(handles.right_whole, 'FaceColor', 'interp', 'FaceVertexCData', handles.color, 'EdgeColor', 'none')
    set(handles.anterior, 'FaceColor', 'interp', 'FaceVertexCData', handles.color, 'EdgeColor', 'none')
    set(handles.posterior, 'FaceColor', 'interp', 'FaceVertexCData', handles.color, 'EdgeColor', 'none')
end

% Set colorbar
guidata(hObject, handles);




