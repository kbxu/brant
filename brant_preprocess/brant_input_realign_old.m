function varargout = brant_input_realign(mode,varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end

% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoRealign = brant_FileRead('realign',C);

coltitle = {'ESTIMATE','WRITE'};

prompt{1} = {'quality',         'numeric';...
             'sep',             'numeric';...
             'fwhm',            'numeric';...
             'rtm',             'numeric';...
             'wrap',            'numeric';...
             'weight',          'file_txt';...
             'interp',          'numeric'};
prompt{2} = {'which',           'numeric';...
             'interp',          'numeric';...
             'wrap',            'numeric';...
             'mask',            'numeric';...
             'prefix',          'string'};
dlg_rstbtn = 1; % use reset button
dlg_title = 'Realign';

defAns{1} = {num2str(infoRealign.eoptions.quality);...
             num2str(infoRealign.eoptions.sep);...
             num2str(infoRealign.eoptions.fwhm);...
             num2str(infoRealign.eoptions.rtm);...
             num2str(infoRealign.eoptions.wrap);...
             infoRealign.eoptions.weight;...
             num2str(infoRealign.eoptions.interp)};

defAns{2} = {num2str(infoRealign.roptions.which);...
             num2str(infoRealign.roptions.interp);...
             num2str(infoRealign.roptions.wrap);...
             num2str(infoRealign.roptions.mask);...
             infoRealign.roptions.prefix};

switch(mode)
    case 'btn_input'
    [realignInfo.eoptions, realignInfo.roptions] = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);
    case {'file_input','file_input_init'}
        realignInfo.eoptions = defAns{1};
        realignInfo.roptions = defAns{2};
end

if isempty(realignInfo.eoptions) && isempty(realignInfo.roptions)
    % Cancel is pressed.
    varargout{1} = '';
    return;
end

% update txt file and labels
% write as a sign of the existance of realign parameters, nothing more
switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('REALIGN PARAMETERS','selected',C{1});
    case 'file_input_init'
        C{1} = brant_FileWrite('REALIGN PARAMETERS','',C{1});
end

for n = 1:length(realignInfo.eoptions)
    C{1} = brant_FileWrite(['rea_est_',prompt{1}{n,1}],realignInfo.eoptions{n},C{1});
end

for n = 1:length(realignInfo.roptions)
    C{1} = brant_FileWrite(['rea_wri_',prompt{2}{n,1}],realignInfo.roptions{n},C{1});
end
varargout{1} = C{1};

if ~strcmp(mode,'file_input_init')
    brant_updateLabel('realign',[realignInfo.eoptions;realignInfo.roptions]);
end
