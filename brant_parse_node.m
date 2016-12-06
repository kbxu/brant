function node_out = brant_parse_node(node_file, varargin)

if nargin == 1
    check_field_ind = 1;
else
    check_field_ind = varargin{1};
end

% expected title in an excel table
all_fns = {'x', 'y', 'z', 'size', 'module', 'r', 'g', 'b', 'label', 'index'};
tbl_raw = brant_read_csv(node_file);
titles = tbl_raw(1, :);
tbl_data_cell = tbl_raw(2:end, :);

num_node = size(tbl_data_cell, 1);
fn_inds = cellfun(@(x) find(strcmpi(x, titles), 1, 'first'), all_fns, 'UniformOutput', false);
fn_ept = cellfun(@isempty, fn_inds);

for m = 1:numel(all_fns)
    if (fn_ept(m) == 0)
        if any(strcmpi(all_fns{m}, {'module', 'label'}))
            node_out.(all_fns{m}) = tbl_data_cell(:, fn_inds{m});
        else
            node_out.(all_fns{m}) = cellfun(@str2double, tbl_data_cell(:, fn_inds{m}));
        end
    end
end

if check_field_ind == 1
    % check input
    for m = 1:numel(all_fns)
        if ~isfield(node_out, all_fns{m})
            switch all_fns{m}
                case {'x', 'y', 'z'}
                    error('Column of %s is missing!', all_fns{m});
                case 'module'
                    node_out.module = repmat({'module 1'}, num_node, 1);
                otherwise
                    % never mind
            end
        end
    end
end