function varargout = brant_Construct(varargin)
% BRANT_CONSTRUCT M-file for brant_Construct.fig
% Creat by Hu Yong, 2011-04-13
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 15-Jun-2011 19:51:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brant_Construct_OpeningFcn, ...
                   'gui_OutputFcn',  @brant_Construct_OutputFcn, ...
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


% --- Executes just before brant_Construct is made visible.
function brant_Construct_OpeningFcn(hObject, eventdata, handles, varargin)
fprintf('*\tBRANT ---> Construct\n');
% set(0,'DefaultUIcontrolBackgroundColor',[1 1 1]*0.7);
handles.pgbar = progressbar(0.0, hObject,[0.1 0.08 0.5 0.02]);
Htmp = [handles.txtPrefix,...
        handles.txtOutput,...
        handles.txtDir,...
        handles.uipOptions];
set(Htmp,'BackgroundColor',get(hObject,'Color'));
set(hObject, 'Name', upper(mfilename));
try
    load('cdata.mat');
    set(handles.btnOutput,'CData',cdata.openfile,'String','');
    set(handles.btnOpt,   'CData',cdata.openfile,'String','');
    clear cdata;
end

handles.Flist  = {};
movegui(hObject,'center');    % position set

% Choose default command line output for brant_Construct
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brant_Construct wait for user response (see UIRESUME)
% uiwait(handles.figConstruct);


% --- Outputs from this function are returned to the command line.
function varargout = brant_Construct_OutputFcn(hObject, eventdata, handles) 
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
netType = { 'CorrNetwork',  'PartialCorr',...
            'CausalNetwork','PartialCorr',...
            'CohereNetwork','PartialCohere'};
set(hObject, 'UserData', netType);
handles.netType = netType{1};

    % Update handles construct
    guidata(hObject, handles);


function editPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrefix as text
%        str2double(get(hObject,'String')) returns contents of editPrefix as a double


% --- Executes during object creation, after setting all properties.
function editPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnAddDir.
function btnAddDir_Callback(hObject, eventdata, handles)
prefix = get(handles.editPrefix,'String');
Flist = fileload({'hdr','img'}, 'Dir', prefix, true, handles.Flist);

if(length(Flist)>length(handles.Flist)) % add new dir
    handles.Flist = sortrows( Flist );   % sort
    set(handles.listDir, 'String', Flist);
end

    % Updated handles structure
    guidata(hObject, handles);

    
% --- Executes on button press in btnAddList.
function btnAddList_Callback(hObject, eventdata, handles)
prefix = get(handles.editPrefix,'String');
Flist = fileload({'hdr','img'}, 'All', prefix, true, handles.Flist);

if(length(Flist) > length(handles.Flist)) % add new dir
    handles.Flist = sortrows( Flist );   % sort
    set(handles.listDir, 'String', Flist);
end

    % Updated handles structure
    guidata(hObject, handles);
    
% --- Executes on selection change in listDir.
function listDir_Callback(hObject, eventdata, handles)
% hObject    handle to listDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listDir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listDir


% --- Executes during object creation, after setting all properties.
function listDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listDir (see GCBO)
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
id = get(handles.listDir, 'Value');
if(~isempty(handles.Flist) && ~isempty(id))    
    % Show delete information
    fprintf('*\tDelete dir < %s >.\n',handles.Flist{id});
    handles.Flist(id) = []; % delete
    
    set(handles.listDir, 'String', handles.Flist, 'Value', max(id(1)-1, 1));
    % Updated handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in btnRemoveAll.
function btnRemoveAll_Callback(hObject, eventdata, handles)
if(~isempty(handles.Flist))
    fprintf('*\tDelete all dirs.\n');
    handles.Flist = {};

    set(handles.listDir, 'String', handles.Flist, 'Value', 1);
    % Updated handles structure
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function ctxtAddDir_Callback(hObject, eventdata, handles)
% The same as function btnAddDir_Callback
btnAddDir_Callback(hObject, eventdata, handles);


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


% --------------------------------------------------------------------
function ppmOpt_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1 % mask
        set(handles.editOpt, 'String', handles.Mask);
    case 2 % roi
        set(handles.editOpt, 'String', handles.ROI);
    otherwise
        % do nothing
end

    % Updated handles Structure
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function ppmOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editOpt_Callback(hObject, eventdata, handles)
% % inactive
    

% --- Executes during object creation, after setting all properties.
function editOpt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    handles.Mask = '';
    handles.ROI  = 'AAL';

    % Updated handles Structure
    guidata(hObject,handles);


% --- Executes on button press in btnOpt.
function btnOpt_Callback(hObject, eventdata, handles)
switch get(handles.ppmOpt, 'Value')
case 1 % mask
    [tFile, fDir] = uigetfile({'*.hdr','Img-files {*.hdr,*.img}'},...
                               'Select a mask file',...
                               'MultiSelect','off');

    if ischar(tFile) && exist(fDir,'dir')
        if(exist(fullfile(fDir,[tFile(1:end-3),'img']),'file')),
            handles.Mask = fullfile(fDir, tFile);
            set(handles.editOpt, 'String', handles.Mask);
        else
            fprintf('*\tMask must be pairs{*.hdr,*.img}.\n');
            uiwait(errordlg('Mask must be pairs{*.hdr,*.img}',...
                'Error','modal')); 
        end
    end
    
case 2 % roi
    [tFile, fDir] = uigetfile({'*.mat','Mat-files (*.mat)'},...
                               'Pick a MAT-file including ROI-data',...
                               'MultiSelect','off');
    if ischar(tFile)
        handles.ROI = fullfile(fDir, tFile);    
        set(handles.editOpt, 'String', handles.ROI);
    end
    
otherwise
    % do nothing
end

    % Updated handles Structure
    guidata(hObject, handles);

    
% --- Executes on selection change in ppmValue.
function ppmValue_Callback(hObject, eventdata, handles)
Str = {'0.2', 'off'; '0.5', 'on'};
set(handles.editValue, 'String', Str{get(hObject,'Value')});
set(handles.chkSpan,   'Enable', Str{2+get(hObject,'Value')}, 'Value', 0);
uicontrol(handles.editValue);

% Updated handles Structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ppmValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editValue_Callback(hObject, eventdata, handles)
% Value maybe a vector in [0,1], step:0.1~0.01
ErrorMsg = '';
try
    try
        val = eval(get(hObject,'String'));
    catch
        val = str2num(get(hObject,'String'));
    end
    if isempty(val),    val = 0;        end
    
    val = val(:)';     % transform to 1 x n
    if all(val>=0 & val <=1)
        val = unique(round(val*100)/100);
        set(hObject, 'String', mat2str(val));
    else
        ErrorMsg = 'Input value must be in [0, 1].';
    end
catch
    if ~isempty(get(hObject,'String'))
        ErrorMsg = 'Badly input';
    end
end

if(~isempty(ErrorMsg))
    fprintf('%s\n',ErrorMsg);
    uiwait(errordlg(ErrorMsg, 'Error', 'modal'));
    set(hObject, 'String', '');    uicontrol(hObject);
end


% --- Executes during object creation, after setting all properties.
function editValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkSpan.
function chkSpan_Callback(hObject, eventdata, handles)
% hObject    handle to chkSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSpan


% --- Executes on button press in chkSymmetry.
function chkSymmetry_Callback(hObject, eventdata, handles)
% hObject    handle to chkSymmetry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSymmetry


% --- Executes on button press in chkRelation.
function chkRelation_Callback(hObject, eventdata, handles)
% hObject    handle to chkRelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkRelation


% --- Executes on button press in btnHelp.
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
pos = get(handles.figConstruct, 'Position');
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
    'BackgroundColor',    get(handles.figConstruct,'Color'),...
    'String',             helpMsg);
uicontrol(helpFig, 'Style', 'pushbutton',...
    'Position',           [pos(3)/2-30, pos(4)/10-12, 60, 24],...
    'String',             'OK',...
    'Callback',           'closereq');
    

% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
global RUNSTOP;

if( strcmpi(get(hObject, 'String'), 'Run') ),
RUNSTOP = false;

% Input check
if isempty(handles.Flist)
    uiwait(msgbox('Pls add directory including {*.img, *.hdr}',...
        'Warn','warn','modal'));
    return;
end

% voxel size extract
if isempty(handles.Mask)
    fprintf('WARNING: mask option is empty.\n');    
    % load an img file to determine voxel size at random
    tmpDir   = handles.Flist{1};
    tmpFile  = dir(fullfile(tmpDir,[get(handles.editPrefix,'String'),'*.hdr']));
    tmpFile  = tmpFile(1).name;
    mask     = fullfile(tmpDir, tmpFile);   
else
    mask     = handles.Mask;
end
v = spm_vol( mask );
volsize  = abs(v.mat([1,6,11]));

warnMsg = '';
if strcmpi(handles.ROI,'AAL')             % check for defined ROI data
    P = fileparts(which('data_declar.m'));% find the path
    if(~isempty(P) && isequal(volsize, [2 2 2])),        % 2x2x2 AAL
        handles.ROI = fullfile(P,'AAL_ROI_2x2x2.mat');
    elseif(~isempty(P) && isequal(volsize, [3 3 3])),    % 3x3x3 AAL
        handles.ROI = fullfile(P,'AAL_ROI_3x3x3.mat');
    else
        warnMsg = 'Pls self-define ROI of AAL';
        warnMsg = sprintf('%s, with voxel size %s.',warnMsg, mat2str(volsize));
    end
else % self-defined roi-data
    try
        load( handles.ROI );
        if exist('roi','var') && all(isfield(roi,{'volsize','volid'}))
            if ~isequal(roi.volsize, volsize)
                warnMsg = 'Voxel size doesn''t consistent, please reset.';
            end
            clear roi;
        else
            warnMsg = 'Defined ROI-data is unexpected, pls read help.';
        end
    catch
        warnMsg = 'Self-defined ROI-data read aborted.';
    end
end

if ~isempty(warnMsg)
	uiwait(msgbox(warnMsg, 'Warn', 'warn', 'modal'));
	return;
end
% handles.Volsize = volsize;
fprintf('*\tThe voxel size is %s. \n', mat2str(volsize));
clear  tmp*; % delete temporary variables
    

% Run construct
tic
    set(hObject, 'String', 'Stop');
    progressbar(0.0, handles.pgbar);
    
    brant_ConstructRun( handles );
    if(RUNSTOP), 
        fprintf('*\tTask doesn''t finish. \n');
    end
    
	clear global RUNSTOP
    set(hObject, 'String', 'Run');
	progressbar(1.0, handles.pgbar);
toc

else % stop run procedure
    set(hObject, 'String', 'Run');
    RUNSTOP = true;
end
