function brant_updateLabel(varargin)
% varargin{1} is mode, varargin{2} is data in columns

h.infoboard = findobj(0,'Tag','info_label_chbd');
C = get(h.infoboard,'String');
        
switch upper(varargin{1})
    
    case 'REFRESH'
    case 'SLICE_TIMING',

        st_info = varargin{2};
        for n = 1:length(st_info)
            if isempty(st_info{n})
                st_info{n} = 'default';
            end
        end
        st_labels = {'slice order:','TR:','ref slice:','prefix:'};

        posST = find(strcmp('SLICE_TIMING',C), 1);
        lenC = length(C);
        if isempty(posST)
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 5 + notEmpty,1);
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'SLICE_TIMING';
            for m = [1,3,4]
                tmpcell{lenC + m + 1 + notEmpty} = strcat(st_labels{m},9,st_info{m});
            end
            tmpcell{lenC + 3 + notEmpty} = strcat(st_labels{2},9,st_info{2},32,'s');
            C = tmpcell;
        else
            for m = [1,3,4]
                C{posST + m} = strcat(st_labels{m},9,st_info{m});
            end
            C{posST + 2} = strcat(st_labels{2},9,st_info{2},32,'s');
        end

    case 'REALIGN',
        
        rea_info = varargin{2};
        for n = 1:length(rea_info)
            if isempty(rea_info{n})
                rea_info{n} = 'default';
            end
        end
        rea_labels = {'quality:','sep:','fwhm:','rtm:','wrap:','weight:','interp:',...
                      'which:','interp:','wrap:','mask:','prefix:'};

        posREA = find(strcmp('REALIGNMENT',C), 1);
        lenC = length(C);
        if isempty(posREA)
            
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 15 + notEmpty,1);
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'REALIGNMENT';
            tmpcell{lenC + 2 + notEmpty} = 'Estimate';
            for m = 1:7
                tmpcell{lenC + m + 2 + notEmpty} = strcat(rea_labels{m},9,rea_info{m});
            end
            tmpcell{lenC + 10 + notEmpty} = 'Write';
            for m = 11:15
                tmpcell{lenC + m + notEmpty} = strcat(rea_labels{m - 3},9,rea_info{m - 3});
            end
            C = tmpcell;
            
        else
            for m = 2:8
                C{posREA + m} = strcat(rea_labels{m - 1},9,rea_info{m - 1});
            end
            for m = 10:14
                C{posREA + m} = strcat(rea_labels{m - 2},9,rea_info{m - 2});
            end
        end

    case 'NORMALISE',
        
        nor_info = varargin{2};
        for n = 1:length(nor_info)
            if isempty(nor_info{n})
                nor_info{n} = 'default';
            end
            if iscell(nor_info{n})
                nor_info{n} = nor_info{n}{1}; % this change may not be safe
            end
        end
        nor_labels = {'source:','wtsrc:',...  % edited on 20140217
                      'template:','weight:','smosrc:','smoref:','regtype:','cutoff:','nits:','reg:',...
                      'preserve:','bb:','vox:','interp:','wrap:','prefix:'};

        posNOR = find(strcmp('NORMALISE',C), 1);
        lenC = length(C);
        if isempty(posNOR)
            
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 20 + notEmpty,1);
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'NORMALISE';
            tmpcell{lenC + 2 + notEmpty} = 'Subj';
            for m = 1:2
                tmpcell{lenC + m + 2 + notEmpty} = strcat(nor_labels{m},9,nor_info{m});
            end
            tmpcell{lenC + 5 + notEmpty} = 'Estimate';
            for m = 1:8
                tmpcell{lenC + m + 5 + notEmpty} = strcat(nor_labels{m + 2},9,nor_info{m + 2});
            end
            tmpcell{lenC + 14 + notEmpty} = 'Write';
            for m = 15:20
                tmpcell{lenC + m + notEmpty} = strcat(nor_labels{m - 4},9,nor_info{m - 4});
            end
            C = tmpcell;
            
        else
            for m = 2:3
                C{posNOR + m} = strcat(nor_labels{m - 1},9,nor_info{m - 1});
            end
            for m = 5:12
                C{posNOR + m} = strcat(nor_labels{m - 2},9,nor_info{m - 2});
            end
            for m = 14:19
                C{posNOR + m} = strcat(nor_labels{m - 3},9,nor_info{m - 3});
            end
        end
        
	case 'DENOISE',
        
        denoise_info = varargin{2};
        
        for n = 2:length(denoise_info)
            if isempty(denoise_info{n}) | denoise_info{n} == 0 %#ok<*OR2>
                denoise_info{n} = 'NA';
            end
        end

        for m = 1:length(denoise_info)
            if isnumeric(denoise_info{m})
                denoise_info{m} = num2str(denoise_info{m});
            end
        end
        
        denoise_labels = {'timepoints:','voxelsize:',...
                          'constant:','linear drift:',...
                          'whole brain:','white matter:','gray matter:','csf:', 'global mean:',...
                          'head motion:','motion deriv:','prefix:'};

        posDenoise = find(strcmp('DENOISE',C), 1);
        lenC = length(C);
        if isempty(posDenoise)
            
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 17 + notEmpty, 1); % prefix
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'DENOISE';
            
            tmpcell{lenC + 2 + notEmpty} = 'Subj';
            for m = 3:4
                tmpcell{lenC + m + notEmpty} = strcat(denoise_labels{m - 2},9,denoise_info{m - 2});
            end
            
            tmpcell{lenC + 5 + notEmpty} = 'GLM Corr';
            for m = 6:7
%                 if isnumeric(denoise_info{m - 3})
%                     denoise_info{m - 3} = num2str(denoise_info{m - 3});
%                 end
                tmpcell{lenC + m + notEmpty} = strcat(denoise_labels{m - 3},9,denoise_info{m - 3});
            end
            
            tmpcell{lenC + 8 + notEmpty} = 'Mask';
            for m = 9:13
                tmpcell{lenC + m + notEmpty} = strcat(denoise_labels{m - 4},9,denoise_info{m - 4});
            end
%             tmpcell{lenC + 13 + notEmpty} = strcat(denoise_labels{13 - 4},9,num2str(denoise_info{13 - 4}));
            tmpcell{lenC + 14 + notEmpty} = 'Motion CORR';
            for m = 15:17 % prefix
%                 if isnumeric(denoise_info{m - 5})
%                     denoise_info{m - 5} = num2str(denoise_info{m - 5});
%                 end
                tmpcell{lenC + m + notEmpty} = strcat(denoise_labels{m - 5},9,denoise_info{m - 5});
            end
            C = tmpcell;
            
        else
            for m = 2:3
                C{posDenoise + m} = strcat(denoise_labels{m - 1},9,denoise_info{m - 1});
            end
            for m = 5:6
%                 if isnumeric(denoise_info{m - 2})
%                     denoise_info{m - 2} = num2str(denoise_info{m - 2});
%                 end
                C{posDenoise + m} = strcat(denoise_labels{m - 2},9,denoise_info{m - 2});
            end
            for m = 8:12
                C{posDenoise + m} = strcat(denoise_labels{m - 3},9, denoise_info{m - 3});
            end
%             C{posDenoise + 14} = strcat(denoise_labels{14 - 3},9,num2str(denoise_info{14 - 3}));
            for m = 14:16 % prefix
%                 if isnumeric(denoise_info{m - 5})
%                     denoise_info{m - 5} = num2str(denoise_info{m - 5});
%                 end
                C{posDenoise + m} = strcat(denoise_labels{m - 4},9,denoise_info{m - 4});
            end
        end
        
	case 'FILTER',

        filter_info = varargin{2};
        for n = 1:length(filter_info)
            if isempty(filter_info{n})
                filter_info{n} = 'default';
            end
        end
        filter_labels = {'lower cutoff:', 'upper cutoff:', 'whole brain:', 'TR:','timepoints:','prefix:'};

        posFILTER = find(strcmp('FILTER',C), 1);
        lenC = length(C);
        if isempty(posFILTER)
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 7 + notEmpty,1);
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'FILTER';
            for m = 1:2
                tmpcell{lenC + m + 1 + notEmpty} = strcat(filter_labels{m},9,filter_info{m},32,'Hz');
            end
            tmpcell{lenC + 4 + notEmpty} = strcat(filter_labels{3},9,filter_info{3});
            tmpcell{lenC + 5 + notEmpty} = strcat(filter_labels{4},9,filter_info{4},32,'s');
            tmpcell{lenC + 6 + notEmpty} = strcat(filter_labels{5},9,filter_info{5});
            tmpcell{lenC + 7 + notEmpty} = strcat(filter_labels{6},9,filter_info{6});
            C = tmpcell;
        else
            for m = 1:2
                C{posFILTER + m} = strcat(filter_labels{m},9,filter_info{m},32,'Hz');
            end
            C{posFILTER + 3} = strcat(filter_labels{3},9,filter_info{3});
            C{posFILTER + 4} = strcat(filter_labels{4},9,filter_info{4},32,'s');
            C{posFILTER + 5} = strcat(filter_labels{5},9,filter_info{5});
            C{posFILTER + 6} = strcat(filter_labels{6},9,filter_info{6});
        end

	case 'SMOOTH',

        smooth_info = varargin{2};
        for n = 1:length(smooth_info)
            if isempty(smooth_info{n})
                smooth_info{n} = 'default';
            end
        end
        smooth_labels = {'fwhm:','prefix:'};

        posSMOOTH = find(strcmp('SMOOTH',C), 1);
        lenC = length(C);
        if isempty(posSMOOTH)
            if lenC == 0
                notEmpty = 0;
            else
                notEmpty = 1;
            end
            
            tmpcell = cell(lenC + 3 + notEmpty,1);
            if lenC ~= 0
                for m = 1:lenC
                    tmpcell{m} = C{m};
                end
            end
            tmpcell{lenC + 1 + notEmpty} = 'SMOOTH';
            for m = 1:2
                tmpcell{lenC + m + 1 + notEmpty} = strcat(smooth_labels{m},9,smooth_info{m});
            end

            C = tmpcell;
        else
            for m = 1:2
                C{posSMOOTH + m} = strcat(smooth_labels{m},9,smooth_info{m});
            end
        end
end

set(h.infoboard,'String',C);

hCheckBoard = findobj(0,'Tag','figCheckBoard');
if strcmp(get(hCheckBoard,'Visible'),'on')
    figure(hCheckBoard);
end
