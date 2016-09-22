function view_angle = brant_get_view_angle(mode_display)

mode_brain = regexpi(mode_display, ':', 'split');
switch mode_brain{1}
    case 'halves'
        switch mode_brain{2}
            case {'left lateral', 'right medial'}
                view_angle = [-90, 0];
            case {'left medial', 'right lateral'}
                view_angle = [90, 0];
        end
    case 'whole brain'
        switch mode_brain{2}
            case 'sagital left'
                view_angle = [-90, 0];
            case 'sagital right'
                view_angle = [90, 0];
            case 'axial superior'
                view_angle = [0, 90];
            case 'axial inferior'
                view_angle = [180, -90];
            case 'coronal anterior'
                view_angle = [180, 0];
            case 'coronal posterior'
                view_angle = [0, 0];
        end
end