function [axes1_surf, axes2_surf, axes3_surf, axes4_surf] = init_display(handles)

if ~handles.if_whole
    [vertices_1, vertices_2, faces_1, faces_2, color_1, color_2] = splitt(handles.vertices, handles.faces, handles.color);
else
    vertices_1 = handles.vertices;
    vertices_2 = handles.vertices;
    faces_1 = handles.faces;
    faces_2 = handles.faces;
    color_1 = handles.color;
    color_2 = handles.color;
end

% left lateral
cla(handles.axes1);
axes(handles.axes1);
axes1_surf = displayPatch(faces_1, vertices_1, color_1, handles.display(1, 1), handles.display(1, 2), handles);
set(handles.slider1_1, 'Value', 0.5);
set(handles.slider1_2, 'Value', 0.5);

% right lateral
cla(handles.axes2);
axes(handles.axes2);
axes2_surf = displayPatch(faces_2, vertices_2, color_2, handles.display(2, 1), handles.display(2, 2), handles);
set(handles.slider2_1, 'Value', 0.5);
set(handles.slider2_2, 'Value', 0.5);

% left medial
cla(handles.axes3);
axes(handles.axes3);
axes3_surf = displayPatch(faces_1, vertices_1, color_1, handles.display(3, 1), handles.display(3, 2), handles);
set(handles.slider3_1, 'Value', 0.5);
set(handles.slider3_2, 'Value', 0.5);

% right medial
cla(handles.axes4);
axes(handles.axes4);
axes4_surf = displayPatch(faces_2, vertices_2, color_2, handles.display(4, 1), handles.display(4, 2), handles);
set(handles.slider4_1, 'Value', 0.5);
set(handles.slider4_2, 'Value', 0.5);