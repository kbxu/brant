function new = displayPatch(faces, vertices, color, azimut, elevation, handles)
new = patch('Faces', faces, 'Vertices', vertices, 'Facecolor', [handles.bg_grey handles.bg_grey handles.bg_grey], 'EdgeColor', 'None');
set(new, 'FaceColor', 'interp', 'FaceVertexCData', color, 'EdgeColor', 'none')
axis tight;
daspect([1 1 1])
view(azimut, elevation)
 camlight right
% camlight headlight
lighting gouraud
alpha(1)
axis off