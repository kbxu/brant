function new = sliderRotate(axes, display, handles)

if ~handles.if_whole
    [vertices_left, vertices_right, faces_left, faces_right, color_left, color_right] = splitt(handles.vertices, handles.faces, handles.color);
    switch mod(axes, 2) 
    case 0
        faces = faces_right;
        vertices = vertices_right;
        color = color_right;
    case 1
        faces = faces_left;
        vertices = vertices_left;
        color = color_left;
    end
else
    faces = handles.faces;
    vertices = handles.vertices;
    color = handles.color;
end

new = displayPatch(faces, vertices, color, display(axes, 1), display(axes, 2), handles);
