function [sts, errmsgs] = brant_check_input(prompt, dlg_out)

numel_eles = numel(prompt);
sts = 1;
errmsgs = '';

try
    for m = 1:numel_eles
        for n = 1:size(prompt{m}, 1)
            switch(prompt{m}{n, 2})
                case 'numeric'
                    num_tmp = str2num(dlg_out{m}{n});
                    if (isnumeric(num_tmp) & ~isempty(num_tmp)) ~= 1
                        error([prompt{m}{n, 1}, 32, dlg_out{m}{n}, 32, 'should be a number!']);
                    end
                case {'string', 'popup'}
                    if ischar(dlg_out{m}{n}) ~= 1
                        error([prompt{m}{n, 1}, 32, dlg_out{m}{n}, 32, 'should be a string!']);
                    end
                case {'box_file_img_tmp', 'file_txt'}
                    if ~isempty(dlg_out{m}{n})
                        if exist(dlg_out{m}{n}, 'file') ~= 2
                            error([prompt{m}{n, 1}, 32, dlg_out{m}{n}, 32, 'should be a regular file!']);
                        end
                    end
                case {'box_file_img_*', 'file_img_*'}
                    if isempty(dlg_out{m}{n}) || exist(dlg_out{m}{n}, 'file') ~= 2
                        error([prompt{m}{n, 1}, 32, dlg_out{m}{n}, 32, 'must be a regular file!']);
                    end
                case {'box', 'box_must'}
                    assert(isnumeric(dlg_out{m}{n}));
            end
        end
    end
catch err
    fprintf('\n');
    errmsgs = err.message;
end
