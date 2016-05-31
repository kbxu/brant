function out = brant_FileRead(varargin)
% ����ܲ���ͷ�ҵ��˵�����Ĳ���ȱʧ���ᷢ�����?
% varargin{1} is working mode
% varargin{2} is a cell array of strings read from *.txt
% varargin{3} is the file type

C = varargin;

if nargin == 3
    InitialType = C{3};     %ע����࣬�Ժ��ٸģ�?
end

switch upper(C{1})

    case 'INITDIR'  % Read folder paths from selected txt file ��preprocessing.txt��s�·��?
        
        posInitDir = find(strcmp('Directory:',C{2}{1}),1);  %Find the postition of slice timing
        if posInitDir ~= 0
            shiftDIR = str2num(C{2}{1}{posInitDir + 1});
            storeFilepath = cell(shiftDIR,1);
            for n = 1:shiftDIR
                storeFilepath{n} = C{2}{1}{posInitDir + 1 + n};
            end
            out = storeFilepath;
        else
            m = 0;
            for n = 1:length(C{2}{1})
                if ~isempty(C{2}{1}{n})
                    m = m + 1;
                    out{m} = C{2}{1}{n}; %#ok<*AGROW>
                end
            end
        end
        
        for n = 1:length(out)
            if ~isdir(out{n})
                out = {};
                errordlg({'Directory input error!','Please check your input file!'});
                return;
            end
        end
        
        
    case 'DIR'      % Read paths from selected directories ����ͬ·���µ��ļ���s�P����
        % Read path info
        posDIR = find(strcmp('Directory:',C{2}{1}),1);  %Find the postition of slice timing
        if ~isempty(posDIR)
            shiftDIR = str2num(C{2}{1}{posDIR + 1});
            P = cell(shiftDIR, 1);
            out.is4d = zeros(shiftDIR, 1);
            subjnames = cell(shiftDIR, 1);
            for n = 1:shiftDIR
                Ptmp = dir(fullfile(C{2}{1}{posDIR + 1 + n}, InitialType)); % 10*33 char
                nfile = numel(Ptmp);   % ���������?
                if strcmp(InitialType(1:4), 'mean')
                    if nfile > 1
                        error([[9, 'More than one', 32, '''mean*''', 32, 'file were found in directory', 32, C{2}{1}{posDIR + 1 + n}], 13, 9, 'Please remove the others (left one in each directory only)']);
                    end
                end
                if nfile == 0
                    fprintf('%s\n', fullfile(C{2}{1}{posDIR + 1 + n}, InitialType));%% printf the wrong subject
                    error([9, 'No', 32, InitialType, 32, 'files found in', 32, fullfile(C{2}{1}{posDIR + 1 + n}, InitialType)]);
                elseif nfile == 1
                    PP = cell(1);
                    fn_tmp = fullfile(C{2}{1}{posDIR + 1 + n}, Ptmp(1).name);
                    file_size = get_nii_frame(fn_tmp);
                    subjnames{n}{1} = fn_tmp;
                    if file_size == 1
                        out.is4d(n) = 0;
                        PP{1} = [fn_tmp,',001'];
                    elseif file_size > 1
                        out.is4d(n) = 1;
                        for vol_id = 1:file_size
                            PP{1} = [PP{1}; [fn_tmp, ',', sprintf('%03d', vol_id)]]; % �ַ����Ҫ���������
                        end
                    end
                elseif nfile > 1
                    PP = cell(1);
                    subjnames{n} = cell(nfile, 1);
                    for m = 1:nfile
                        fn_tmp = fullfile(C{2}{1}{posDIR + 1 + n}, Ptmp(m).name);
                        subjnames{n}{m} = fn_tmp;
                        file_size = get_nii_frame(fn_tmp);
                        if file_size == 1
                            out.is4d(n) = 0;
                            PP{1} = [PP{1}; [fn_tmp,',001']]; % �ַ����Ҫ���������
                        elseif file_size > 1
                            error([[9, 'More than one', 32, '''mean*''', 32, 'file were found in directory', 32, C{2}{1}{posDIR + 1 + n}], 13, 9, 'Please remove the others (left one in each directory only)']);
                        end
                    end
                end
                
                P{n} = PP; % 2*1 cell P{n} = PP{1};
            end
            out.P = P;
            out.nsubjects = shiftDIR;
            out.subjs = subjnames;
        else
            out.P = {};
            out.nsubjects = 0;
            out.subjs = '';
        end
        
	case 'SLICETIMING'
        
        posST = find(strcmp('SLICETIMING PARAMETERS:',C{2}{1}), 1);
        if ~isempty(posST) && ~strcmp(C{2}{1}{posST+2}(end-4:end-3),'NA')
        
            % search for slice order info
            posSO = find(strcmp('st_slice_order:',C{2}{1}));
            shiftSO = str2num(C{2}{1}{posSO + 1});
            if shiftSO ~= 0                         % ������²������0
                SOtmp = C{2}{1}{posSO + 1 + 1};     % slice order����Ϊ1
                if shiftSO > 1
                    for n = 2:shiftSO
                        SOtmp = strcat(SOtmp,32,C{2}{1}{posSO + 1 + n});
                    end
                    out.slice_order = SOtmp;
                else
                    out.slice_order = SOtmp;
                end
            end

            % Read reference slice info
            posRefSlice = find(strcmp('st_refslice:',C{2}{1}),1);
            refslice = C{2}{1}{posRefSlice + 2};
            out.refslice = str2num(refslice);

            % Read timing info
            posTR = find(strcmp('st_tr(s):',C{2}{1}),1);
            nslice = length(str2num(out.slice_order));
            TR = str2num(C{2}{1}{posTR + 2});
            TA = TR - TR/nslice;
            timing(1) = TA / (nslice -1);
            timing(2) = TR - TA;
            out.timing = timing;
            out.tr = TR;

            % Read prefix info
            posPrefix = find(strcmp('st_prefix:',C{2}{1}),1);
            prefix = C{2}{1}{posPrefix + 2};
            out.prefix = prefix;

        else
            out.slice_order = '0';      % ����һ��Ҫ�s��ַ��ͷ�������ܶ�ط���?
            out.refslice = 0;
            out.timing = [];
            out.tr = 0;
            out.prefix = 'a';
        end
        
    case 'REALIGN',
        
        posRealign = find(strcmp('REALIGN PARAMETERS:',C{2}{1}), 1);
        if ~isempty(posRealign) 
            
            % read estimate info
            realign_est = {'rea_est_quality:',...
                           'rea_est_sep:',...
                           'rea_est_fwhm:',...
                           'rea_est_rtm:',...
                           'rea_est_wrap:',...
                           'rea_est_weight:',...
                           'rea_est_interp:'};
            
            est_tmp = cell(length(realign_est),1);
            for n = 1:length(realign_est)
                est_pos = find(strcmp(realign_est{n},C{2}{1}),1);
                if ~isempty(est_pos)
                    est_val = C{2}{1}{est_pos + 2};
                    est_tmp{n} = est_val;
                end
            end
            
            out.eoptions.quality = str2num(est_tmp{1});
            out.eoptions.sep = str2num(est_tmp{2});
            out.eoptions.fwhm = str2num(est_tmp{3});
            out.eoptions.rtm = str2num(est_tmp{4});
            out.eoptions.wrap = str2num(est_tmp{5});
            out.eoptions.weight = est_tmp{6};
            out.eoptions.interp = str2num(est_tmp{7});
            
            % read write info
            realign_wri = {'rea_wri_which:',...
                           'rea_wri_interp:',...
                           'rea_wri_wrap:',...
                           'rea_wri_mask:',...
                           'rea_wri_prefix:'};
            
            wri_tmp = cell(length(realign_wri),1);
            for n = 1:length(realign_wri)
                wri_pos = find(strcmp(realign_wri{n},C{2}{1}),1);
                if ~isempty(wri_pos)
                    wri_val = C{2}{1}{wri_pos + 2};
                    wri_tmp{n} = wri_val;
                end
            end
            
            out.roptions.which = str2num(wri_tmp{1});
            out.roptions.interp = str2num(wri_tmp{2});
            out.roptions.wrap = str2num(wri_tmp{3});
            out.roptions.mask = str2num(wri_tmp{4});
            out.roptions.prefix = wri_tmp{5};

            
        else
            out = brant_default_realign;
        end
        
        
    case 'NORMALISE',

    posNormalise = find(strcmp('NORMALISE PARAMETERS:',C{2}{1}),1);
    if posNormalise ~= 0           

        % read subj info
        normalise_subj = {'nor_subj_wtsrc:',...
                          'nor_subj_source:'};
        
        subj_tmp = cell(length(normalise_subj),1);
        for n = 1:length(normalise_subj)
            subj_pos = find(strcmp(normalise_subj{n},C{2}{1}),1);
            if ~isempty(subj_pos)
                subj_val = C{2}{1}{subj_pos + 2};
                subj_tmp{n} = subj_val;
            end
        end

        out.subj.wtsrc = subj_tmp{1};
        out.subj.source = subj_tmp{2};%#ok<*ST2NM>
        
        
        % read estimate info
        normalise_est = {'nor_est_template:',...
                         'nor_est_weight:',...
                         'nor_est_smosrc:',...
                         'nor_est_smoref:',...
                         'nor_est_regtype:',...
                         'nor_est_cutoff:',...
                         'nor_est_nits:',...
                         'nor_est_reg:'};

        est_tmp = cell(length(normalise_est),1);
        for n = 1:length(normalise_est)
            est_pos = find(strcmp(normalise_est{n},C{2}{1}),1);
            if ~isempty(est_pos)
                est_val = C{2}{1}{est_pos + 2};
                est_tmp{n} = est_val;
            end
        end

        out.eoptions.template = {est_tmp{1}};
        out.eoptions.weight = {est_tmp{2}};
        out.eoptions.smosrc = str2num(est_tmp{3});
        out.eoptions.smoref = str2num(est_tmp{4});
        out.eoptions.regtype = est_tmp{5};
        out.eoptions.cutoff = str2num(est_tmp{6});
        out.eoptions.nits = str2num(est_tmp{7});
        out.eoptions.reg = str2num(est_tmp{8}); %#ok<*ST2NM>

        % read write info
        normalise_wri = {'nor_wri_preserve:',...
                         'nor_wri_bb:',...
                         'nor_wri_vox:',...
                         'nor_wri_interp:',...
                         'nor_wri_wrap:',...
                         'nor_wri_prefix:'};
        
        wri_tmp = cell(length(normalise_wri),1);
        for n = 1:length(normalise_wri)
            wri_pos = find(strcmp(normalise_wri{n},C{2}{1}),1);
            if ~isempty(wri_pos)
                wri_val = C{2}{1}{wri_pos + 2};
                wri_tmp{n} = wri_val;
            end
        end

        out.roptions.preserve = str2num(wri_tmp{1});
        out.roptions.bb = str2num(wri_tmp{2});
        out.roptions.vox = str2num(wri_tmp{3});
        out.roptions.interp = str2num(wri_tmp{4});
        out.roptions.wrap = str2num(wri_tmp{5});
        out.roptions.prefix = wri_tmp{6};


    else
        out = brant_default_normalise;
    end
    
    case 'DENOISE',

        posDenoise = find(strcmp('DENOISE PARAMETERS:',C{2}{1}),1);
        posProb = find(strcmp('denoise_subj_timepoints:',C{2}{1}),1);
        if ~isempty(posDenoise) && ~isempty(posProb)

            % read subj info
            denoise_subj = {'denoise_subj_timepoints:',...
                            'denoise_subj_voxelsize:'};

            subj_tmp = cell(length(denoise_subj),1);
            for n = 1:length(denoise_subj)
                subj_pos = find(strcmp(denoise_subj{n},C{2}{1}),1);
                if ~isempty(subj_pos)
                    subj_val = C{2}{1}{subj_pos + 2};
                    subj_tmp{n} = subj_val;
                end
            end

            out.subj.timepoints = str2num(subj_tmp{1});
            out.subj.voxelsize = str2num(subj_tmp{2});

            % read glm info
            denoise_detrend = {'denoise_detrend_constant:',...
                           'denoise_detrend_linear_drift:'};
            detrend_tmp = cell(length(denoise_detrend),1);
            for n = 1:length(denoise_detrend)
                detrend_pos = find(strcmp(denoise_detrend{n},C{2}{1}), 1);
                if ~isempty(detrend_pos)
                    detrend_val = C{2}{1}{detrend_pos + 2};
                    detrend_tmp{n} = detrend_val;
                end
            end

            out.detrend.constant = str2num(detrend_tmp{1});
            out.detrend.linear_drift = str2num(detrend_tmp{2});

            % read mask info
            denoise_mask = {'denoise_mask_wholebrain:',...
                            'denoise_mask_wm:',...
                            'denoise_mask_gm:',...
                            'denoise_mask_csf:'...
                            'denoise_mask_glob:'}; % 20140214

            mask_tmp = cell(length(denoise_mask),1);
            for n = 1:length(denoise_mask)
                mask_pos = find(strcmp(denoise_mask{n},C{2}{1}),1);
                if ~isempty(mask_pos)
                    mask_val = C{2}{1}{mask_pos + 2};
                    mask_tmp{n} = mask_val;
                end
            end

            out.mask.wholebrain = mask_tmp{1};
            out.mask.wm = mask_tmp{2};
            out.mask.gm = mask_tmp{3};
            out.mask.csf = mask_tmp{4};
            out.mask.glob = str2num(mask_tmp{5});% 20140214


            % read motion info
            denoise_motion = {'denoise_motion_head:',...
                              'denoise_motion_deriv:'};

            motion_tmp = cell(length(denoise_motion),1);
            for n = 1:length(denoise_motion)
                motion_pos = find(strcmp(denoise_motion{n},C{2}{1}),1);
                if ~isempty(motion_pos)
                    motion_val = C{2}{1}{motion_pos + 2};
                    motion_tmp{n} = motion_val;
                end
            end

            out.motion.head = str2num(motion_tmp{1});
            out.motion.deriv = str2num(motion_tmp{2});

             % read prefix info
            denoise_prefix = {'denoise_prefix:'};

            prefix_pos = find(strcmp(denoise_prefix,C{2}{1}),1);
            if ~isempty(prefix_pos)
                prefix_tmp = C{2}{1}{prefix_pos + 2};
            end

            out.prefix = prefix_tmp;

        else
            out = brant_default_denoise;
            
            posDir = find(strcmp('Directory:',C{2}{1}),1);
            if ~isempty(posDir)
                filetype = get(findobj(0,'Tag','filetype_text'),'String');
                dir_sample = C{2}{1}{posDir + 2};
                tmp_files = dir(fullfile(dir_sample,filetype));
                if size(tmp_files,1) == 1
                    nii_tmp = spm_vol(fullfile(dir_sample,tmp_files.name));
                    out.subj.timepoints = length(nii_tmp);
                else
                    out.subj.timepoints = size(tmp_files,1);
                end
                
            end
        end
    
    case 'FILTER'
        
        posFT = find(strcmp('FILTER PARAMETERS:',C{2}{1}), 1);
        posProb = find(strcmp('filter_lower_cutoff:',C{2}{1}),1);
        if ~isempty(posFT) && ~isempty(posProb)
            % search for filter info
            posLC = find(strcmp('filter_lower_cutoff:',C{2}{1}),1);
            out.lower_cutoff = str2num(C{2}{1}{posLC + 2});

            % Read filter info
            posUC = find(strcmp('filter_upper_cutoff:',C{2}{1}),1);
            out.upper_cutoff = str2num(C{2}{1}{posUC + 2});

            % Read whole brain mask
            posWB = find(strcmp('filter_wb_mask:',C{2}{1}),1); %st_tr(s)
            out.wb_mask = C{2}{1}{posWB + 2};
            
            % Read timing info
            posTR = find(strcmp('filter_tr(s):',C{2}{1}),1); %st_tr(s)
            out.tr = str2num(C{2}{1}{posTR + 2});

            posTP = find(strcmp('filter_timepoints:',C{2}{1}),1);
            out.timepoints = str2num(C{2}{1}{posTP + 2});

            posPrefix = find(strcmp('filter_prefix:',C{2}{1}),1);
            out.prefix = C{2}{1}{posPrefix + 2};
            
        else
            out.lower_cutoff = 0.01;
            out.upper_cutoff = 0.08;
            out.wb_mask = '';
            out.tr = 0;
            out.timepoints = 0;
            out.prefix = 'f';
            
            posDir = find(strcmp('Directory:',C{2}{1}),1);
            if ~isempty(posDir)
                filetype = get(findobj(gcf,'Tag','filetype_text'),'String');
                dir_sample = C{2}{1}{posDir + 2};
                tmp_files = dir(fullfile(dir_sample, filetype));
                if length(tmp_files) == 1
                    out.timepoints = length(spm_vol(fullfile(dir_sample, tmp_files(1).name)));
                else
                    out.timepoints = length(tmp_files);
                end
            end
        end
        
	case 'SMOOTH'
        
        posSMOOTH = find(strcmp('SMOOTH PARAMETERS:',C{2}{1}), 1);
        if ~isempty(posSMOOTH)
            % search for filter info
            posFWHM = find(strcmp('smooth_fwhm:',C{2}{1}),1);
            out.fwhm = str2num(C{2}{1}{posFWHM + 2});

            % Read filter info
            posPREFIX = find(strcmp('smooth_prefix:',C{2}{1}),1);
            out.prefix = C{2}{1}{posPREFIX + 2};

        else
            out.fwhm = [8 8 8];
            out.prefix = 's';
        end
            
end
