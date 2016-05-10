function Brain = brant_draw_surf(face, vert, brain_alpha)

brain = patch('Faces', face, 'Vertices', vert, 'Edgecolor', 'none');
whitebg(gcf, [1 1 1]);
set(gcf, 'Color', [1 1 1], 'InvertHardcopy', 'off');
eval(['material ', 'metal', ';'])
eval(['shading ', 'interp', ';'])
set(brain, 'FaceColor', [0.95, 0.95, 0.95]);
set(brain, 'FaceAlpha', brain_alpha); 
eval(['lighting ', 'phong', ';']);
daspect([1 1 1]);
Brain = brain;