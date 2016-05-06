function draw_node(node, label, jobman)

h_node_color = findobj(findobj(0, 'Tag', 'Visual'), 'Tag', 'node_same_color_text_color');
color = get(h_node_color, 'Backgroundcolor');
h_module = findobj(findobj(0, 'Tag', 'Visual'), 'Tag', 'node_module');
module_value = get(h_module, 'Value');
job_field = fields(jobman);
cmp = strcmp(job_field, 'node_module_color');
if sum(cmp) == 1
    if size(jobman.node_module_color, 1) > 1
        for i = 1: size(jobman.node_module_color, 1)
            a(i) = size(jobman.node_module_color{i}, 2);
        end
    else
        a = 0;
    end
end
    
for i = 1: size(node, 1)
    if jobman.node_size_eq == 1
%         h_size = findobj(findobj(0, 'Tag', 'Visual'), 'Tag', 'node_size_edit');
%         jobman.node_size = get(h_size, 'String')
        r = jobman.node_size;
    else
        r = node(i, 4);
    end
    [x,y,z]=sphere(100);
    x = x.*r + node(i, 1);
    y = y.*r + node(i, 2);
    z = z.*r + node(i, 3);
    Node = mesh(x, y, z, 'Edgecolor', 'none');
    if jobman.node_same_color == 1
        node_color = color;
    else
        row_num = size(node, 2);
        if row_num == 5 && module_value == 1
            node_color = jobman.node_module_color{node(i, 5)};
        elseif row_num > 5 && row_num < 8 && module_value == 1
            error('Please check the color defined in node text.')
        elseif row_num == 8 
            if sum(a) < 3*size(jobman.node_module_color, 1) && sum(a) >= 3 
                error('Maybe some modules color undefined.')
            elseif sum(a) == 3*size(jobman.node_module_color, 1)
                node_color = jobman.node_module_color{node(i, 5)};
            else
                node_color = [node(i, 6), node(i, 7), node(i, 8)];
            end
        end
    end      
    material('dull');
%     eval(['material ','dull',';'])
    set(Node, 'Facecolor', node_color);
    set(Node,'EdgeAlpha',0)
    if jobman.label == 1 
        if isempty(label)
            error('Please define the node labels in node text.')
        else
            if (jobman.brain_halves == 1 && (jobman.select_view == 2 || jobman.select_view == 5)) || ...
                    (jobman.whole_brain == 1 && jobman.select_view == 2)
                x = node(i, 1) - r - 2;
                y = node(i, 2) + r + 2;
                z = node(i, 3) + r + 2;
            elseif (jobman.brain_halves == 1 && (jobman.select_view == 3 || jobman.select_view == 4)) || ...
                    (jobman.whole_brain == 1 && jobman.select_view == 3)
                x = node(i, 1) - r - 2;
                y = node(i, 2) - r - 2;
                z = node(i, 3) + r + 2;
            elseif jobman.whole_brain == 1 && jobman.select_view == 4
                x = node(i, 1) - r - 2;
                y = node(i, 2) + r + 2;
                z = node(i, 3) + r + 2;
            elseif jobman.whole_brain == 1 && jobman.select_view == 5
                x = node(i, 1) + r + 2;
                y = node(i, 2) - r - 2;
                z = node(i, 3) + r + 2;
            else
                x = node(i, 1) + r + 2;
                y = node(i, 2) - r;
                z = node(i, 3) + r + 3;
            end
            text(x, y, z, label{i}, 'FontWeight', 'Bold')
        end
    end   
end
axis('tight') ;
lighting('phong');
