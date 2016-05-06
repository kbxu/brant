function varargout = brant_input_slicetiming(mode, varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end


% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoSliceTiming = brant_FileRead('slicetiming',C);

prompt{1} = {'slice order:',                         'numeric';...
             'TR(s):',                               'numeric';...
             'reference slice',                      'numeric';...
             'prefix:'                               'string'};
dlg_title = '';
dlg_rstbtn = 0;
defAns{1} = {infoSliceTiming.slice_order;...
             num2str(infoSliceTiming.tr);...
             num2str(infoSliceTiming.refslice);...
             infoSliceTiming.prefix};
coltitle = {'SLICE TIMING'};
switch(mode)
    case 'btn_input'
        sliceinfo{1} = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);
	case {'file_input','file_input_init'}
        sliceinfo = defAns;
end

% 按cancel的话就return
if isempty(sliceinfo{1})
    varargout{1} = '';
    return;
end

% write as a sign of the existance of realign parameters, nothing more
switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('SLICETIMING PARAMETERS','selected',C{1});
	case 'file_input_init'
        C{1} = brant_FileWrite('SLICETIMING PARAMETERS','',C{1});
end

%判断非空输入是否有效（要求输入为数字的输成了字符则无效，字符str2num转换后为空）
C{1} = brant_FileWrite('st_slice_order',sliceinfo{1}{1},C{1});  % SOtmp
switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('st_tr(s)',sliceinfo{1}{2},C{1});
        C{1} = brant_FileWrite('filter_tr(s)',sliceinfo{1}{2},C{1});
    case {'file_input','file_input_init'}
        C{1} = brant_FileWrite('st_tr(s)',sliceinfo{1}{2},C{1});
end
C{1} = brant_FileWrite('st_refslice',sliceinfo{1}{3},C{1});
C{1} = brant_FileWrite('st_prefix',sliceinfo{1}{4},C{1});

filter_tmp = brant_FileRead('filter',C);
varargout{1} = C{1};
% set(findobj(0,'Tag','slicetiming_chb'),'Value',1);
if ~strcmp(mode,'file_input_init')
    brant_updateLabel('slice_timing',sliceinfo{1});
    brant_updateLabel('filter',{num2str(filter_tmp.lower_cutoff);...
                               num2str(filter_tmp.upper_cutoff);...
                               filter_tmp.wb_mask;...
                               num2str(filter_tmp.tr);...
                               num2str(filter_tmp.timepoints);...
                               filter_tmp.prefix});
end
