function varargout = brant_FileWrite(varargin)
% 参数分别是索引的项目，索引项目值，索引的cell array
% 该函数功能是将索引的项目更新到txt文件中，并更新cell array

strIn = strcat(varargin{1},':');
% 索引值的位置
pos = find(strcmp(strIn,varargin{3}));
% 原cell array总长度
oldTotLen = length(varargin{3});

% 大写的就是标题。
if strcmp(varargin{1},upper(varargin{1}))
    input_title = 1;
else
    input_title = 0;
end

if ~isempty(pos) && input_title == 0    % 找到了，输入的不是标题
    
    % 原索引值的长度
    oldIndexLen = str2num(varargin{3}{pos + 1});
    
    % 判断输入类型
	if isnumeric(varargin{2})
        varargin{3}{pos + 2} = num2str(varargin{2});
        tmpcell = varargin{3};
        
    elseif ischar(varargin{2})
        varargin{3}{pos + 2} = varargin{2};
        tmpcell = varargin{3};
        
    elseif iscell(varargin{2})
        newIndexLen = length(varargin{2});
        oldEndIndex = pos + 1 + oldIndexLen;
        newEndIndex = pos + 1 + newIndexLen;
        newTotLen = oldTotLen + newEndIndex - oldEndIndex;
        tmpcell = cell(newTotLen, 1);
        
        for n = 1:pos
            tmpcell{n} = varargin{3}{n};
        end
        tmpcell{pos + 1} = num2str(newIndexLen);
        for n = 1:newIndexLen
            tmpcell{pos + 1 + n} = varargin{2}{n};
        end
        
        if oldEndIndex < oldTotLen
            for m = 1:oldTotLen - oldEndIndex
                tmpcell{pos + 1 + newIndexLen + m} = varargin{3}{oldEndIndex + m};        
            end
        end
	end
    
elseif isempty(pos) && input_title == 0     % 没找到并且输入的不是标题    % pos为0，没找到值，建立新值
        if ischar(varargin{2})
            newIndexLen = 1;
        else
            newIndexLen = length(varargin{2});
        end
        newTotLen = oldTotLen + newIndexLen + 2;
        tmpcell = cell(newTotLen ,1);
        for n = 1:oldTotLen
            tmpcell{n} = varargin{3}{n};
        end
        tmpcell{oldTotLen + 1} = strIn;

        if isnumeric(varargin{2}) || ischar(varargin{2})
            tmpcell{oldTotLen + 2} = '1';
            tmpcell{oldTotLen + 3} = num2str(varargin{2});

        elseif ischar(varargin{2})
            tmpcell{oldTotLen + 2} = '1';
            tmpcell{oldTotLen + 3} = varargin{2};

        elseif iscell(varargin{2})

            tmpcell{oldTotLen + 2} = num2str(newIndexLen);
            for n = 1:newIndexLen
                tmpcell{oldTotLen + 2 + n} = varargin{2}{n};
            end
        end
elseif isempty(pos) && input_title == 1     % 没找到并输入的是标题
        tmpcell = cell((oldTotLen+3),1);
        for n = 1:oldTotLen
            tmpcell{n} = varargin{3}{n};
        end
        tmpcell{oldTotLen+1} = '';
        tmpcell{oldTotLen+2} = strIn;
        tmpcell{oldTotLen+3} = varargin{2};
else    %找到了并且是标题
        tmpcell = varargin{3};
        tmpcell{pos + 1} = varargin{2};
end

filepath = get(findobj(0,'Tag','dir_text'),'String');
pathfile = fileparts(filepath);
indexfile = fullfile(pathfile,'brant_preprocessing_settings.txt');
fid = fopen(indexfile,'wt');
for n = 1:length(tmpcell)
    fprintf(fid, '%s\n', tmpcell{n});  % \r\n
end
fclose(fid);

varargout{1} = tmpcell;
