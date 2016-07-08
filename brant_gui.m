function brant_gui(userdata)

[jobman, ui_strucs, process_fun] = brant_postprocess_defaults(userdata);
brant_postprocesses_sub(userdata, jobman, ui_strucs, process_fun);