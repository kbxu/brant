function draw_line(jobman, fc_strength, node_1, node_2, node)
% interval = 20;
% theta = (0: interval)/interval*2*pi;
%     n = ones(100, 1);
%     x = n*cos(theta);
%     y = n*sin(theta);
%     if jobman.node_size_eq ~= 1
%         len = norm(node(sub_x(i), 1: 3)-node(sub_y(i), 1: 3)) - node(sub_x(i), 4) - node(sub_y(i), 4);
%     else
%         len = norm(node(sub_x(i), 1: 3)-node(sub_y(i), 1: 3)) - jobman.node_size*2;
%     end
%     z = (0:length(n)-1)'/(length(n)-1)*ones(1, length(theta));
%     cyl_stick = mesh(x, y, z*len);
%     unit_ver = [0 0 1];
%     angle_xy = dot(unit_ver, node(sub_x(i), 1: 3)-node(sub_y(i), 1: 3))/...
%         (norm(unit_ver)*norm(node(sub_x(i), 1: 3)-node(sub_y(i), 1: 3)))*180/pi;
%     rot_aix = cross(unit_ver, (node(sub_x(i), 1: 3)-node(sub_y(i), 1: 3)));
%     rotate(cyl_stick, rot_aix, angle_xy, [0 0 0]);
%     set(cyl_stick, 'XData', get(cyl_stick, 'XData') + node(sub_x(i), 1))
%     set(cyl_stick, 'YData', get(cyl_stick, 'YData') + node(sub_x(i), 2))
%     set(cyl_stick, 'ZData', get(cyl_stick, 'ZData') + node(sub_x(i), 3))
    cyl_stick = plot3([node_1(1), node_2(1)], [node_1(2), node_2(2)], [node_1(3), node_2(3)]);
    if jobman.node_same_color == 1
        if jobman.adj_edge_color == 0
            h_same_text_color = findobj(0, 'Tag', 'node_same_color_text_color');
            c = get(h_same_text_color, 'BackgroundColor');
            set(cyl_stick,'Color', c);
        else
            h_pos = findobj(0, 'Tag', 'pos_color_text_color');
            pos = get(h_pos, 'BackgroundColor');
            h_neg = findobj(0, 'Tag', 'neg_color_text_color');
            neg = get(h_neg, 'BackgroundColor');
            if fc_strength > 0
                set(cyl_stick,'Color', pos);
            else
                set(cyl_stick,'Color', neg);
            end
        end
    else
        if jobman.adj_edge_color == 1
            h_pos = findobj(0, 'Tag', 'pos_color_text_color');
            pos = get(h_pos, 'BackgroundColor');
            h_neg = findobj(0, 'Tag', 'neg_color_text_color');
            neg = get(h_neg, 'BackgroundColor');
            if fc_strength > 0
                set(cyl_stick,'Color', pos);
            else
                set(cyl_stick,'Color', neg);
            end
        else
            if jobman.node_module == 1 && node_1(5) == node_2(5)
                if size(jobman.node_module_color, 2) == max(node(:, 5))
                    set(cyl_stick,'Color', jobman.node_module_color{node_1(5)})
                else
                    set(cyl_stick, 'Color', [node_1(6), node_1(7), node_1(8)])
                end
            else
                set(cyl_stick,'Color', [0 0 0])
            end
        end
    end  
    set(cyl_stick, 'LineWidth', jobman.thickness);
%     set(cyl_stick,'EdgeColor','none');
%     set(cyl_stick,'FaceAlpha',0.7);
%     set(cyl_stick,'EdgeAlpha',0);