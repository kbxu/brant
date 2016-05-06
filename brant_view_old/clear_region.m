function [tot_color, vertex_on, vertices_to_color, color] = clear_region(no, hObject, handles)
tot_color = handles.tot_color;
vertex_on = handles.vertex_on;
vertices_to_color = handles.vertices_to_color;
tot_color(:, :, no) = ones(size(handles.vertices, 1), 3) * 0.8;
vertex_on(:, no) = zeros(size(handles.vertices, 1), 1);
vertices_to_color(:, no) = ones(size(handles.vertices, 1), 1) * 1000;
set(handles.popup{no}, 'Value', 1);
color = setColor(1, no, hObject, handles);

guidata(hObject, handles);
end