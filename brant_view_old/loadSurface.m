function [vertices, faces] = loadSurface(val)

switch val
    case 1
        fileID = 0;
        vertices = [];
        faces = [];
    case 2
        fileID = fopen('smoothed.txt');
    case 3
        fileID = fopen('standard.txt');
    case 4
        fileID = fopen('standard_withCC.txt');
end

if fileID
    C = textscan(fileID, '%f');
    column_mat = C{1, 1};
    num_vertex = column_mat(1);
    vertices = reshape(column_mat(2:3 * num_vertex + 1), 3, num_vertex)';
    num_faces = column_mat(1 + 3 * num_vertex + 1);
    faces = reshape(column_mat(1 + 3 * num_vertex + 2:end), 3 , num_faces)';
end

fclose(fileID);