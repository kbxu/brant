function brant_draw_surface(surface_brain, mode_display, surf_alpha, varargin)
% varargin{2}: 3D volume of intensities
% varargin{1}: color info

% load surface
[vertices_coord, faces] = load_surface_new(surface_brain);

mode_brain = regexpi(mode_display, ':', 'split');
if strcmpi(mode_brain{1}, 'whole brain') == 0
    % only for halves
    [vertices_left, vertices_right] = splitVertices(vertices_coord);
    
    [L_ind, y] = find(faces <= size(vertices_left, 1), 1, 'last'); %#ok<NASGU>
    faces_left = faces(1:L_ind, :);
    faces_right = faces(L_ind+1:end, :) - max(faces_left(:));
end

%
CData_tmp = [];
CData_L = [];
CData_R = [];
c_map = [];
% find color of vertices
if nargin > 4
    if strcmpi(mode_brain{1}, 'whole brain')
        [CData, c_map, cbr] = brant_get_vert_color(varargin{2}, vertices_coord, varargin{1});
    else
        switch mode_brain{2}
            case {'left lateral', 'left medial'}
                [CData_L, c_map, cbr] = brant_get_vert_color(varargin{2}, vertices_left, varargin{1});
            case {'right lateral', 'right medial'}
                [CData_R, c_map, cbr] = brant_get_vert_color(varargin{2}, vertices_right, varargin{1});
            otherwise % left and right
                [CData_L, c_map, cbr] = brant_get_vert_color(varargin{2}, vertices_left, varargin{1});
                [CData_R, c_map, cbr] = brant_get_vert_color(varargin{2}, vertices_right, varargin{1});
        end
    end
end


if strcmpi(mode_display, 'halves:left and right') == 0
    view_angle = brant_get_view_angle(mode_display);
    
    switch mode_brain{1}
        case 'halves'
            switch mode_brain{2}
                case {'left lateral', 'left medial'}
                    faces_tmp = faces_left;
                    vertices_tmp = vertices_left;
                    if nargin > 4
                        CData_tmp = CData_L;
                    end
                case {'right lateral', 'right medial'}
                    faces_tmp = faces_right;
                    vertices_tmp = vertices_right;
                    if nargin > 4
                        CData_tmp = CData_R;
                    end
            end
        case 'whole brain'
            vertices_tmp = vertices_coord;
            faces_tmp = faces;
            if nargin > 4
                CData_tmp = CData;
            end
    end
    center_shift = mean(vertices_tmp);
    vertices_tmp = bsxfun(@minus, vertices_tmp, center_shift);
    brant_draw_surf(faces_tmp, vertices_tmp, surf_alpha, CData_tmp);
    colormap(c_map);
    view(view_angle);
    h_light = camlight('right');
    set(h_light, 'Position', campos);
    set(gca, 'Userdata', center_shift);
    
    if nargin > 3
        material(varargin{1}.material_type);
        lighting(varargin{1}.lighting_type);
        shading(varargin{1}.shading_type);
    end

    if nargin > 4
        if varargin{1}.colorbar_ind == 1
            caxis(cbr.caxis);
        end
    end
else
    
    h_figure = gcf;
    sub_view_angle = [-90, 90, 60, -60];
    sub_tags = {'upper_l', 'upper_r', 'lower_l', 'lower_r'};
    sub_faces = {'L', 'R', 'L', 'R'};
    sub_pos = [0, 0.5, 0.5, 0.46;...
               0.5, 0.5, 0.5, 0.46;...
               0, 0.02, 0.5, 0.46;...
               0.5, 0.02, 0.5, 0.46];
           
%     center_shift = mean(vertices_coord);
    for m = 1:4
        h_sub = subplot(2, 2, m, 'Parent', h_figure);
        
        set(h_sub, 'Position', sub_pos(m, :));
        if strcmpi(sub_faces{m}, 'L')
            face_tmp = faces_left;
            vertices_tmp = vertices_left;
            CData_tmp = CData_L;
        else
            face_tmp = faces_right;
            vertices_tmp = vertices_right;
            CData_tmp = CData_R;
        end
        center_shift = mean(vertices_tmp);
        vertices_tmp = bsxfun(@minus, vertices_tmp, center_shift);
        
        brant_draw_surf(face_tmp, vertices_tmp, surf_alpha, CData_tmp);
        
        view([sub_view_angle(m), 0]);
        set(h_sub, 'Tag', sub_tags{m});
        h_light = camlight(sub_view_angle(m), 0);
        set(h_light, 'Position', campos, 'Tag', sub_tags{m});
        set(gca, 'Userdata', center_shift);
        
        if nargin > 3
            material(varargin{1}.material_type);
            lighting(varargin{1}.lighting_type);
%             shading(varargin{1}.shading_type);
        end
        
        if nargin > 4
            colormap(c_map);
            if varargin{1}.colorbar_ind == 1
                caxis(cbr.caxis);
            end
        end
    end
end


% axis('vis3d');

if nargin > 4
    if varargin{1}.colorbar_ind == 1
        cbar_h = colorbar('Location', 'SouthOutside');
        set(cbar_h, 'Position', [0.35, 0.05, 0.3, 0.03],...
                    'FontSize', 14,...
                    'XTick', cbr.xtick,...
                    'XTickLabel', cbr.xlabel);
    end
end