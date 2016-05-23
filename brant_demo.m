function brant_demo

brant; pause(0.5)
brant_preprocess('init'); pause(0.5)
brant_preprocess('quit'); pause(1)

brant_path = fileparts(which('brant'));

functypes = {'FC', 'SPON', 'STAT', 'NET', 'UTILITIES'};
for m = 1:numel(functypes)
    brant_postprocess(functypes{m}); 
    h_parent = gcf; pos = get(gcf, 'Position'); pause(0.5);
    
    prompt = brant_postprocess_funcions(functypes{m});
    for n = 1:numel(prompt)
        brant_gui(prompt{n}); pos = update_pos(pos);
        fn = regexprep(prompt{n}, '[\\\/ ]', '_');
        set(gcf, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
        export_fig(fullfile(brant_path, 'brant_gui_pics', [fn, '.png']), '-nocrop', '-r800');
    end
    pause(1.5);
    delete(h_parent);
end
brant('quit');

function pos = update_pos(pos)

pos_s = get(gcf, 'Position');
pos = [pos(1) + pos(3) + 10, pos(2) - (pos_s(4) - pos(4)), pos_s(3:4)];
set(gcf, 'Position', pos);
pause(0.5);