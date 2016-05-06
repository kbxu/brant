function varargout = GUI2(varargin)
% GUI2 M-file for GUI2.fig
%      GUI2, by itself, creates a new GUI2 or raises the existing
%      singleton*.
%
%      H = GUI2 returns the handle to a new GUI2 or the handle to
%      the existing singleton*.
%
%      GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI2.M with the given input arguments.
%
%      GUI2('Property','Value',...) creates a new GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI2 before GUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI2_OpeningFcn via varargin.
%
%      *See GUI2 Options on GUIDE's Tools menu.  Choose "GUI2 allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI2

% Last Modified by GUIDE v2.5 07-Aug-2013 19:46:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI2 is made visible.
function GUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI2 (see VARARGIN)

% colorbar
init_colorbar(handles);

% axis off
axes(handles.axes1);
axis off;
axes(handles.axes2);
axis off;
axes(handles.axes3);
axis off;
axes(handles.axes4);
axis off;

%% =================================handles variables====================================
% threshold
handles.if_threshold = 0;
handles.threshold = 0;

% if displaying whole brain
handles.if_whole = 0;
% display orientations
handles.display = [-90, 0; 90, 0; 90, 0; -90, 0];
%==========================================================================
% Choose default command line output for GUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
end

% UIWAIT makes GUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%% load surface
% --- Executes on selection change in surface_pop.
function surface_pop_Callback(hObject, eventdata, handles)
% hObject    handle to surface_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns surface_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from surface_pop
%%  Load surface
% load vertices and faces
val = get(hObject, 'Value');
[handles.vertices, handles.faces] = loadSurface(val);

% ---declare color variables---
% surface grey intensity
handles.bg_grey = 0.8;
% color of the last volume loaded
handles.color_last = ones(size(handles.vertices, 1), 3) * handles.bg_grey;
handles.color_last_on = zeros(size(handles.vertices, 1), 1);
% if the surface holds an old colors
handles.if_old = 0;
% old colors reamining on the surface
handles.color_old = ones(size(handles.vertices, 1), 3) * handles.bg_grey;
handles.color_old_on = zeros(size(handles.vertices, 1), 1);
% color to be displayed
handles.color = ones(size(handles.vertices, 1), 3) * handles.bg_grey;
handles.color_on = zeros(size(handles.vertices, 1), 1);

% display uncolored surface
[left, right, left_back, right_back] = init_display(handles);
% surface patches (brain halves)
handles.left = left;
handles.right = right;
handles.left_back = left_back;
handles.right_back = right_back;

% set compass
for i = 1:4
    North = findobj(gcbf,'Tag',['orient_' int2str(i) '_N']);
    South = findobj(gcbf,'Tag',['orient_' int2str(i) '_S']);
    West = findobj(gcbf,'Tag',['orient_' int2str(i) '_W']);
    East = findobj(gcbf,'Tag',['orient_' int2str(i) '_E']);
    [n, s, w, e] = setCompass(handles.display(i, :));
    set(North, 'String', n);
    set(South, 'String', s);
    set(West, 'String', w);
    set(East, 'String', e);
end
guidata(hObject, handles);
end

%% load volume
% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% loads the volume 
[handles.volume_coor, handles.volume_matrix, handles.trans_matrix, handles.volume_name, handles.value_range] = loadVolume();

% bring the vertices into the voxel space
handles.vertices_coor = verticesToVoxelSpace(handles.vertices, handles.trans_matrix);

% project volume on surface in voxel space
% [handles.vertices_image_intensity] = projectInVoxelSpace(handles.volume_matrix, handles.vertices_coor);
[handles.left_multi_intensity, handles.right_multi_intensity] = multiIntersect(handles.volume_matrix, handles.vertices_coor);
guidata(hObject, handles);

% display name and value range on the GUI
set(handles.name, 'String', handles.volume_name);
set(handles.value_min, 'String', num2str(handles.value_range(1), 3));
set(handles.value_max, 'String', num2str(handles.value_range(2), 3));
end

%% select data type
% --- Executes on selection change in data_type.
function data_type_Callback(hObject, eventdata, handles)
% hObject    handle to data_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns data_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data_type
color_pop_handle = findobj(gcbf,'Tag','color_pop');

data_type_val = get(hObject, 'Value');

% set color popupmenu and smooth button
handles.data_type = setColorPop(data_type_val, color_pop_handle);
if strcmp(handles.data_type, 'continuous positive values') || strcmp(handles.data_type, 'positive and negative values')
    smooth_button_handle = findobj(gcbf,'Tag','smooth_button');
    set(smooth_button_handle, 'visible', 'on');
end

% bring the vertex voxels intensities to the actual vertices
% handles.vertices_intensity = voxelsToVertices(handles.vertices_coor, handles.vertices_image_intensity, handles.data_type);
handles.vertices_intensity = projectIntersections(handles.left_multi_intensity, handles.right_multi_intensity, handles.data_type);
guidata(hObject, handles);
end

% --- Executes on button press in threshold_checkbox.
function threshold_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of threshold_checkbox
handles.if_threshold = get(hObject, 'Value');
[handles.color_last, handles.color_last_on] = computeColor(handles);
handles.color = handles.color_last;
handles.color_on = handles.color_last_on;
setColor(hObject, handles);
guidata(hObject, handles);
end


function threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of threshold_edit as a double
handles.threshold = abs(str2double(get(hObject,'String')));
[handles.color_last, handles.color_last_on] = computeColor(handles);
handles.color = handles.color_last;
handles.color_on = handles.color_last_on;
setColor(hObject, handles);
guidata(hObject, handles);
end

%% set colors
% --- Executes on selection change in color_pop.
function color_pop_Callback(hObject, eventdata, handles)
% hObject    handle to color_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        color_pop
handles.color_val = get(hObject, 'Value');

% compute last vertices color (last volume loaded)
[handles.color_last, handles.color_last_on] = computeColor(handles);

% sum last colors with eventual old colors
[handles.color, handles.color_on] = sumColor(handles.color_last, handles.color_last_on, handles.color_old, handles.color_old_on, handles.bg_grey, handles.if_old);

% set the color on the surface
setColor(hObject, handles);

guidata(hObject, handles);
end

% --- Executes on button press in smooth_button.
function smooth_button_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vertices_intensity = smoothSurf(handles.vertices_coor, handles.vertices_intensity, handles.volume_matrix);
[handles.color_last, handles.color_last_on] = computeColor(handles);
handles.color = handles.color_last;
handles.color_on = handles.color_last_on;
setColor(hObject, handles);
guidata(hObject, handles);
end

% hold or clear colors
% --- Executes on button press in hold.
function hold_Callback(hObject, eventdata, handles)
% hObject    handle to hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.if_old = 1;

% store present color in old color
handles.color_old = handles.color;
handles.color_old_on = handles.color_on;
guidata(hObject, handles);

% clear last color
[handles.color_last, handles.color_last_on] = clear_color(size(handles.vertices, 1), handles.bg_grey);

% clear GUI
clearGUI(handles);

guidata(hObject, handles);
end

% --- Executes on button press in clear_last.
function clear_last_Callback(hObject, eventdata, handles)
% hObject    handle to clear_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% color goes back to old color
handles.color = handles.color_old;
handles.color_on = handles.color_old_on;

% clear last color
[handles.color_last, handles.color_last_on] = clear_color(size(handles.vertices, 1), handles.bg_grey);

% set color
setColor(hObject, handles);

% clear GUI
clearGUI(handles);

guidata(hObject, handles);
end

% --- Executes on button press in clear_all.
function clear_all_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.if_old = 0;

% clear last, old and present color
[handles.color_last, handles.color_last_on] = clear_color(size(handles.vertices, 1), handles.bg_grey);
[handles.color_old, handles.color_old_on] = clear_color(size(handles.vertices, 1), handles.bg_grey);
[handles.color, handles.color_on] = clear_color(size(handles.vertices, 1), handles.bg_grey);

% set color
setColor(hObject, handles);

% clear GUI
clearGUI(handles);

guidata(hObject, handles);
end

%% rotations
% --- Executes on slider movement.
function slider1_1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes1);
axes(handles.axes1);
[handles.left, handles.left_whole, handles.display] = sliderFunction(1, 1, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_1_N');
South = findobj(gcbf,'Tag','orient_1_S');
West = findobj(gcbf,'Tag','orient_1_W');
East = findobj(gcbf,'Tag','orient_1_E');
[n, s, w, e] = setCompass(handles.display(1, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider1_2_Callback(hObject, eventdata, handles)
% hObject    handle to slider1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes1);
axes(handles.axes1);
[handles.left, handles.left_whole, handles.display] = sliderFunction(1, 2, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_1_N');
South = findobj(gcbf,'Tag','orient_1_S');
West = findobj(gcbf,'Tag','orient_1_W');
East = findobj(gcbf,'Tag','orient_1_E');
[n, s, w, e] = setCompass(handles.display(1, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider2_1_Callback(hObject, eventdata, handles)
% hObject    handle to slider2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes2);
axes(handles.axes2);
[handles.right, handles.right_whole, handles.display] = sliderFunction(2, 1, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_2_N');
South = findobj(gcbf,'Tag','orient_2_S');
West = findobj(gcbf,'Tag','orient_2_W');
East = findobj(gcbf,'Tag','orient_2_E');
[n, s, w, e] = setCompass(handles.display(2, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider2_2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes2);
axes(handles.axes2);
[handles.right, handles.right_whole, handles.display] = sliderFunction(2, 2, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_2_N');
South = findobj(gcbf,'Tag','orient_2_S');
West = findobj(gcbf,'Tag','orient_2_W');
East = findobj(gcbf,'Tag','orient_2_E');
[n, s, w, e] = setCompass(handles.display(2, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider3_1_Callback(hObject, eventdata, handles)
% hObject    handle to slider3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes3);
axes(handles.axes3);
[handles.left_back, handles.anterior, handles.display] = sliderFunction(3, 1, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_3_N');
South = findobj(gcbf,'Tag','orient_3_S');
West = findobj(gcbf,'Tag','orient_3_W');
East = findobj(gcbf,'Tag','orient_3_E');
[n, s, w, e] = setCompass(handles.display(3, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider3_2_Callback(hObject, eventdata, handles)
% hObject    handle to slider3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes3);
axes(handles.axes3);
[handles.left_back, handles.anterior, handles.display] = sliderFunction(3, 2, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_3_N');
South = findobj(gcbf,'Tag','orient_3_S');
West = findobj(gcbf,'Tag','orient_3_W');
East = findobj(gcbf,'Tag','orient_3_E');
[n, s, w, e] = setCompass(handles.display(3, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider4_1_Callback(hObject, eventdata, handles)
% hObject    handle to slider4_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
cla(handles.axes4);
axes(handles.axes4);
[handles.right_back, handles.posterior, handles.display] = sliderFunction(4, 1, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_4_N');
South = findobj(gcbf,'Tag','orient_4_S');
West = findobj(gcbf,'Tag','orient_4_W');
East = findobj(gcbf,'Tag','orient_4_E');
[n, s, w, e] = setCompass(handles.display(4, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider4_2_Callback(hObject, eventdata, handles)
% hObject    handle to slider4_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
val = get(hObject, 'Value');
cla(handles.axes4);
axes(handles.axes4);
[handles.right_back, handles.posterior, handles.display] = sliderFunction(4, 2, val, handles);

% set compass
North = findobj(gcbf,'Tag','orient_4_N');
South = findobj(gcbf,'Tag','orient_4_S');
West = findobj(gcbf,'Tag','orient_4_W');
East = findobj(gcbf,'Tag','orient_4_E');
[n, s, w, e] = setCompass(handles.display(4, :));
set(North, 'String', n);
set(South, 'String', s);
set(West, 'String', w);
set(East, 'String', e);
guidata(hObject, handles);
end

%% display settings
function display_mode_SelectionChangeFcn(hObject, eventdata, handles)
text1_handle = findobj(gcbf,'Tag','text10');
text2_handle = findobj(gcbf,'Tag','text11');
text3_handle = findobj(gcbf,'Tag','text12');
text4_handle = findobj(gcbf,'Tag','text13');
switch get(eventdata.NewValue, 'Tag') % Get Tag of selected object.
    case 'brain_halves'
        %set whole brain off
        handles.if_whole = 0;
        handles.display = [-90, 0; 90, 0; 90, 0; -90, 0];
        
        % set orientation text handle
        set(text1_handle, 'String', 'left hemisphere');
        set(text2_handle, 'String', 'right hemisphere');
        set(text3_handle, 'String', 'left hemisphere');
        set(text4_handle, 'String', 'right hemisphere');
        
        [handles.left, handles.right, handles.left_back, handles.right_back] = init_display(handles);
    case 'whole_brain'
        % set whole brain on
        handles.if_whole = 1;
        handles.display = [-90, 0; 90, 0; 180, 0; 0, 0];
        
        % set orientation text handle
        set(text1_handle, 'String', 'left view');
        set(text2_handle, 'String', 'right view');
        set(text3_handle, 'String', 'anterior view');
        set(text4_handle, 'String', 'posterior view');
        
        [handles.left_whole, handles.right_whole, handles.anterior, handles.posterior] = init_display(handles);
end
% set compass
for i = 1:4
    North = findobj(gcbf,'Tag',['orient_' int2str(i) '_N']);
    South = findobj(gcbf,'Tag',['orient_' int2str(i) '_S']);
    West = findobj(gcbf,'Tag',['orient_' int2str(i) '_W']);
    East = findobj(gcbf,'Tag',['orient_' int2str(i) '_E']);
    [n, s, w, e] = setCompass(handles.display(i, :));
    set(North, 'String', n);
    set(South, 'String', s);
    set(West, 'String', w);
    set(East, 'String', e);
end
guidata(hObject, handles);
end

%% object creation

% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function value_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to value_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function value_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to value_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function data_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function color_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function slider1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider4_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function slider4_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function surface_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surface_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

