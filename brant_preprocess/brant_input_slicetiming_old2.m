function varargout = brant_input_slicetiming(mode, st)

h_prep_main = findobj(0, 'Tag', 'brant_preprocess_main');
varargout{1} = '';
switch(mode)
    case 'btn_input'
        
        dlg_rstbtn = 0;
        st_data = get(h_prep_main, 'Userdata');
        
        [dlg_title, coltitle, field_fun, subfield_fun, prompt, defAns] = brant_preprocess_parameters('Slice Timing', st_data);
        sliceinfo = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);

        % 按cancel的话就return
        if isempty(sliceinfo)
            return;
        else
            if isempty(subfield_fun)
                for m = 1:size(field_fun, 1)
                    for n = 1:size(prompt{1}, 1)
                        st_data.(field_fun{m}).(prompt{1}{n, 3}) = sliceinfo{n};
                    end
                end
            end
        end
	case {'file_input','file_input_init'}
        st_data.slicetiming = st;
end
set(h_prep_main, 'Userdata', st_data);
