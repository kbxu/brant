function setLoadBar(step, hObject, handles)
axes(handles.axes6);
colormap hot;
load_bar = ones(1, 6);
load_bar(1:step) = 0;
imagesc(load_bar);
set(gca,'XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
guidata(hObject, handles)