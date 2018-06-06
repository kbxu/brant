function brant_draw_surface(surface_brain, mode_display, draw_param, vol)
% varargin{1}: radius of maximum neighbour interpolation in mm
% if input is a nifti mask, the current programm only works for standard
% space -- mean zeroed image

% load surface
[vertices_coord, faces] = load_surface_new(surface_brain);

mode_brain = regexpi(mode_display, ':', 'split');

% get indices of vertices for left and right faces
left_ver_end = find(vertices_coord(:,1) < 0, 1, 'last');
left_ver_ind = 1:left_ver_end;
right_ver_ind = left_ver_end+1:size(vertices_coord, 1);

% get indices of left and right faces
left_face_end = find(faces(:, 1) <= numel(left_ver_ind), 1, 'last');
faces_right_shift = max(max(faces(1:left_face_end, :)));
left_face_ind = 1:left_face_end;
right_face_ind = left_face_end+1:size(faces, 1);

% find color of vertices
if ~isempty(vol)
    [CData, c_map_wb, cbr] = brant_get_vert_color(vol, vertices_coord, draw_param);
else
    CData = [];
end

if (strcmpi(mode_display, 'halves:left and right') == 0)
    draw_param.angle = brant_get_view_angle(mode_display);
    
    switch mode_brain{1}
        case 'halves'
            switch mode_brain{2}
                case {'left lateral', 'left medial'}
                    brant_draw_surf(gca, faces(left_face_ind, :),...
                                        vertices_coord, left_ver_ind,...
                                        CData, draw_param);
                case {'right lateral', 'right medial'}
                    brant_draw_surf(gca, faces(right_face_ind, :) - faces_right_shift,...
                                        vertices_coord, right_ver_ind,...
                                        CData, draw_param);
            end
        case 'whole brain'
            brant_draw_surf(gca, faces, vertices_coord, [left_ver_ind, right_ver_ind],...
                                CData, draw_param);
    end
    
    pos_gca = get(gca, 'Position');
    set(gca, 'Position', [pos_gca(1), 0.15, pos_gca(3), 0.7]);
    
    if ~isempty(vol)
        colormap(c_map_wb);
%         if (draw_param.colorbar_ind == 1)
            caxis(cbr.caxis);
%         end
    end
else
    
    sub_view_angle = [-90, 90, 60, -60];
    sub_tags = {'upper_l', 'upper_r', 'lower_l', 'lower_r'};
    sub_faces = {'L', 'R', 'L', 'R'};
    sub_pos = [0, 0.5, 0.5, 0.46;...
               0.5, 0.5, 0.5, 0.46;...
               0, 0.02, 0.5, 0.46;...
               0.5, 0.02, 0.5, 0.46];
           
    for m = 1:4
        
        h_sub = subplot(2, 2, m, 'Parent', gcf);
        set(h_sub, 'Position', sub_pos(m, :));
        set(h_sub, 'Tag', sub_tags{m});
        
        draw_param.angle = [sub_view_angle(m), 0];
        if strcmpi(sub_faces{m}, 'L')
            brant_draw_surf(gca, faces(left_face_ind, :),...
                                vertices_coord, left_ver_ind,...
                                CData, draw_param);
        else
            brant_draw_surf(gca, faces(right_face_ind, :) - faces_right_shift,...
                                vertices_coord, right_ver_ind,...
                                CData, draw_param);
        end
        
        if ~isempty(vol)
            colormap(c_map_wb);
%             if (draw_param.colorbar_ind == 1)
                caxis(cbr.caxis);
%             end
        end
    end
end

if ~isempty(vol)
    if (draw_param.colorbar_ind == 1)
        cbar_h = colorbar('Location', 'SouthOutside');
        set(cbar_h, 'Position', [0.35, 0.05, 0.3, 0.03],...
                    'FontSize', 20,...
                    'XTick', cbr.xtick,...
                    'XTickLabel', cbr.xlabel);
    end
end