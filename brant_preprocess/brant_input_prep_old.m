function brant_input_prep(calc_type, h_prep_main)

dlg_rstbtn = 0;
data_fig = get(h_prep_main, 'Userdata');

[dlg_title, sub_title_field, prompt, defAns] = brant_preprocess_parameters(calc_type, data_fig);
brant_inputdlg_new(dlg_title, dlg_rstbtn, sub_title_field, prompt, defAns, calc_type, h_prep_main);
