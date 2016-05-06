function [color, color_on] = sumColor(color_last, color_last_on, color_old, color_old_on, bg_grey, if_old)
% initialize output values
color = ones(size(color_last)) * bg_grey;
color_on = zeros(size(color_last_on));

if if_old
    for i = 1:size(color_last, 1)
        if color_last_on(i) == 0
            color(i, :) = color_old(i, :);
        elseif color_old_on(i) == 0
            color(i, :) = color_last(i, :);
        else
            color(i, :) = [mean([color_last(i, 1), color_old(i, 1)]) mean([color_last(i, 2), color_old(i, 2)]) mean([color_last(i, 3), color_old(i, 3)])];
        end
    end
    color_on(color_last_on == 1) = 1;
    color_on(color_old_on == 1) = 1;
else
    color = color_last;
    color_on = color_last_on;
end
