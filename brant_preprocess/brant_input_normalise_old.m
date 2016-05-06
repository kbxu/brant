function varargout = brant_input_normalise(mode,varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end


% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoNormalise = brant_FileRead('normalise',C);
coltitle = {'SOURCE', 'ESTIMATE', 'WRITE'};
prompt{1} = {'source',                      'file_txt';...
             'wtsrc',                       'file_txt'};
prompt{2} = {'template',                    'file_img_*';...
             'weight',                      'file_txt';...          % what?
             'smosrc',                      'numeric';...
             'smoref',                      'numeric';...
             'regtype',                     'popup';...  % 'string'
             'cutoff',                      'numeric';...
             'nits',                        'numeric';...
             'reg',                         'numeric'};
prompt{3} = {'preserve',                    'numeric';...
             'bb',                          'numeric';...
             'vox',                         'numeric';...
             'interp',                      'numeric';...
             'wrap',                        'numeric';...
             'prefix',                      'string'};
dlg_rstbtn = 1;     % use reset button
dlg_title = 'Normalise';

% 如果是直接从文件里面读，只能读出第一个参数，这里要重新赋值一遍来满足popmenu
if ~iscell(infoNormalise.eoptions.regtype)
    default_spaces = {'1','mni','imni','rigid','subj','eastern','none'};
    swinum = find(strcmp(infoNormalise.eoptions.regtype,default_spaces),1);
    default_spaces{1} = num2str(swinum - 1);
    infoNormalise.eoptions.regtype = default_spaces;
end

defAns{1} = {infoNormalise.subj.source;...
             infoNormalise.subj.wtsrc};

defAns{2} = {infoNormalise.eoptions.template;...
             infoNormalise.eoptions.weight;...
             num2str(infoNormalise.eoptions.smosrc);...
             num2str(infoNormalise.eoptions.smoref);...
             infoNormalise.eoptions.regtype;...
             num2str(infoNormalise.eoptions.cutoff);...
             num2str(infoNormalise.eoptions.nits);...
             num2str(infoNormalise.eoptions.reg)};

defAns{3} = {num2str(infoNormalise.roptions.preserve);...
             strcat(num2str(infoNormalise.roptions.bb(1,:)),';',num2str(infoNormalise.roptions.bb(2,:)));...
             num2str(infoNormalise.roptions.vox);...
             num2str(infoNormalise.roptions.interp);...
             num2str(infoNormalise.roptions.wrap);...
             infoNormalise.roptions.prefix};

switch(mode)
    case 'btn_input'
        % 更新infoNormalise
        [infoNormalise.subj, infoNormalise.eoptions, infoNormalise.roptions] = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);
    case {'file_input','file_input_init'}
        infoNormalise.subj = defAns{1};
        defAns{2}{5} = defAns{2}{5}{str2num(defAns{2}{5}{1}) + 1};
        infoNormalise.eoptions = defAns{2};
        infoNormalise.roptions = defAns{3};
end

% 不管从哪里输入，都要检查一遍数据
if ~isempty(infoNormalise.eoptions) || ~isempty(infoNormalise.roptions)
    
    out.subj.source = infoNormalise.subj{1};
    out.subj.wtsrc = infoNormalise.subj{2};
    
    out.eoptions.template = infoNormalise.eoptions{1};
    out.eoptions.weight = infoNormalise.eoptions{2};
    out.eoptions.smosrc = str2num(infoNormalise.eoptions{3});
    out.eoptions.smoref = str2num(infoNormalise.eoptions{4});
    out.eoptions.regtype = infoNormalise.eoptions{5};
    out.eoptions.cutoff = infoNormalise.eoptions{6};
    out.eoptions.nits = str2num(infoNormalise.eoptions{7});
    out.eoptions.reg = str2num(infoNormalise.eoptions{8});

    out.roptions.preserve = str2num(infoNormalise.roptions{1});
    out.roptions.bb = str2num(infoNormalise.roptions{2});
    out.roptions.vox = str2num(infoNormalise.roptions{3});
    out.roptions.interp = str2num(infoNormalise.roptions{4});
    out.roptions.wrap = str2num(infoNormalise.roptions{4});
    out.roptions.prefix = infoNormalise.roptions{5};
    
    % 这里检测单个输入是否错误
    S = cell(3,1);
    for n = 1:3 
        S{n} = cell(size(prompt{n},1),1);
        for m = 1:size(prompt{n},1)
            S{n}{m} = struct('type',        '.',...
                             'subs',        prompt{n}{m,1});
            if n == 2 && m ~= 2 && isempty(subsref(out.eoptions,S{n}{m}))
                warndlg([prompt{n}{m},32,'Input Invalid!'])
                return;
            elseif n == 3 && isempty(subsref(out.roptions,S{n}{m}))
                warndlg([prompt{n}{m},32,'Input Invalid!'])
                return;
            end
        end
    end

else
    % Cancel is pressed.
    varargout{1} = '';
    return;
end

% update txt file and labels
% subj info
normalise_subj = {'nor_subj_source';...
                  'nor_subj_wtsrc'};
                 
% estimate info
normalise_est = {'nor_est_template';...
                 'nor_est_weight';...
                 'nor_est_smosrc';...
                 'nor_est_smoref';...
                 'nor_est_regtype';...
                 'nor_est_cutoff';...
                 'nor_est_nits';...
                 'nor_est_reg'};

% write info
normalise_wri = {'nor_wri_preserve';...
                 'nor_wri_bb';...
                 'nor_wri_vox';...
                 'nor_wri_interp';...
                 'nor_wri_wrap';...
                 'nor_wri_prefix'};

% write the inputs into preprocessing_setting.txt

% write as a sign of the existance of realign parameters, nothing more
switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('NORMALISE PARAMETERS','selected',C{1});
    case 'file_input_init'
        C{1} = brant_FileWrite('NORMALISE PARAMETERS','',C{1});
end

% write data in
for n = 1:length(infoNormalise.subj)
    C{1} = brant_FileWrite(normalise_subj{n},infoNormalise.subj{n},C{1});
end

for n = 1:length(infoNormalise.eoptions)
    C{1} = brant_FileWrite(normalise_est{n},infoNormalise.eoptions{n},C{1});
end

for n = 1:length(infoNormalise.roptions)
    C{1} = brant_FileWrite(normalise_wri{n},infoNormalise.roptions{n},C{1});
end
varargout{1} = C{1};
% set(findobj(0,'Tag','normalise_chb'),'Value',1);
if ~strcmp(mode,'file_input_init')
    brant_updateLabel('normalise',[infoNormalise.subj;infoNormalise.eoptions;infoNormalise.roptions]);
end
