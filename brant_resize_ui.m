function brant_resize_ui(h)

set(h, 'Units', 'characters');

str_ui = get(h, 'String');
if ~isempty(strfind(str_ui, '<html>'))
    rep_strs = {'<html>', '</html>', '<sup>', '</sup>', '<sub>', '</sub>'};
    str_ui_new = str_ui;
    for m = 1:numel(rep_strs)
        str_ui_new = strrep(str_ui_new, rep_strs{m}, '');
    end
    por_str = length(str_ui_new) / length(str_ui);
else
    por_str = 1;
end

pos_ui = get(h, 'Pos');
str_size = get(h, 'extent');
set(h, 'Position', [pos_ui(1:2), ceil(por_str * str_size(3) + 4), pos_ui(4)]);
set(h, 'Units', 'Pixels');


% set(h, 'FontUnits', 'pixels', 'FontSize', 12);
