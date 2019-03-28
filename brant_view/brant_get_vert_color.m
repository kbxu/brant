function [CData, c_map, cbr] = brant_get_vert_color(vol, vertices_coord, colorinfo)
% get colormap for vertices

% vol_h = spm_vol(vol);
% b_box = spm_get_bbox(vol);
% vol_int = spm_read_vols(vol_h);
% step_len = diag(vol_h.mat);
% b_box = bsxfun(@times, b_box, sign(step_len(1:3))');
% [X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));

if isfield(colorinfo, 'rad_mm')
    rad_mm = colorinfo.rad_mm;
else
    rad_mm = [];
end

vol_data = load_nii_mod(vol);
vol_int = single(vol_data.img);
% from brant_get_XYZ
s_mat = [vol_data.hdr.hist.srow_x; vol_data.hdr.hist.srow_y; vol_data.hdr.hist.srow_z];
if (s_mat(1, 1) < 0)
    s_mat(1, :) = s_mat(1, :) * -1;
end
size_data = size(vol_data.img);
step_len = diag(s_mat(1:3, 1:3));
b_box = [s_mat(:, 4), s_mat(:, 4) + step_len .* (size_data - 1)']';
[X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));

vol_int = permute(vol_int, [2, 1, 3]);
vol_int(~isfinite(vol_int)) = 0;

% maximum neighbour interpolation with spot light sphere
vox_len = diag(abs(s_mat(:, 1:3)));
if ~isempty(rad_mm) && all(rad_mm >= vox_len)
    rad_N = ceil(rad_mm ./ vox_len);
    [Xmm, Ymm, Zmm] = meshgrid(-1*rad_N(1):rad_N(1), -1*rad_N(2):rad_N(2), -1*rad_N(3):rad_N(3));
    vox_inds_tmp = [Xmm(:) * vox_len(1), Ymm(:) * vox_len(2), Zmm(:) * vox_len(3)];
    dist_vox = arrayfun(@(x) norm(vox_inds_tmp(x, :), 2), 1:size(vox_inds_tmp, 1)) <= rad_mm;
%     dist_vox = pdist2([0, 0, 0], vox_inds_tmp) <= rad_mm;
    vol_int = imdilate(vol_int, reshape(dist_vox, 2 * rad_N' + 1)); % find maximum in nearnest neighbour
end

% if (colorinfo.discrete == 0)
%     vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), vertices_coord(:, 3));
% else
%     vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), vertices_coord(:, 3), 'Nearest');
% end

thres_str = strrep(colorinfo.vol_exp, 'vol', 'vol_int');
vol_int = vol_int .* eval(thres_str);

vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), vertices_coord(:, 3), 'Nearest');

% % max_abs = max(abs(vq(:)));
% thres_str = strrep(colorinfo.vol_exp, 'vol', 'vq');
% vol_3d_mask = eval(thres_str);
% vq(~vol_3d_mask) = 0;
    
% min_vq = min(setdiff(vq, 0));
% max_vq = max(setdiff(vq, 0));
min_vq = min(setdiff(vol_int(:), 0));
max_vq = max(setdiff(vol_int(:), 0));
max_abs = max(abs(vol_int(:)));

if (colorinfo.discrete == 0)
    
    color_N = 129;
    
%     negative_clip = 40;
    c_map_pos = hot(fix(color_N/2));
    c_map = [c_map_pos(:,3:-1:1); ones(1, 3); c_map_pos(end:-1:1,:)];
    
    
%     clip = 17;
%     color_N_half = ceil((color_N + 1) / 4);
%     c_map = winter(color_N);
%     c_map((color_N_half - clip):color_N_half, 3) = 1;
%     c_map((color_N_half - clip):color_N_half, 1) = linspace(0, 1, clip+1);
%     c_map(color_N_half:(color_N_half + clip), 1) = 1;
%     c_map(color_N_half:(color_N_half + clip), 3) = linspace(1, 0, clip+1);
    
%     c_map = c_map / 2;
%     unmask below one line if you want to visualize positive color in blue
%     c_map=c_map(end:-1:1,:);

%     lin_cmap_neg = linspace(-1*max_abs, 0, floor(color_N / 2) + 1);
%     lin_cmap_pos = linspace(0, max_abs, floor(color_N / 2) + 1);

    thr = max_abs / color_N * 20;
%     thr = 1e-2;
    
    if (min_vq > 0)
        % only positive
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, sort(unique([0, min_vq, max_vq])), 'Nearest');
        if min_vq ~= max_vq
            if (abs(min_vq) > thr)
                tick_vec = [0, min_vq, max_vq];
            else
                tick_vec = [0, max_vq];
            end
        else       
            tick_vec = [0, max_vq];
        end
        
        % set -inf to minimum positive to white
        if tick_cbr(2)-1 >= 1
            c_map(1:tick_cbr(2)-1, :) = 1;
        end

        % set maximum positive to inf to white
        if (tick_cbr(end)+1) <= color_N
            c_map(tick_cbr(end)+1:end, :) = 1;
        end
        
        if colorinfo.clip_colorbar == 1
            idx = sum(c_map, 2) < 3;
            c_map_pos_clip = hot(sum(idx));
            c_map(idx, :) = c_map_pos_clip(end:-1:1, :);
        end
            
        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.2g'), tick_vec, 'UniformOutput', false);
    elseif (max_vq < 0)
        % only negative value
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, sort(unique([min_vq, max_vq, 0])), 'Nearest');
        if min_vq ~= max_vq
            if (abs(max_vq) > thr)
                tick_vec = [min_vq, max_vq, 0];
            else
                tick_vec = [max_vq, 0];
            end
        else
            % only one value      
            tick_vec = [min_vq, 0];
        end
        
        % set maximum negative to inf to white
        if tick_cbr(end-1)+1 <= color_N
            c_map(tick_cbr(end-1)+1:end, :) = 1;
        end
            
        % set -inf to minimum negative to white
        if tick_cbr(1)-1 >= 1
            c_map(1:tick_cbr(1)-1, :) = 1;
        end
        
        if colorinfo.clip_colorbar == 1
            idx = sum(c_map, 2) < 3;
            c_map_pos_clip = hot(sum(idx));
            c_map(idx, :) = c_map_pos_clip(:, 3:-1:1);
        end

        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.2g'), tick_vec, 'UniformOutput', false);
    else
        % show negative and positive color
        CData = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, vq, 'Nearest');
        
        max_neg_vq = max(vq(vq < 0));
        min_pos_vq = min(vq(vq > 0));
        
        tick_cbr = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, sort(unique([min_vq, max_neg_vq, 0, min_pos_vq, max_vq])), 'Nearest');
        
        % set -inf to min_vq to white
        if (tick_cbr(1)-1) >= 1
            c_map(1:tick_cbr(1)-1, :) = 1;
        end
            
        % set max_neg_vq to min_pos_vq to white
        if isempty(max_neg_vq)
            if (tick_cbr(1)+1) <= tick_cbr(3)-1
                c_map(tick_cbr(1)+1:tick_cbr(3)-1, :) = 1;
            end
        elseif (min_vq == max_neg_vq)
            if (tick_cbr(1)+1) <= tick_cbr(3)-1
                c_map(tick_cbr(1)+1:tick_cbr(3)-1, :) = 1;
            end
        else
            if (tick_cbr(2)+1) <= tick_cbr(4)-1
                c_map(tick_cbr(2)+1:tick_cbr(4)-1, :) = 1;
            end
        end
        
        % set max_vq to inf to white
        if (tick_cbr(end)+1) <= color_N
            c_map(tick_cbr(end)+1:end, :) = 1;
        end
        
        
        if colorinfo.clip_colorbar == 1
            idx = sum(c_map, 2) < 3;
            len_idx = length(idx);
            
            pos_idx = [true(fix(len_idx/2), 1); false(len_idx-fix(len_idx/2), 1)];
            
            c_map_pos_clip = hot(sum(pos_idx & idx));
            c_map(pos_idx & idx, :) = c_map_pos_clip(:, 3:-1:1);
            
            c_map_pos_clip = hot(sum(~pos_idx & idx));
            c_map(~pos_idx & idx, :) = c_map_pos_clip(end:-1:1, :);
        end
        

        tick_vec = 0;
        tick_neg = [min_vq, max_neg_vq];
        tick_pos = [min_pos_vq, max_vq];
        
        if (abs(max_neg_vq) > thr)
            tick_vec = [max_neg_vq, tick_vec];
        end
        
        if (abs(diff(tick_neg)) > thr)
            tick_vec = [min_vq, tick_vec];
        end
        
        if (abs(min_pos_vq) > thr)
            tick_vec = [tick_vec, min_pos_vq];
        end
        
        if (abs(diff(tick_pos)) > thr)
            tick_vec = [tick_vec, max_vq];
        end
        
        cbr.xtick = interp1(linspace(-1*max_abs, max_abs, color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%.2g'), tick_vec, 'UniformOutput', false);
    end   
    cbr.caxis = [1, color_N];
else
    uniq_color = setdiff(vol_int(:), 0);
    color_N = numel(uniq_color);
    
    c_map = hsv(color_N);
    rand_ind = randperm(color_N, color_N);
    c_map = [1, 1, 1; c_map(rand_ind, :)];
    
    CData = interp1([0; uniq_color], 1:(color_N+1), vq, 'Nearest');
    
    min_pos_vq = min(vq(vq > 0));
    tick_cbr = interp1([0; uniq_color], 1:(color_N+1), [0, min_pos_vq, max_vq], 'Nearest');
    if (tick_cbr(3)+1) <= color_N
        c_map(tick_cbr(3)+1:end, :) = 1;
    end
    c_map(1:max(tick_cbr(2)-1, 1), :) = 1;
    
    thr = max_abs / color_N * 8;
    
    if ((abs(min_pos_vq) > thr) && ((max_vq - min_pos_vq) > thr))
        tick_vec = [0, min_pos_vq, max_vq];
    else
        tick_vec = [0, max_vq];
    end
    
    cbr.xtick = interp1([0; uniq_color], 1:(color_N+1), tick_vec, 'Nearest');
    cbr.xlabel = arrayfun(@(x) num2str(x, '%d'), tick_vec, 'UniformOutput', false);
    
    cbr.caxis = [1, color_N+1];
end