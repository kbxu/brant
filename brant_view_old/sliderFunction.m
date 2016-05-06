function [half, whole, display] = sliderFunction(Axes, index, val, handles)

display = updateDisplay(Axes, index, handles.if_whole, val, handles.display);

if ~handles.if_whole
    half = sliderRotate(Axes, display, handles);
    whole = [];
else
    whole = sliderRotate(Axes, display, handles);
    half = [];
end