function varargout = brant_input_smooth(mode,varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end

% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoSMOOTH = brant_FileRead('smooth',C);

prompt{1} = {'fwhm',        'numeric';...
             'prefix',      'string'};

dlg_title = '';
dlg_rstbtn = 0;
coltitle = {'SMOOTH'};
defAns{1} = {num2str(infoSMOOTH.fwhm);...
             infoSMOOTH.prefix};

switch(mode)
    case 'btn_input'
        outputSmooth{1} = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns); %inputdlg(prompt, dlg_title, num_lines, defAns);
	case {'file_input','file_input_init'}
        outputSmooth = defAns;
end

if isempty(outputSmooth{1})    % 按cancel或者右上角叉的情况下
    varargout{1} = '';
    return;
end

switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('SMOOTH PARAMETERS','selected',C{1});
    case 'file_input_init'
        C{1} = brant_FileWrite('SMOOTH PARAMETERS','',C{1});
end

% write data in
for n = 1:2
	C{1} = brant_FileWrite(strcat('smooth_',prompt{1}{n,1}),outputSmooth{1}{n},C{1});
end
varargout{1} = C{1};
% set(findobj(0,'Tag','smooth_chb'),'Value',1);
if ~strcmp(mode,'file_input_init')
    brant_updateLabel('smooth',outputSmooth{1});
end
