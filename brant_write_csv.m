function brant_write_csv(filename, csv_cell)
% input filename, csv_cell
% filename: output filename
% csv_cell: csv data stored in cell array

fid = fopen(filename, 'wt');

for m = 1:size(csv_cell, 1)
    for n = 1:size(csv_cell, 2)
        if isnumeric(csv_cell{m, n})
            tmp_cell = num2str(csv_cell{m, n});
        else
            tmp_cell = csv_cell{m, n};
        end
        if n == size(csv_cell, 2)
            fprintf(fid, '%s\n', tmp_cell);
        else
            fprintf(fid, '%s,', tmp_cell);
        end
    end
end

fclose(fid);