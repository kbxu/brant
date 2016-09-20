function brain = brant_draw_surf(face, vert, brain_alpha, varargin)

if nargin > 3 && ~isempty(varargin{1})
    brain = patch('Faces', face, 'Vertices', vert, 'FaceVertexCData', varargin{1}); %FaceVertexCData
else
    brain = patch('Faces', face, 'Vertices', vert, 'Edgecolor', 'none');
%     set(brain, 'FaceColor', [0.95, 0.95, 0.95]);
end
whitebg(gcf, [1 1 1]);
set(gcf, 'Color', [1 1 1], 'InvertHardcopy', 'off');

lighting('phong');
material('dull');
shading('interp');

if nargin > 3 && ~isempty(varargin{1})
    
else
    set(brain, 'FaceColor', [0.95, 0.95, 0.95]);
    set(brain, 'FaceAlpha', brain_alpha);
end

axis('vis3d');
axis('tight');
axis('off');
daspect([1 1 1]);
