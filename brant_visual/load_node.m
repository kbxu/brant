function [node_coord, label] = load_node(node)

try
    node_coord = load(node);
    label = [];
catch
    node_strs_tmp = importdata(node, '\n');
    node_strs_tmp2 = cellfun(@(x) regexp(x, '\s', 'split'), node_strs_tmp, 'UniformOutput', false);
    node_strs = cat(1, node_strs_tmp2{:});
    
    len_strs = cellfun(@numel, node_strs_tmp2);
    if all(len_strs == 9)
        label = node_strs(:, 9);
        node_coord = str2double(node_strs(:, 1:8));
    else
        error('Please custom node sizes!')
    end
end

% try
%     node_coord = load(node);
%     label = [];
% catch
%     fid = fopen(node, 'r');
%     tline = fgetl(fid);
%     temp = 1: length(tline);
%     space_ind = strfind(tline, ' ');
%     numeric_ind = setdiff(temp, space_ind);
%     numeric_ind_diff = diff(numeric_ind);
%     numeric_col = numel(find(numeric_ind_diff ~= 1));
%     frewind(fid)
%     i = 0;
%     while ~feof(fid)
%         fscanf(fid, '%f', numeric_col);
%         i = i + 1;
%         fscanf(fid, '%s', 1);
%     end
%     node_coord = zeros(i-1, numeric_col);
%     frewind(fid)
%     for i = 1: size(node_coord, 1)
%         node_coord(i, :) = fscanf(fid, '%f', numeric_col);
%         label{i} = fscanf(fid, '%s', 1);
%     end
%     fclose(fid);
% end
%     row_num = size(node_coord, 2);
%     if row_num<=3
%         error('Please custom node sizes.')
%     end
% end
