function csv_cell = brant_read_csv(filename)

csv_data = importdata(filename, '\n');
csv_parse_tmp = regexp(csv_data, ',', 'split');
csv_cell = cat(1, csv_parse_tmp{:});
csv_cell = strtrim(csv_cell);