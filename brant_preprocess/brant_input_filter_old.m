function varargout = brant_input_filter(mode,varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end

% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoFilter = brant_FileRead('filter',C);

prompt{1} = {'Lower cutoff(Hz)',       'numeric';...
             'Upper cutoff(Hz)',       'numeric';...
             'Brain mask',             'box_file_img_tmp'};
prompt{2} = {'TR(s)',                  'numeric';...
             'Timepoints',             'numeric';...
             'prefix',                 'string'};
dlg_title = 'Filter';
dlg_rstbtn = 0;
coltitle = {'Butterworth Filter',''};
defAns{1} = {num2str(infoFilter.lower_cutoff);...
             num2str(infoFilter.upper_cutoff);...
             infoFilter.wb_mask};
defAns{2} = {num2str(infoFilter.tr);...
             num2str(infoFilter.timepoints);...
             infoFilter.prefix};

outputFilter = cell(1,2);
switch(mode)
    case 'btn_input'
        [outputFilter{1}, outputFilter{2}] = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns); %inputdlg(prompt, dlg_title, num_lines, defAns);
	case {'file_input','file_input_init'}
        outputFilter = defAns;
end

if isempty(outputFilter{1}) && isempty(outputFilter{2}) % 按cancel或者右上角叉的情况下
    varargout{1} = '';
    return;
end

switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('FILTER PARAMETERS','selected',C{1});
    case 'file_input_init'
        C{1} = brant_FileWrite('FILTER PARAMETERS','',C{1});
end

tmp{1} = {'lower_cutoff', 'upper_cutoff', 'wb_mask', 'tr(s)', 'timepoints', 'prefix'};
tmp{2} = {outputFilter{1}{1};outputFilter{1}{2};outputFilter{1}{3};outputFilter{2}{1};outputFilter{2}{2};outputFilter{2}{3}};

% write data in
for n = 1:length(tmp{1})
    C{1} = brant_FileWrite(strcat('filter_',tmp{1}{n}),tmp{2}{n},C{1});
end
C{1} = brant_FileWrite('st_tr(s)', tmp{2}{4},C{1});
st_tmp = brant_FileRead('slicetiming', C);

varargout{1} = C{1};
% set(findobj(0,'Tag','filter_chb'),'Value',1);
if ~strcmp(mode,'file_input_init')
    brant_updateLabel('filter',[outputFilter{1};outputFilter{2}]);
    brant_updateLabel('slice_timing',[cellstr(st_tmp.slice_order);cellstr(num2str(st_tmp.tr));cellstr(num2str(st_tmp.refslice));cellstr(st_tmp.prefix)]);
end
