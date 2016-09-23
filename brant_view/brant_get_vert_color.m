function [CData, c_map, cbr] = brant_get_vert_color(vol, vertices_coord, colorinfo)
% get colormap for vertices

% vol_h = spm_vol(vol);
% b_box = spm_get_bbox(vol);
% vol_int = spm_read_vols(vol_h);
% step_len = diag(vol_h.mat);
% b_box = bsxfun(@times, b_box, sign(step_len(1:3))');
% [X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));


vol_data = load_nii_mod(vol);
vol_int = vol_data.img;
% from brant_get_XYZ
s_mat = [vol_data.hdr.hist.srow_x; vol_data.hdr.hist.srow_y; vol_data.hdr.hist.srow_z];
if s_mat(1, 1) < 0
    s_mat(1, :) = s_mat(1, :) * -1;
end
size_data = size(vol_data.img);
step_len = diag(s_mat(1:3, 1:3));
b_box = [s_mat(:, 4), s_mat(:, 4) + step_len .* (size_data - 1)']';
[X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));

vol_int = permute(vol_int, [2, 1, 3]);
vol_int(~isfinite(vol_int)) = 0;
if colorinfo.discrete == 0
    vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), vertices_coord(:, 3));
else
    vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), vertices_coord(:, 3), 'Nearest');
end

max_abs = max(abs(vq(:)));
thres_str = strrep(colorinfo.vol_exp, 'vol', 'vq');
vol_3d_mask = eval(thres_str);
vq(~vol_3d_mask) = 0;
    
min_vq = min(setdiff(vq, 0));
max_vq = max(setdiff(vq, 0));
    


if colorinfo.discrete == 0
    
    color_N = 129;
    c_map = jet(color_N);
    c_map(49:65, 3) = 1;
    c_map(49:65, 1) = linspace(0, 1, 17);
    c_map(65:82,1) = 1;
    c_map(65:82,3) = linspace(1, 0, 18);
    
%     lin_cmap_neg = linspace(-1*max_abs, 0, floor(color_N / 2) + 1);
%     lin_cmap_pos = linspace(0, max_abs, floor(color_N / 2) + 1);

    
    thr = max_abs / color_N * 8;
    
    if min_vq > 0
%         c_map = c_map_tmp(65:end, :);
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, [0, min_vq, max_vq], 'Nearest');
        c_map(tick_cbr(1):tick_cbr(2), :) = 1;
        c_map(1:tick_cbr(1), :) = 1;
        c_map(tick_cbr(3):end, :) = 1;
        
        if abs(min_vq) > thr
            tick_vec = [0, min_vq, max_vq];
        else
            tick_vec = [0, max_vq];
        end
        
        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.3g'), tick_vec, 'UniformOutput', false);
    elseif max_vq < 0
%         c_map = c_map_tmp(1:65, :);
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, [min_vq, max_vq, 0], 'Nearest');
        c_map(tick_cbr(2):tick_cbr(3), :) = 1;
        c_map(tick_cbr(3):end, :) = 1;
        c_map(1:tick_cbr(1), :) = 1;
        
        if abs(max_vq) > thr
            tick_vec = [min_vq, max_vq, 0];
        else
            tick_vec = [max_vq, 0];
        end
        
        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.3g'), tick_vec, 'UniformOutput', false);
    else
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        max_neg_vq = max(vq(vq < 0));
        min_pos_vq = min(vq(vq > 0));
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, [min_vq, max_neg_vq, 0, min_pos_vq, max_vq], 'Nearest');
        c_map(tick_cbr(2):tick_cbr(4), :) = 1;
        c_map(1:tick_cbr(1), :) = 1;
        c_map(tick_cbr(5):end, :) = 1;
        
        tick_vec = 0;
        tick_neg = [min_vq, max_neg_vq];
        tick_pos = [min_pos_vq, max_vq];
        
        if abs(max_neg_vq) > thr
            tick_vec = [max_neg_vq, tick_vec];
        end
        
        if abs(diff(tick_neg)) > thr
            tick_vec = [min_vq, tick_vec];
        end
        
        if abs(min_pos_vq) > thr
            tick_vec = [tick_vec, min_pos_vq];
        end
        
        if abs(diff(tick_pos)) > thr
            tick_vec = [tick_vec, max_vq];
        end
        
        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.3g'), tick_vec, 'UniformOutput', false);
    end   
    cbr.caxis = [1, 129];
else
    uniq_color = setdiff(vol_int, 0);
    color_N = numel(uniq_color);
    
    c_map = hsv(color_N);
    rand_ind = randperm(color_N, color_N);
    c_map = [1, 1, 1; c_map(rand_ind, :)];
    
    CData = interp1([0; uniq_color], 1:(color_N+1), vq, 'Nearest');
    
    min_pos_vq = min(vq(vq > 0));
    tick_cbr = interp1([0; uniq_color], 1:(color_N+1), [0, min_pos_vq, max_vq], 'Nearest');
    c_map(min(tick_cbr(3)+1,color_N):end, :) = 1;
    c_map(1:max(tick_cbr(2)-1, 1), :) = 1;
    
    thr = max_abs / color_N * 8;
    
    if abs(min_pos_vq) > thr && (max_vq - min_pos_vq) > thr
        tick_vec = [0, min_pos_vq, max_vq];
    else
        tick_vec = [0, max_vq];
    end
    
    
    
    
    cbr.xtick = interp1([0; uniq_color], 1:(color_N+1), tick_vec, 'Nearest');
    cbr.xlabel = arrayfun(@(x) num2str(x, '%.3g'), tick_vec, 'UniformOutput', false);
    
    cbr.caxis = [1, color_N+1];
end