function csv_cell = brant_read_csv(filename, varargin)

if nargin == 1
    sep_str = '[,;]';
else
    sep_str = varargin{1};
end

csv_data = importdata(filename, '\n');
csv_parse_tmp = regexp(csv_data, sep_str, 'split');
csv_cell = cat(1, csv_parse_tmp{:});
csv_cell = strtrim(csv_cell);