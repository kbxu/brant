function [vertices, faces] = load_surface_new(surface_file)

[o1, o2, ext] = fileparts(surface_file); %#ok<ASGLU>
if strcmpi(ext, '.txt')
    fid = fopen(surface_file);
    frewind(fid)
    num_vertex = fscanf(fid, '%d', 1);
    vertices = fscanf(fid, '%f', [3, num_vertex])';
    num_faces = fscanf(fid, '%d', 1);
    faces = fscanf(fid, '%d', [3, num_faces])';
    fclose(fid);
elseif any(strcmpi(ext, {'.img', '.nii'}))
    surface_nii = load_nii(surface_file);
    mask_tmp = smooth3(surface_nii.img > 0.5);
    surf_org = [surface_nii.hdr.hist.srow_x(4), surface_nii.hdr.hist.srow_y(4), surface_nii.hdr.hist.srow_z(4)];
    surf_pixdim = surface_nii.hdr.dime.pixdim(2:4);

    N_nbr = 1;
    [xx,yy,zz] = ndgrid(-1 * N_nbr:N_nbr);
    nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= N_nbr;

    V_ero = imerode(mask_tmp, nhood);
    V_edge = mask_tmp - V_ero;
    [faces, vertices_coord_tmp] = isosurface(V_edge, .2);
    vertices_coord_tmp = vertices_coord_tmp - 1;
    vertices(:,2) = vertices_coord_tmp(:,1) * surf_pixdim(2) + surf_org(2);
    vertices(:,1) = vertices_coord_tmp(:,2) * surf_pixdim(1) + surf_org(1);
    vertices(:,3) = vertices_coord_tmp(:,3) * surf_pixdim(3) + surf_org(3);

%     write_surface('D:\Program Files\matlab_toolbox\Brant\brant_surface\monkey.txt', faces, vertices);
end