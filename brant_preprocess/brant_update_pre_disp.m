function string_disp = brant_update_pre_disp

h_main = findobj(0, 'Name',             'brant_Preprocessing',...
                    'Tag',              'brant_preprocess_main');

h_disp = findobj(0, 'Name',             'brant_CheckBoard',...
                    'Tag',              'brant_preprocess_check');

h_para_disp = findobj(h_disp, 'Tag', 'info_label_chbd');
h_para_disp_sel = findobj(h_disp, 'Tag', 'disp_only_sel_chbd');
only_sel_disp = get(h_para_disp_sel, 'Value');

if isempty(h_main) || isempty(h_disp)
    error('Brant preprocessing main figure is not open!');
end

main_data = get(h_main, 'Userdata');
string_disp = '';
cnt = 1;

m_steps = numel(main_data.pref.order);
str_sel = '';

for m = 1:m_steps
    

        if only_sel_disp == 0
            if main_data.ind.(main_data.pref.order{m}) == 1
                str_sel = 'selected';
            else
                str_sel = 'not selected';
            end
        else
            if main_data.ind.(main_data.pref.order{m}) == 0
                continue;
            end
        end
        string_disp{cnt, 1} = strcat(upper(main_data.pref.order{m}), 32, str_sel);
        cnt = cnt + 1;
        sub_fields = fieldnames(main_data.(main_data.pref.order{m}));
        n_sub = numel(sub_fields);
        for n = 1:n_sub
            if isstruct(main_data.(main_data.pref.order{m}).(sub_fields{n}))
                string_disp{cnt, 1} = strcat(upper(sub_fields{n}(1)), sub_fields{n}(2:end), ':');
                cnt = cnt + 1;
                sub_sub_fields = fieldnames(main_data.(main_data.pref.order{m}).(sub_fields{n}));
                n_sub_sub = numel(sub_sub_fields);
                for nn = 1:n_sub_sub
                    if isnumeric(main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn}))
                        str_tmp = num2str(main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn}));
                        
                        if size(str_tmp, 1) > 1
                            str_cell = cellstr(str_tmp);
                            str_edit = sprintf('%s;',str_cell{:});
                            str_tmp = str_edit(1:end-1);
                        end
                    else
                        str_tmp = main_data.(main_data.pref.order{m}).(sub_fields{n}).(sub_sub_fields{nn});
                    end
                    string_disp{cnt, 1} = sprintf('%-25s\t%s', [sub_sub_fields{nn}, ':'], str_tmp);
                    cnt = cnt + 1;
                end
            else
                if isnumeric(main_data.(main_data.pref.order{m}).(sub_fields{n}))
                    str_tmp = num2str(main_data.(main_data.pref.order{m}).(sub_fields{n}));
                    
                    if size(str_tmp, 1) > 1
                        str_cell = cellstr(str_tmp);
                        str_edit = sprintf('%s;',str_cell{:});
                        str_tmp = str_edit(1:end-1);
                    end
                else
                    str_tmp = main_data.(main_data.pref.order{m}).(sub_fields{n});
                end
                string_disp{cnt, 1} = sprintf('%-25s\t%s', [sub_fields{n}, ':'], str_tmp);
                cnt = cnt + 1;
            end
        end
        string_disp{cnt, 1} = '';
        cnt = cnt + 1;
    
end

set(h_para_disp, 'String', string_disp);
figure(h_disp);
