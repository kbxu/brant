function varargout = brant_Modularity(varargin)
% BRANT_MODULARITY M-file for brant_Modularity.fig
% Creat by Hu Yong, 2011-04-13
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 09-Jul-2011 11:04:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brant_Modularity_OpeningFcn, ...
                   'gui_OutputFcn',  @brant_Modularity_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before brant_Modularity is made visible.
function brant_Modularity_OpeningFcn(hObject, eventdata, handles, varargin)
fprintf('*\tBRANT ---> Modularity\n');
% set(0,'DefaultUIcontrolBackgroundColor',[1 1 1]*0.7);
handles.pgbar = progressbar(0.0, hObject,[0.1 0.05 0.5 0.02]);
Htmp = [handles.txtOutput, handles.uipOptions,...
        handles.txtAP,     handles.txtFile];
set(Htmp,'BackgroundColor',get(hObject,'Color'));
set(hObject, 'Name', upper(mfilename));
try
    load('cdata.mat');
    set(handles.btnOutput,'CData',cdata.openfile,'String','');
    clear cdata;
end

handles.Flist  = {};
handles.AT     = [];       % algorithm type
movegui(hObject,'center'); % position set

% Choose default command line output for brant_Modularity
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brant_Modularity wait for user response (see UIRESUME)
% uiwait(handles.figMeasure);


% --- Outputs from this function are returned to the command line.
function varargout = brant_Modularity_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in ppmType.
function ppmType_Callback(hObject, eventdata, handles)    
netType = get(hObject, 'UserData');
handles.netType = netType{get(hObject,'Value')};

% Update handles construct
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ppmType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
netType = { 'binary',  'directed', 'weighted', 'all type'};
set(hObject, 'UserData', netType);
handles.netType = netType{1};

% Update handles construct
guidata(hObject, handles);


% --- Executes on button press in btnAddFile.
function btnAddFile_Callback(hObject, eventdata, handles)
Flist = fileload({'mat'}, 'File', [], false, handles.Flist);
if(length(Flist)>length(handles.Flist))  % add new dir
    handles.Flist = sortrows( Flist );   % sort
    set(handles.listFile, 'String', Flist);
end

    % Updated handles structure
    guidata(hObject, handles);

    
% --- Executes on button press in btnAddList.
function btnAddList_Callback(hObject, eventdata, handles)
Flist = fileload({'mat'}, 'Txt', [], false, handles.Flist);
if(length(Flist) > length(handles.Flist)) % add new dir
    handles.Flist = sortrows( Flist );    % sort
    set(handles.listFile, 'String', Flist);
end

    % Updated handles structure
    guidata(hObject, handles);
    
% --- Executes on selection change in listFile.
function listFile_Callback(hObject, eventdata, handles)
% hObject    handle to listFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFile


% --- Executes during object creation, after setting all properties.
function listFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRemove.
function btnRemove_Callback(hObject, eventdata, handles)
id = get(handles.listFile, 'Value');
if(~isempty(handles.Flist) && ~isempty(id))    
    % Show delete information
    fprintf('*\tDelete dir < %s >.\n',handles.Flist{id});
    handles.Flist(id) = []; % delete
    
    set(handles.listFile, 'String', handles.Flist, 'Value', max(id(1)-1, 1));
    % Updated handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in btnRemoveAll.
function btnRemoveAll_Callback(hObject, eventdata, handles)
if(~isempty(handles.Flist))
    fprintf('*\tDelete all dirs.\n');
    handles.Flist = {};

    set(handles.listFile, 'String', handles.Flist, 'Value', 1);
    % Updated handles structure
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function ctxtAddFile_Callback(hObject, eventdata, handles)
% The same as function btnAddDir_Callback
btnAddFile_Callback(hObject, eventdata, handles);


function ctxtAddList_Callback(hObject, eventdata, handles)
% The same as function btnAddList_Callback
btnAddList_Callback(hObject, eventdata, handles);


function ctxtRemove_Callback(hObject, eventdata, handles)
% The same as function btnRemove_Callback
btnRemove_Callback(hObject, eventdata, handles)


function ctxtRemoveAll_Callback(hObject, eventdata, handles)
% The same as function btnRemoveAll_Callback
btnRemoveAll_Callback(hObject, eventdata, handles)


function ctxtAdding_Callback(hObject, eventdata, handles)
% hObject    handle to ctxtAdding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function editOutput_Callback(hObject, eventdata, handles)
theDir = get(hObject, 'String');
if(exist(theDir,'dir')),
    handles.OutputDir = theDir;
else
    uiwait(errordlg('Dir non-exist,or invalid directory.','Error','modal'));
end
    set(hObject,'String',handles.OutputDir);
    
    % Updated handles structure
    guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editOutput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    set(hObject,'String',pwd);
    handles.OutputDir = pwd;
    
    % Updated handles structure
    guidata(hObject,handles);
    
% --- Executes on button press in btnOutput.
function btnOutput_Callback(hObject, eventdata, handles)
theDir = handles.OutputDir;
theDir = uigetdir(theDir, 'Please select the output directory: ');
if(ischar(theDir) && exist(theDir,'dir'))
    handles.OutputDir = theDir;
    set(handles.editOutput,'String',theDir);
    
    % Updated handles Structure
    guidata(hObject, handles);
end


% --- Executes on selection change in ppmAT.
function ppmAT_Callback(hObject, eventdata, handles)
% select algorithm type
str = {'', ...
        {'G-N algorithm';'Max likehood';'Max eigenvalue';'Fast algorithm'},...
        {'Link community';'Fast algorithm'},...
        {'Struct class-3';'Struct class-4';...
        'Function class-3';'Function class-4';...
        'All type of 3 & 4'}...
       };
val = get(hObject, 'Value');
handles.AT = str{val};
set(handles.listAT, 'String', handles.AT);
uicontrol(handles.listAT);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ppmAT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function listAT_Callback(hObject, eventdata, handles)



function listAT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editAP_Callback(hObject, eventdata, handles)
% Value must be a positive integer 
ErrorMsg = '';
try
    val = round(str2num(get(hObject,'String')));
    if isscalar(val) && val>0
        set(hObject, 'String', mat2str(val));
    else
        ErrorMsg = 'Input value must be a positive integer.';
    end
catch
    if ~isempty(get(hObject,'String'))
        ErrorMsg = 'Badly input';
    end
end

if ~isempty(ErrorMsg)
    fprintf('%s\n',ErrorMsg);
    uiwait(errordlg(ErrorMsg, 'Error', 'modal'));
    set(hObject, 'String', '100');    uicontrol(hObject);
end


% --- Executes during object creation, after setting all properties.
function editAP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in chkMI.
function chkMI_Callback(hObject, eventdata, handles)
% hObject    handle to chkMI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkMI

% --- Executes on button press in chkSI.
function chkSI_Callback(hObject, eventdata, handles)
% hObject    handle to chkSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSI


% --------------------------------------------------------------------
function btnHelp_Callback(hObject, eventdata, handles)
helpMsg = ['<html><big> 帮  助 </big><p>',...
    '<font size = 3 color = black>',...
    '1, Construct界面用于构造功能网络，类型有六种：相关/偏相关网络，',...
    '   因果/偏因果网络，一致/偏一致性网络；<br>',...
    '2, 输入img所在文件夹或上一层文件夹，可以指定特殊前缀Prefix，用以',...
    '   过滤文件，也可以通过txt文件添加文件目录列表；<br>',...
    '3, Mask选择要求是与img文件同大小，同维度，且可以为空；<br>',...
    '4, ROI默认为AAL模板(116个脑区),可以选择自定义的ROI文件，但需要',...
    '   和AAL_ROI_2x2x2.mat格式类似；<br>',...
    '5，选项中包括设置阈值，或比例，都可以为区间，最小步长为0.01，当',...
    '   选则比例时，可以采用最小生成树来构建网络；<br>',...
    '6, 输出文件会保存在一个叫brantResOut的文件夹下, 内部变量为g. <br>',...
    '<br><br><br></font></html>'];
pos = get(handles.figMeasure, 'Position');
pos(2) = pos(2)+pos(4)/4;
pos(4) = pos(4)/2;

helpFig = figure('Position', pos, ...
    'Menubar',     'none',...
    'Name',        'Help',... 
    'NumberTitle', 'off', ...
    'WindowStyle', 'modal');
uicontrol(helpFig, 'Style', 'pushbutton',...
    'Position',           [0  0  pos(3)+2 pos(4)+2],...
    'SelectionHighlight', 'off',...
    'HorizontalAlignment','center',...
    'Enable',             'inactive',...
    'BackgroundColor',    get(handles.figMeasure,'Color'),...
    'String',             helpMsg);
uicontrol(helpFig, 'Style', 'pushbutton',...
    'Position',           [pos(3)/2-30, pos(4)/10-12, 60, 24],...
    'String',             'OK',...
    'Callback',           'closereq');
    

% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
global RUNSTOP1;

if strcmpi(get(hObject, 'String'), 'Run')
    RUNSTOP1 = false;

    % Input check
    if isempty(handles.Flist)
        uiwait(msgbox('Pls select *.mat file','Warn','warn','modal'));
        return;
    end

    % Selected measures check
    if isempty(get(handles.listSelected, 'String'))
        uiwait(msgbox('Pls select a measure at least.','Warn','warn','modal')); 
        return;
    end

    % Run measure
    tic
        set(hObject, 'String', 'Stop');
        progressbar(0.0, handles.pgbar);

        fname = brant_MeasureRun( handles );
        if RUNSTOP1,    fprintf('*\tTask doesn''t finish. \n');        end
        clear global RUNSTOP1
        set(hObject, 'String', 'Run');
        progressbar(1.0, handles.pgbar);
        
        % Integration result
        if ~isempty(fname) && get(handles.chkMI, 'Value')
            brant_MeasureInt(fname, get(handles.editOutput,'String'));
        end
    toc

else % stop run procedure
    set(hObject, 'String', 'Run');
    RUNSTOP1 = true;
end
