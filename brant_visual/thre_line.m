function [sub_1, sub_2, edge_fc, index] = thre_line(jobman, node_coord)
edge_fc = load(jobman.edge);
h_obj = findobj(0, 'Tag', 'threshold_str_edit');
jobman.threshold_str = get(h_obj, 'String');
if ~isempty(jobman.threshold_str)
    ind = strfind(jobman.threshold_str, 'edge');
    if size(ind, 2) == 2
        
        if strfind(jobman.threshold_str, '&&') ~= 0
            judge_ind = strfind(jobman.threshold_str, '&&');
            str = ['edge_fc', jobman.threshold_str(ind(1)+4:judge_ind -1), '&edge_fc', jobman.threshold_str(ind(2)+4:end)];
        else
            judge_ind = strfind(jobman.threshold_str, '||');
            str = cell(2, 1);
            str{1} = ['edge_fc', jobman.threshold_str(ind(1)+4:judge_ind -1)];
            str{2} = ['edge_fc', jobman.threshold_str(ind(2)+4:end)];
        end
    else
        str = ['edge_fc', jobman.threshold_str(ind(1)+4:end)];
    end
    if size(str, 1) == 1
        index = find(eval(str));
    else
        index = union(find(eval(str{1})), find(eval(str{2})));
    end
    [sub_1, sub_2] = ind2sub(size(edge_fc), index);
else
    index = find(edge_fc>0&edge_fc<=1);
    [sub_1, sub_2] = ind2sub(size(edge_fc), index);
end
%%%%%% remove duplicate edges
edge_ind = [sub_1, sub_2];
temp = [sub_1+sub_2, sub_1.*sub_2];
[C, cc, dd] = unique(temp, 'rows');
edge_ind = edge_ind(cc, :);
sub_1 = edge_ind(:, 1);
sub_2 = edge_ind(:, 2);