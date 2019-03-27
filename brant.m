function varargout = brant(Action)
% BRANT   BRAinNetome Toolkit
%   Authors: XU Kaibin, ZHAN Yafeng, HU Yong, LIU Yong
%   Usages: brant(Action)
%         Actions: { ''(empty)| 'fMRI' | 
%         'Path' | 'Preprocess' | 'Net' | 'Spon' | 'FC' | 'Stat'   | 
%         'Quit' | 'About'  | 'View'| 'Mail'}.
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
% Copyright(c) 2010 - now
% Brainnetome Center: http://www.brainnetome.org
% National Lab of Pattern Recognition (NLPR),
% Institute of Automation,
% Chinese Academy of Sciences (IACAS), China.
% BRANT Home page: http://brant.brainnetome.org/
% Fast Update Version: https://github.com/kbxu/brant
% $Mail    = yliu@nlpr.ia.ac.cn;
% $Version = 3.36;
% $Release = 20190327;
% *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Hbrant = findobj(0,'Type','figure','Tag','figBRANT');     % get figure handles
if((nargin < 1) || isempty(Action)),  Action = 'fmri';  end	% first start
switch upper(Action)
    case 'FMRI' % initialization  
        if isempty(Hbrant)% || ~ishandle(Hbrant) % check valid 
            % Version check
            if (str2double(strtok(version, '.')) < 7)
                error('The version of MATLAT isn''t lower than 7.0');
            end
            
            h_fig = initFig;
            set(h_fig, 'Visible', 'on');
            set(allchild(h_fig), 'Units', 'characters');
%             brant_check_paths;
        else % singlgton
            figure(Hbrant);
        end

    case 'PATH' % update search path
        brant_check_paths;

    case {'PREPROCESS','PREP'}
        brant_preprocess;

    case {'FC', 'SPON', 'UTILITY', 'STAT', 'NET', 'VIEW', 'THIRD PARTY'}
        brant_postprocess(upper(Action));
        
    case 'QUIT'
        window_names = brant_windows;
        h_all_fig = findobj(0, 'Type', 'fig');
        nm_all_fig = arrayfun(@(x) get(x, 'Name'), h_all_fig, 'UniformOutput', false);

        h_brant_ind = cellfun(@(x) any(strcmpi(x, window_names)), nm_all_fig);
        delete(h_all_fig(h_brant_ind));
        
        if ishandle(Hbrant)
            delete(Hbrant);
        end
        fprintf('\tBye for now...\n');

    case {'ABOUT', 'ABOUTBRANT'}  % help documents
        web('http://brant.brainnetome.org/', '-browser');

    case 'MAIL' % mail to author
        web('mailto:yliu@nlpr.ia.ac.cn');
        
    case {'LICENCE', 'LICENSE'}
        fprintf('o\n');
        
    case 'VERSION'
        varargout = regexpi(help(mfilename),'Version = ([0-9\.]+);','tokens','once');
    otherwise
        error(['Usage: ', mfilename]);
end

if (nargout>0) && (strcmpi(Action, 'version') == 0)
    varargout{1} = Hbrant;    
end
  


function h_fig = initFig
if(ispc) % check pc(Windows) version of MATLAB
   UserName = getenv('USERNAME');
else
   UserName = getenv('USER');
end
Version  = regexpi(help(mfilename),'Version = ([0-9\.]+);','tokens','once');
Release  = regexpi(help(mfilename),'Release = ([0-9\.]+);','tokens','once');
Datetime = fix(clock);
fprintf('*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n');
fprintf('*  Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),...
            Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('*  BRAinNetome Toolkit (BRANT)\n');
fprintf('*  Version = %s\n',Version{1});
fprintf('*  Release = %s\n',Release{1});
fprintf('*  Copyright(c) 2010 - now\n');
fprintf('*  Brainnetome Center: <a href = "http://www.brainnetome.org">http://www.brainnetome.org</a>\n');
fprintf('*  National Lab of Pattern Recognition(NLPR)\n');
fprintf('*  Institute of Automation,\n');
fprintf('*  Chinese Academy of Sciences(CASIA), China\n');
fprintf('*  <a href = "http://brant.brainnetome.org/">Homepage</a> <a href = "https://github.com/kbxu/brant">GitHub</a>\n')
fprintf('*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n\n');

set(0,'Units','pixels');
screensize = get(0,'screensize');  % newly added on 20140219
defColor = 0.9 * [1 1 1];

% Handles of main figure
h_fig = figure(...
    'IntegerHandle',    'off',...
	'Name',             sprintf('%s %s',upper(mfilename),Version{1}),...
    'Position',         [screensize(3)/2 - 400, screensize(4) - 400, 310 270],...   % new edited on 20140219
    'Color',            defColor,...
    'CloseRequestFcn',  [mfilename,'(''Quit'')'],...
    ...'DeleteFcn',        [mfilename,'(''Quit'')'],...
	'NumberTitle',      'off',...
	'Tag',              'figBRANT',...	
    'Units',            'pixels',...
	'Resize',           'off',...	
	'MenuBar',          'none',...    
	'Visible',          'off');

% Handles of axes
h_axes = axes(...
    'Parent',           h_fig,...
    'Units',            'pixels',...
    'Box',              'on',...
    'Position',         [21 150 270 80]);
I = imread(fullfile(fileparts(which('brant')), 'logo.jpg'));
image(I, 'Parent', h_axes);
set(h_axes, 'XTick', [], 'YTick', []);
title('Brainnetome Toolkit', ...
    'FontSize',         16, ...
    'FontWeight',       'bold', ...
    'Color',            [0 0.4 1]);

h_uip = uipanel(...
    'Parent',           h_fig,...
    'Units',            'pixels',...
    'Position',         [20, 20, 270, 120],...
    'Title',            '',...
    'BackgroundColor',  defColor,...
    'BorderType',       'line',...
    'BorderWidth',      2);

% Handles of pushbutton     
btnOpt = {...
    'Preprocess',       [15  84 90 25];...
    'Utility',          [15  46 90 25];...
    'FC',               [120 84 60 25];...
    'SPON',             [195 84 60 25];...
    'NET',              [120 46 60 25];...
    'STAT',             [195 46 60 25];...
    'View',             [120 8  60 25];...
    'Third Party',            [15  8  90 25];...
    'Quit',             [195 8  60 25]};

h_btn = zeros(size(btnOpt, 1), 1);
for n = 1:size(btnOpt, 1)        %length returns the longest dim
    h_btn(n) = uicontrol(...
        'Parent',       h_uip,...
        'Style',        'pushbutton',...
        'String',       btnOpt{n, 1},...
        'Position',     btnOpt{n, 2},...
        'FontSize',     10.0,...
        'FontWeight',   'bold',...
        'ForegroundColor',[0.2 0.4 0.8],...
        'Callback',     [mfilename,'(''',btnOpt{n,1},''')']);
end
% set(h_btn(1:2), 'FontSize', 9.0); % pre & about
set(h_btn(9), 'ForegroundColor', [1.0 0.4 0]); % quit
set(h_btn(8), 'ForegroundColor', [0.3 0.5 0]);

% Handles of copyright text
uicontrol(h_fig,...
    'Style',            'text',...
    'Position',         [105 2 100 15],...
    'String',           'Copyright(c) 2010 ',...
    'BackgroundColor',  defColor,...
    'ForegroundColor',  [1 1 1]*0.7,...
    'FontSize',         8);
