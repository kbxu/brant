function init_colorbar(handles)
axes(handles.axes5);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor', 'white','YColor', 'white');
set(gca, 'visible', 'off');

axes(handles.axes7);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor', 'white','YColor', 'white');
set(gca, 'visible', 'off');

axes(handles.axes8);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor', 'white','YColor', 'white');
set(gca, 'visible', 'off');