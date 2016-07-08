function brant_postprocess(dlg_title)

userdata = ['fig_', dlg_title];
h_board = findobj(0, 'Tag', userdata);
if isempty(h_board)
    prompt = brant_postprocess_funcions(dlg_title);
    brant_postprocess_ui(dlg_title, prompt);
else
    h_brant = findobj(0, 'Tag', 'figBRANT');
    pos_brant = get(h_brant, 'Position');
    pos_board = get(h_board, 'Position');
    pos_par = get(h_brant, 'Position');
    fig_pos = [pos_par(1) + pos_par(3) + 15, pos_par(4) + pos_par(2) - pos_board(4), pos_board(3), pos_board(4)];
    pos_tmp = [pos_brant(1), pos_brant(2) - fig_pos(4) - 39, fig_pos(3:4)];
    set(h_board, 'Position', pos_tmp);
    
    figure(h_board);
end
