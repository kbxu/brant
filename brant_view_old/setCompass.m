function [n, s, w, e] = setCompass(display)
% set West East
if abs(display(1)) > 135
    w = 'R';
    e = 'L';
    if display(2) > 45
        n = 'P';
        s = 'A';
    elseif display(2) < -45
        n = 'A';
        s = 'P';
    else
        n = 'U';
        s = 'D';
    end
elseif display(1) >= -135 && display(1) < -45
    w = 'A';
    e = 'P';
    if display(2) > 45
        n = 'R';
        s = 'L';
    elseif display(2) < -45
        n = 'L';
        s = 'R';
    else
        n = 'U';
        s = 'D';
    end
elseif abs(display(1)) <= 45
    w = 'L';
    e = 'R';
    if display(2) > 45
        n = 'A';
        s = 'P';
    elseif display(2) < -45
        n = 'P';
        s = 'A';
    else
        n = 'U';
        s = 'D';
    end
elseif display(1) > 45 && display(1) <= 135
    w = 'P';
    e = 'A';
    if display(2) > 45
        n = 'L';
        s = 'R';
    elseif display(2) < -45
        n = 'R';
        s = 'L';
    else
        n = 'U';
        s = 'D';
    end
end


