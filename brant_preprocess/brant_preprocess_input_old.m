function brant_preprocess_input(preps)

h_prep_main = findobj(0, 'Tag', 'brant_preprocess_main');

preps_all = get(h_prep_main, 'Userdata');
dlg_rstbtn = 0;

[dlg_title, coltitle, prompt, defAns] = brant_preprocess_parameters(preps, preps_all);
% prep_parameters{1} = brant_inputdlg(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);
prep_parameters{1} = brant_inputdlg_new(dlg_title, dlg_rstbtn, coltitle, prompt, defAns);

if ~isempty(prep_parameters{1})
    preps_all.(preps) = prep_parameters;
    set(h_prep_main, 'Userdata', preps);
end
