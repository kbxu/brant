function display = updateDisplay(axes, index, if_whole, val, old_display)

display = old_display;
if index == 1
    switch axes
        case 1
            display(axes, 1) = -val * 180;
        case 2
            display(axes, 1) = (-val * 180) + 180;
        case 3
            if ~if_whole
                display(axes, 1) = (-val * 180) + 180;
            else
                if (-val * 180) - 90 < -180
                    display(axes, 1) = 360 + ((-val * 180) - 90);
                else
                    display(axes, 1) = (-val * 180) - 90;
                end
            end
        case 4
            if ~if_whole
                display(axes, 1) = -val * 180;
            else
                display(axes, 1) = (-val * 180) + 90;
            end
    end
elseif index == 2
    display(axes, 2) = (-val * 180) + 90;
end
