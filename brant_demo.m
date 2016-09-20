function brant_demo(outdir)

% brant_path = fileparts(which('brant'));

brant; 
set(gcf, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
% export_fig(fullfile(outdir, 'brant.png'), '-nocrop');
saveas(gcf, fullfile(outdir, 'brant.png'));

pause(0.5)
brant_preprocess('init'); pause(0.5)

h_prep = findobj(0, 'Name', 'brant_Preprocessing');
figure(h_prep);
set(gcf, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
print(fullfile(outdir, 'brant_preprocess.png'), '-dpng', '-r0')
% export_fig(fullfile(outdir, 'brant_preprocess.png'), '-nocrop');
% saveas(gcf, fullfile(outdir, 'brant_preprocess.png'));

% h_board = findobj(0, 'Name', 'brant_CheckBoard');
% figure(h_board);
% set(gcf, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
% export_fig(fullfile(outdir, 'brant_preprocess_info.png'), '-nocrop');

brant_preprocess('quit'); pause(1)

functypes = {'FC', 'SPON', 'STAT', 'NET', 'UTILITY'};
for m = 1:numel(functypes)
    brant_postprocess(functypes{m}); 
    h_parent = gcf; pos = get(gcf, 'Position'); pause(0.5);
    
    prompt = brant_postprocess_funcions(functypes{m});
    for n = 1:numel(prompt)
        brant_gui(prompt{n}); pos = update_pos(pos);
        fn = regexprep(prompt{n}, '[\\\/ ]', '_');
        set(gcf, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
        export_fig(fullfile(outdir, [fn, '.png']), '-nocrop');
%         saveas(gcf, fullfile(outdir, [fn, '.png']));
    end
    pause(1.5);
    delete(h_parent);
end
brant('quit');

function pos = update_pos(pos)

brant_config_figure(gcf, 'pixel');
pos_s = get(gcf, 'Position');
pos = [pos(1) + pos(3) + 10, pos(2) - (pos_s(4) - pos(4)), pos_s(3:4)];
set(gcf, 'Position', pos);
pause(0.5);
