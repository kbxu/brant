function C = brant_prep_input(mode, varin_tmp)

switch(mode)
    case 'btn_input'
        filedir = get(findobj(gcf,'Tag','dir_text'),'String');
        if isempty(filedir)
            warndlg('Please input directories first!');
            C = '';
            return;
        end
        pathfile = fileparts(filedir);
        indexfile = fullfile(pathfile,'brant_preprocessing_settings.txt');
        fid = fopen(indexfile);
        if fid == -1
            warndlg('Please input valid directories first!');
            C = '';
            return;
        end
        C = textscan(fid, '%s', 'delimiter', '\n');
        fclose(fid);
	case {'file_input','file_input_init'}
        C = varin_tmp{1};
end
