function varargout = brant_input_denoise(mode,varargin)

C = brant_prep_input(mode, varargin);

if isempty(C)
    varargout{1} = '';
    return;
end

% 文件中包含该信息时会将信息读出，未包含时读出的是默认值
infoDenoise = brant_FileRead('denoise',C);

coltitle = {'SUBJINFO', 'Detrend', 'MASK', 'MOTION CORR'};  % 名字待定
prompt{1} = {'timepoints',                  'numeric';...
             'voxelsize',                   'numeric'};
prompt{2} = {'constant *',                  'box_must';...
             'linear drift',                'box'};
prompt{3} = {'whole brain',                 'box_file_img_*';...
             'white matter',                'box_file_img_tmp';...
             'gray matter',                 'box_file_img_tmp';...          % 这里最好写成files，可能会导入很多文件，不然导入一个txt吧
             'csf',                         'box_file_img_tmp';...
             'global mean',                 'box'};  % 20140224
prompt{4} = {'head motion',                 'box';...
             'motion''s deriv',             'box';...
             'filetype',                    'string';...
             '',                            'empty';...
             'prefix',                      'string'};

dlg_rstbtn = 1;     % use reset button
dlg_title = 'Denoise';

defAns{1} = {num2str(infoDenoise.subj.timepoints);...
             num2str(infoDenoise.subj.voxelsize)};

defAns{2} = {infoDenoise.detrend.constant;...
             infoDenoise.detrend.linear_drift};

defAns{3} = {infoDenoise.mask.wholebrain;...
             infoDenoise.mask.wm;...
             infoDenoise.mask.gm;...
             infoDenoise.mask.csf;...
             infoDenoise.mask.glob}; % 20140224
         
defAns{4} = {infoDenoise.motion.head;...
             infoDenoise.motion.deriv;...
             infoDenoise.motion.filetype;...
             '';...     %prefix
             infoDenoise.prefix};      %prefix

switch(mode)
    case 'btn_input'
        % 更新infoDenoise
        [infoDenoise.subj, infoDenoise.detrend, infoDenoise.mask, infoDenoise.motion] = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);
    case {'file_input','file_input_init'}
        infoDenoise.subj = defAns{1};
        infoDenoise.detrend = defAns{2};
        infoDenoise.mask = defAns{3};
        infoDenoise.motion = defAns{4};  % prefix
end


% 不管从哪里输入，都要检查一遍数据
if ~isempty(infoDenoise.subj) || ~isempty(infoDenoise.detrend) || ~isempty(infoDenoise.mask) || ~isempty(infoDenoise.motion)  %  按的不是cancel
    
    out.subj.timepoints = str2num(infoDenoise.subj{1});
    out.subj.voxelsize = str2num(infoDenoise.subj{2});
    
    out.detrend.constant = infoDenoise.detrend{1};
    out.detrend.linear_drift = infoDenoise.detrend{2};
    
    out.mask.wholebrain = infoDenoise.mask{1};
    out.mask.wm = infoDenoise.mask{2};
    out.mask.gm = infoDenoise.mask{3};
    out.mask.csf = infoDenoise.mask{4};
    out.mask.glob = infoDenoise.mask{5};  % 20140224
    
    
    out.motion.head = infoDenoise.motion{1};
    out.motion.deriv = infoDenoise.motion{2};
    
    out.prefix = infoDenoise.motion{4};  % prefix
    
    field_names = fieldnames(out); % fields of out
    tmp{1} = fieldnames(out.subj);
    tmp{2} = fieldnames(out.detrend);
    tmp{3} = fieldnames(out.mask);
    tmp{4} = fieldnames(out.motion);
    tmp{4}{4} = 'prefix';
    
    % 这里检测单个输入是否错误
    S = cell(4,1);
    for n = 1:4
        S{n} = cell(size(prompt{n},1),1);
        for m = 1:size(prompt{n},1)
            S{n}{m} = struct('type',        '.',...
                             'subs',        tmp{n}{m});
            % 检查第一列的数字有没出错
            if n == 1 && isempty(subsref(out.subj,S{n}{m}))
                warndlg([prompt{n}{m},32,'Input Invalid!'])
                return;
            % 检查第三列的mask文件有没出错
            elseif n == 3
                if ~isempty(subsref(out.mask,S{n}{m}))
                    % 检查一下mask的文件类型
                    % 待写
                end

            end
        end
    end

else
    % Cancel is pressed.
    varargout{1} = '';
    return;
end

% write the inputs into preprocessing_setting.txt

% write as a sign of the existance of removenoise parameters, nothing more
switch(mode)
    case 'btn_input'
        C{1} = brant_FileWrite('DENOISE PARAMETERS','selected',C{1});
    case 'file_input_init'
        C{1} = brant_FileWrite('DENOISE PARAMETERS','',C{1});
end

% write data in
for n = 1:length(infoDenoise.subj)
    C{1} = brant_FileWrite(strcat('denoise_',field_names{1},'_',tmp{1}{n}),infoDenoise.subj{n},C{1});
end

for n = 1:length(infoDenoise.detrend)
    C{1} = brant_FileWrite(strcat('denoise_',field_names{2},'_',tmp{2}{n}),infoDenoise.detrend{n},C{1});
end

for n = 1:length(infoDenoise.mask)
    C{1} = brant_FileWrite(strcat('denoise_',field_names{3},'_',tmp{3}{n}),infoDenoise.mask{n},C{1});
end

for n = 1:2
    C{1} = brant_FileWrite(strcat('denoise_',field_names{4},'_',tmp{4}{n}),infoDenoise.motion{n},C{1});
end

C{1} = brant_FileWrite('denoise_prefix',infoDenoise.motion{4},C{1}); %#ok<NASGU>
varargout{1} = C{1};
% set(findobj(0,'Tag','denoise_chb'),'Value',1);
if ~strcmp(mode,'file_input_init')
    brant_updateLabel('denoise',[infoDenoise.subj;infoDenoise.detrend;infoDenoise.mask;infoDenoise.motion{1};infoDenoise.motion{2};infoDenoise.motion{4}]);
end
