function help_strs = brant_help_information(dlg_title)

brant_path = fileparts(which('brant'));
brant_help_path = fullfile(brant_path, 'help');

dlg_title = regexprep(dlg_title, '[$|.*+?\\\/]', '_');
brant_help_file = fullfile(brant_help_path, [lower(dlg_title), '.txt']);

help_strs = '';
if exist(brant_help_file, 'file') == 2
    help_strs_tmp = importdata(brant_help_file, '\n');
    help_strs = char(help_strs_tmp);
else
    warning('No help file %s can be found!', brant_help_file)
end
