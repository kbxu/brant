function  [faces, vertices_coord] = load_surface(surf_name)

ratio = 1.0;
fid = fopen(surf_name);
num_vertices = fscanf(fid, '%f', 1);
vertices_coord = fscanf(fid, '%f', [3, num_vertices]);
vertices_coord = vertices_coord';
vertices_coord = ratio.*vertices_coord;
num_faces = fscanf(fid, '%f', 1);
faces = fscanf(fid, '%f', [3, num_faces]);
faces = faces';
fclose(fid);
