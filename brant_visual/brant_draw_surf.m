function brain = brant_draw_surf(h_axis, face_inds, vert_coords_wb, vert_ind, CData_wb, draw_param)

vert_coords = vert_coords_wb(vert_ind, :);

brain_alpha = draw_param.alpha;
view_angle = draw_param.angle;
axes(h_axis);

center_shift = mean(vert_coords_wb);
vert_coords = bsxfun(@minus, vert_coords, center_shift);

if ~isempty(CData_wb)
    brain = patch('Faces', face_inds, 'Vertices', vert_coords, 'FaceVertexCData', CData_wb(vert_ind), 'FaceAlpha', brain_alpha); %FaceVertexCData
else
    brain = patch('Faces', face_inds,...
                  'Vertices', vert_coords,...
                  'Edgecolor', 'none',...
                  'FaceAlpha', brain_alpha,...
                  'FaceColor', [0.95, 0.95, 0.95]);
end

whitebg(gcf, [1 1 1]);
set(gcf, 'Color', [1 1 1], 'InvertHardcopy', 'off');

if ~isempty(CData_wb)
    shading(draw_param.shading_type);
end

axis('vis3d', 'tight', 'off');
daspect([1 1 1]);
set(h_axis, 'Userdata', center_shift);

view(view_angle);
h_light = camlight('right');
set(h_light, 'Position', campos, 'Tag', get(h_axis, 'Tag'));

material(draw_param.material_type);
lighting(draw_param.lighting_type);