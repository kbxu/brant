function [color, color_on] = computeColor(handles)

% initialize color, color_on, threshold and colorbar definition
color = ones(size(handles.vertices_intensity, 1), 3) * handles.bg_grey;
color_on = zeros(size(handles.vertices_intensity, 1), 1);
if handles.if_threshold
    threshold = handles.threshold;
else
    threshold = 0;
end
colorbar_def = 64;

% check data_type
if strcmp(handles.data_type, 'binary values')
    switch handles.color_val
        case 1
            vol_col = [handles.bg_grey handles.bg_grey handles.bg_grey];
        case 2
            vol_col = [1 1 0];
        case 3
            vol_col = [1 0 1];
        case 4
            vol_col = [0 1 1];
        case 5
            vol_col = [1 0 0];
        case 6
            vol_col = [0 1 0];
        case 7
            vol_col = [0 0 1];
    end
    % ---set colorbar---
    axes(handles.axes5);
    set(gca, 'visible', 'on');
    set(gca, 'Color', vol_col);
    set(gca,'XColor', vol_col','YColor', vol_col);
   
    % ---compute surface color---
    ind_to_color = find(handles.vertices_intensity > threshold);
    color(ind_to_color, :) = [ones(length(ind_to_color), 1) * vol_col(1), ones(length(ind_to_color), 1) * vol_col(2), ones(length(ind_to_color), 1) * vol_col(3)];
    color_on(ind_to_color) = 1;
elseif strcmp(handles.data_type, 'discrete positive values') || strcmp(handles.data_type, 'continuous positive values')
    switch handles.color_val
        case 1
            vol_col = ones(colorbar_def, 3) * handles.bg_grey;
        case 2
            vol_col = autumn;
            colormap autumn;
        case 3
            vol_col = hot;
            colormap hot;
            
            vol_col = jet;
            colormap jet;
        case 4
            vol_col = HSV;
            colormap HSV;
        case 5
            vol_col = lines;
            colormap lines;
    end
    % ---set colorbar---
    axes(handles.axes5);
    set(gca, 'visible', 'on');
    colorbar_vec = 1:colorbar_def;
    imagesc(colorbar_vec);
    % find highest intensity
    max_int = max(handles.vertices_intensity);
    % set tick values
    lowest = num2str(threshold, 2);
    middle = num2str(max_int / 2, 2);
    highest = num2str(max_int, 2);
    set(gca, 'XTickLabel', {lowest; middle; highest}, 'XTick', [1, round(colorbar_def / 2), colorbar_def], 'YTickLabel',[],'YTick',[])
    
    % ---compute surface color---
    ind_to_color = find(handles.vertices_intensity > threshold);
    % normalize intensities%%% 
% % %     norm_int = ceil(handles.vertices_intensity / (max_int-threshold) * colorbar_def);
% normalize intensities%%% revised by Yong Liu 
norm_int = ceil(handles.vertices_intensity /max_int * colorbar_def);
    color(ind_to_color, :) = vol_col(norm_int(ind_to_color), :);
    color_on(ind_to_color) = 1;
elseif strcmp(handles.data_type, 'positive and negative values')
    switch handles.color_val
        case 2
            % ---set colorbar---
            % create a mixed colorbar(negative and positive)
            colorbar_vec = 1:colorbar_def;
            cwinter = flipud(winter(floor(colorbar_def / 2)));
            cautumn = autumn(ceil(colorbar_def / 2));
            colormap([cwinter; cautumn]);
            % find lowest and highest intensities
            min_int = min(handles.vertices_intensity);
            max_int = max(handles.vertices_intensity);
            lowest = num2str(min_int, 2);
            highest = num2str(max_int, 2);
            % set negative colorbar
            axes(handles.axes7);
            set(gca, 'visible', 'on');
            imagesc(colorbar_vec);
            set(gca, 'XTickLabel', {lowest}, 'XTick', [1], 'YTickLabel',[],'YTick',[], 'XLim', [1, floor(colorbar_def / 2)]);
            % set positive colorbar
            axes(handles.axes8);
            set(gca, 'visible', 'on');
            imagesc(colorbar_vec);
            set(gca, 'XTickLabel', {highest}, 'XTick', [colorbar_def], 'YTickLabel',[],'YTick',[], 'Xlim', [floor(colorbar_def / 2) + 1, colorbar_def]);
            
            % ---compute surface color---
            % compute negative colors
            neg_ind = find(handles.vertices_intensity < threshold * (-1));
            norm_neg = ceil((handles.vertices_intensity(neg_ind) + ones(length(neg_ind), 1) * threshold) / (min_int + threshold) * floor(colorbar_def / 2));
            cwinter = flipud(cwinter);
            color(neg_ind, :) = cwinter(norm_neg, :);
            color_on(neg_ind) = 1;
            % compute positive colors
            pos_ind = find(handles.vertices_intensity > threshold);
            norm_pos = ceil((handles.vertices_intensity(pos_ind) - ones(length(pos_ind), 1) * threshold) / (max_int - threshold) * ceil(colorbar_def / 2));
            color(pos_ind, :) = cautumn(norm_pos, :);
            color_on(pos_ind) = 1;
    end
end