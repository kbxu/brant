function node_out = brant_parse_node(node_file)

% expected title in an excel table
all_fns = {'x', 'y', 'z', 'size', 'module', 'r', 'g', 'b', 'label'};

if strcmpi(node_file(end-3:end), '.txt')
    
    try
        node_infos = load(node_file);
        n_col_node = size(node_infos, 2);
        
        if n_col_node == 10
            use_ind = node_infos(:, 10) == 1;
            node_infos = node_infos(use_ind, :);
            n_col_node = 9;
            
            if isempty(node_infos)
                error('All nodes are excluded by the 10th column!')
            end
        end
        
        for m = 1:min(numel(all_fns), n_col_node)
            node_out.(all_fns{m}) = node_infos(:, m);
        end

        num_node = size(node_infos, 1);
    catch
        node_strs_tmp = importdata(node_file, '\n');
        node_strs_tmp2 = cellfun(@(x) regexp(x, '([.]?[\S]+)[\t ]*', 'tokens'), node_strs_tmp, 'UniformOutput', false);
        node_strs_tmp3 = cat(1, node_strs_tmp2{:});
        node_strs = cellfun(@(x) x{1}, node_strs_tmp3, 'UniformOutput', false);
        n_col_node = size(node_strs, 2);
        len_strs = cellfun(@numel, node_strs_tmp2);
        
        if n_col_node == 10
            use_ind = str2double(node_strs(:, 10)) == 1;
            node_strs = node_strs(use_ind, :);
            n_col_node = 9;
            
            if isempty(node_strs)
                error('All nodes are excluded by the 10th column!')
            end
        end
        
        num_node = size(node_strs, 1);
        
        for m = 1:min(numel(all_fns), n_col_node)
            if any(m == [5, 9])
                node_out.(all_fns{m}) = node_strs(:, m);
            else
                node_out.(all_fns{m}) = str2double(node_strs(:, m));
            end
        end
    end
    
    if isfield(node_out, 'module')
        if isnumeric(node_out.module)
            node_out.module = arrayfun(@num2str, node_out.module, 'UniformOutput', false);
        end
    end
else

    [tbl_num, tbl_txt, tbl_raw] = xlsread(node_file); %#ok<ASGLU>
    titles = tbl_txt(1, :);
    tbl_data_cell = tbl_raw(2:end, :);
    
    
    use_ind = find(strcmpi(titles, 'use'), 1, 'first'); %cellfun(@(x) find(strcmpi(x, 'use')), titles_fn, 'UniformOutput', false);
    if ~isempty(use_ind)
        use_ind_tbl = cat(1, tbl_data_cell{:, use_ind(1)}) == 1;
        tbl_data_cell = tbl_data_cell(use_ind_tbl, :);
        
        if isempty(tbl_data_cell)
            error('All nodes are excluded by the use column!')
        end
    end
    
    num_node = size(tbl_data_cell, 1);
    fn_inds = cellfun(@(x) find(strcmpi(x, titles), 1, 'first'), all_fns, 'UniformOutput', false);
    fn_ept = cellfun(@isempty, fn_inds);

%     n_col_node = numel(titles);
    for m = 1:numel(all_fns)
        if fn_ept(m) == 0
            if any(strcmpi(all_fns{m}, {'module', 'label'}))
                data_tmp = tbl_data_cell(:, fn_inds{m});
                if isnumeric(data_tmp{1})
                    data_tmp = cellfun(@num2str, data_tmp, 'UniformOutput', false);
                end
                if ~iscell(data_tmp)
                    data_tmp = cellstr(data_tmp);
                end
                node_out.(all_fns{m}) = cellfun(@strtrim, data_tmp, 'UniformOutput', false);
            else
                tbl_data_tmp = tbl_data_cell(:, fn_inds{m});
                if isnumeric(tbl_data_tmp{1})
                    node_out.(all_fns{m}) = cat(1, tbl_data_tmp{:});
                elseif ischar(tbl_data_tmp{1})
                    node_out.(all_fns{m}) = cellfun(@str2num, tbl_data_tmp);
                else
                    error('Unknow type of data');
                end
            end
        end
    end
end

% don't display selected node labels
% if isfield(node_out, 'label')
%     label_nan = cellfun(@isempty, node_out.label);
%     node_out.label(label_nan) = '';
% end


% check input
for m = 1:numel(all_fns)
    if ~isfield(node_out, all_fns{m})
        switch all_fns{m}
            case {'x', 'y', 'z'}
                error('Column of %s is missing!', all_fns{m});
            case 'module'
                node_out.module = repmat({'module 1'}, num_node, 1);
%             case 'size'
%                 node_out.size = ones(num_node, 1);
%             case {'r', 'g', 'b'}
%                 rgb_ind = strcmpi(all_fns{m}, 'r');
%                 node_out.(all_fns{m}) = ones(num_node, 1) * rgb_ind;
%             case 'label'
%                 node_out.label = cell(num_node, 1);
            otherwise
                % never mind
        end
    end
end
