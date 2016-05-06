function demo_aal_nodes

brat_path = fileparts(which('brat'));

v = spm_vol(fullfile(brat_path, 'template', 'aal.nii'));
[v_data, v_xyz] = spm_read_vols(v);

aal_vals = setdiff(unique(v_data), 0);

cen_ind = zeros(numel(aal_vals), 3);
roi_size = zeros(numel(aal_vals));
for m = 1:numel(aal_vals)
    v_ind = v_data == aal_vals(m);
    for n = 1:3
        cen_ind(m, n) = mean(v_xyz(n, v_ind));
    end
    roi_size(m) = sum(v_ind(:));
end



roi_size = roi_size / mean(roi_size) * 2;

fp = fopen(fullfile(brat_path, 'template', 'aal.nii.lut'));
lut_tmp = fread(fp, inf, 'uint8');
fclose(fp);

color_map = reshape(lut_tmp, length(lut_tmp) / 3, 3) / 255;

dlmwrite(fullfile(brat_path, 'template', 'aal_nodes.txt'), [cen_ind, roi_size, ones(numel(aal_vals), 1), color_map(1:numel(aal_vals), :)]);