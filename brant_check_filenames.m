function varargout = brant_check_filenames(C, mode)

count = 1;
C_tmp = cell(length(C{1}), 1);
C{1} = strtrim(C{1});

switch mode
    case 'dirs'
        for m = 1:length(C{1})
            if isempty(C{1}{m})
                continue;
            else
                if exist(C{1}{m}, 'dir') == 7
                    C_tmp{count} = C{1}{m};
                    count = count + 1;
                else
                    fprintf('invalid input directory %s\n', C{1}{m})
                    varargout{1} = -1;
%                     return;
                end
            end
        end
    case 'imgs'
        for m = 1:length(C{1})
            if isempty(C{1}{m})
                continue;
            else
                if exist(C{1}{m}, 'file') == 2
                    [tmp1, tmp2, ext] = fileparts(C{1}{m});
                    switch(upper(ext))
                        case{'.IMG', '.NII', '.HDR'}
                            C_tmp{count} = C{1}{m};
                            count = count + 1;
                        otherwise
                            varargout{1} = -1;
                            return;
                    end
                else
                    varargout{1} = -1;
                    return;
                end
            end
        end
    case 'nc_dirs'
        C_tmp =  C{1};
end

varargout{1} = C_tmp;
