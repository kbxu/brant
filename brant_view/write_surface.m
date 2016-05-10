function write_surface(surf_name, faces, vertices_coord)

num_vertices = size(vertices_coord, 1);
num_faces = size(faces, 1);

fid = fopen(surf_name, 'wt');
fprintf(fid, '%d\n', num_vertices);
for m = 1:size(vertices_coord, 1)
    for n = 1:size(vertices_coord, 2)
        fprintf(fid, '%f\t', vertices_coord(m, n));
    end
    fprintf(fid, '\n');
end
fprintf(fid, '%d\n', num_faces);
for m = 1:size(faces, 1)
    for n = 1:size(faces, 2)
        fprintf(fid, '%d\t', faces(m, n));
    end
    fprintf(fid, '\n');
end
fclose(fid);