function varargout = brant_Net(varargin)
% BRANT_NET M-file for brant_Net.fig
% Creat by Hu Yong, 2011-06-20
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 20-Jun-2011 21:20:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brant_Net_OpeningFcn, ...
                   'gui_OutputFcn',  @brant_Net_OutputFcn, ...
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


% --- Executes just before brant_Net is made visible.
function brant_Net_OpeningFcn(hObject, eventdata, handles, varargin)
Hbrant = findobj(0, 'Type', 'figure', 'Tag', 'figBRANT'); % get figure handles
if ishandle(Hbrant)
    % Get main figure position
	mpos  = get(Hbrant, 'OuterPosition');
    pos   = get(hObject, 'OuterPosition');
    pos(1) = mpos(1)+mpos(3);
    pos(2) = mpos(2);
    set(hObject, 'OuterPosition', pos);
else
    movegui(hObject, 'center');
end
set(hObject, 'Name', upper(mfilename));

% Reset figure close callback function
set(hObject, 'CloseRequestFcn', @Close_Callback);

% Choose default command line output for brant_Net
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brant_Net wait for user response (see UIRESUME)
% uiwait(handles.figNet);


% --- Outputs from this function are returned to the command line.
function varargout = brant_Net_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in btnCon.
function btnCon_Callback(hObject, eventdata, handles)
run brant_Construct;

% --- Executes on button press in btnMod.
function btnMod_Callback(hObject, eventdata, handles)
run brant_Modularity;

% --- Executes on button press in btnMea.
function btnMea_Callback(hObject, eventdata, handles)
run brant_Measure;

function Close_Callback(hObject, eventdata, handles)
% Get main figure handles
Hbrant = findobj(0, 'Type', 'figure', 'Tag', 'uipNet');
if ishandle(Hbrant), 	delete(Hbrant);       end
% if ishandle(hObject),   delete(hObject);    end
% ==>
closereq;
