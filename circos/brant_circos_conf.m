function brant_circos_conf(jobman)
% must there be two columns for roi file: label, module, size(optional),
% index_module -> module order on circos, index_node -> node order in the module
% number of roi must equal the size of edge matrix
% the order of ROIs in table must be consistant with edge matrix
% to change the order of visualization in circos, modify 'index' column

circos_dir = jobman.circos_dir{1};
conf_dir = jobman.conf_dir{1};
roi_file = jobman.roi_info{1};
link_file = jobman.edge{1};
pos_color = round(jobman.pos_color * 255);
neg_color = round(jobman.neg_color * 255);
% chromo_units = jobman.chromo_units;
out_dir = jobman.out_dir{1};

if exist(out_dir, 'dir') ~= 7, mkdir(out_dir); end

if (jobman.transparent_bkg == 0)
    bkg_str = 'white';
else
    bkg_str = 'transparent';
end

label_fn = fullfile(out_dir, 'brant_labels.txt');
band_fn = fullfile(out_dir, 'brant_band.txt');
link_fn = fullfile(out_dir, 'brant_links.txt');

out_dir = regexprep(out_dir, '[\/\\]+$', '');

if (ispc == 1)
    bat_fn = fullfile(out_dir, 'brant_circos_cmd.bat');
    fid = fopen(bat_fn, 'wt');
    fprintf(fid, '@echo off\n');
    fprintf(fid, 'set circosbin="%s"\n', fullfile(circos_dir, 'circos'));
    fprintf(fid, 'set circosconf="%s"\n', fullfile(conf_dir, 'circos.conf'));
    fprintf(fid, 'set labelfile="%s"\n', label_fn);
    fprintf(fid, 'set bandfile="%s"\n', band_fn);
    fprintf(fid, 'set linkfile="%s"\n', link_fn);
    fprintf(fid, 'set outdir="%s"\n', out_dir);
    fprintf(fid, ['%%circosbin%% -conf %%circosconf%% -param image/background=%s -param karyotype=%%bandfile%%', 32,...
                  '-param plots/plot/file=%%labelfile%% -param links/link/file=%%linkfile%% -outputdir %%outdir%%'], bkg_str);
    fclose(fid);
else
    bat_fn = fullfile(out_dir, 'brant_circos_cmd.sh');
    fid = fopen(bat_fn, 'wt');
    fprintf(fid, '#!/usr/bin/env bash\n\n');
    fprintf(fid, 'chmod u+x "%s"\n', fullfile(circos_dir, 'circos'));
    fprintf(fid, 'circosbin="%s"\n', fullfile(circos_dir, 'circos'));
    fprintf(fid, 'circosconf="%s"\n', fullfile(conf_dir, 'circos.conf'));
    fprintf(fid, 'labelfile="%s"\n', label_fn);
    fprintf(fid, 'bandfile="%s"\n', band_fn);
    fprintf(fid, 'linkfile="%s"\n', link_fn);
    fprintf(fid, 'outdir="%s"\n', out_dir);
    fprintf(fid, ['${circosbin} -conf ${circosconf} -param image/background=%s -param karyotype=${bandfile}', 32,...
                  '-param plots/plot/file=${labelfile} -param links/link/file=${linkfile} -outputdir ${outdir}'], bkg_str);
    fclose(fid);
end

% circos parameter
spin_sa = 10000;

node_in = brant_parse_node_circos(roi_file);
% node_in.label = cellfun(@(x) regexprep(x, '\W', '_'), node_in.label, 'UniformOutput', false);
% node_in.module = cellfun(@(x) regexprep(x, '\W', '_'), node_in.module, 'UniformOutput', false);
fc_mat = load(link_file);

num_node = size(node_in.label, 1);
if (num_node ~= size(fc_mat, 1))
    error('The number of roi must equal the size of edge matrix!');
end

diag_ind = logical(eye(num_node));
fc_mat(diag_ind) = 0;

if (isequal(fc_mat, fc_mat') == 0)
    error('FC matrix must be symmetric!');
end

% original order, module order, node order
index_mat = [(1:num_node)', node_in.index_module, node_in.index_node];

% now sort by module order then node order.
srt_index_mat = sortrows(index_mat, 2);
module_ind_uniq = unique(srt_index_mat(:, 2));
for m = 1:size(module_ind_uniq)
    row_ind = srt_index_mat(:, 2) == module_ind_uniq(m);
    srt_index_mat(row_ind, :) = sortrows(srt_index_mat(row_ind, :), 3);
end
% now columns are sorted first by module order then by node order.

node_info = [node_in.label, node_in.module];
node_info_srt = node_info(srt_index_mat(:, 1), :);


[lobe_num, ind] = unique(srt_index_mat(:, 2));
lobe_label_uniq = node_info_srt(ind, 2);
lobe_num_sum = arrayfun(@(x) sum(srt_index_mat(:, 2) == x), lobe_num);

% % define lobes and subareas.


% plot sub-area labels
fid = fopen(label_fn, 'wt');
arrayfun(@(x) fprintf(fid, 'lobe%d %d %d %s\n', srt_index_mat(x, 2),...
                                                (srt_index_mat(x, 3) - 1) * spin_sa,...
                                                (srt_index_mat(x, 3) - 1) * spin_sa + (spin_sa - 1), node_info_srt{x, 1}),...
                                                (1:num_node)');
fclose(fid);

% plot band file
fid = fopen(band_fn, 'wt');
arrayfun(@(x, y, z, k) fprintf(fid, 'chr - lobe%d %s 0 %d chr%d\n',...
                    z, x{1}, (y * spin_sa - 1), k), lobe_label_uniq, lobe_num_sum, lobe_num, (1:size(lobe_num, 1))');

color_tmp = cell(size(srt_index_mat, 1), 1);
color_tmp(1:2:end) = {'gpos'};
color_tmp(2:2:end) = {'gneg'};
    

for m = 1:numel(lobe_num)
    s_ind = find(srt_index_mat(:, 2) == lobe_num(m), 1, 'first');
    e_ind = find(srt_index_mat(:, 2) == lobe_num(m), 1, 'last');
    arrayfun(@(x) fprintf(fid, 'band lobe%d %s %s %d %d %s\n',...
                        lobe_num(m), node_info_srt{x, 1}, node_info_srt{x, 1},...
                        (x - s_ind) * spin_sa,...
                        (x - s_ind) * spin_sa + spin_sa - 1,...
                        color_tmp{x}),...
                        s_ind:e_ind);
end
fclose(fid);

up_ind = triu(ones(num_node, num_node), 1);
fc_mat_src = fc_mat(srt_index_mat(:, 1), srt_index_mat(:, 1));
[x_ind, y_ind] = find(fc_mat_src .* up_ind);
link_sign = arrayfun(@(x, y) sign(fc_mat_src(x, y)), x_ind, y_ind);


% plot link file
red_ind = link_sign > 0;
fc_strs = cell(size(red_ind, 1), 1);
fc_strs(red_ind) = {num2str(pos_color, '%d,%d,%d')}; %{'red'};
fc_strs(~red_ind) = {num2str(neg_color, '%d,%d,%d')}; %{'blue'};
% fc_ind = cellfun(@(x) find(strcmp(x, area_file(:, 1))), fc_strs(:, 1:2));
fid = fopen(link_fn, 'wt');
arrayfun(@(x, y, z)  fprintf(fid, 'lobe%d %d %d lobe%d %d %d color=%s\n',...
                     srt_index_mat(x, 2), (srt_index_mat(x, 3) - 1) * spin_sa, (srt_index_mat(x, 3) - 1) * spin_sa + (spin_sa - 1),...
                     srt_index_mat(y, 2), (srt_index_mat(y, 3) - 1) * spin_sa, (srt_index_mat(y, 3) - 1) * spin_sa + (spin_sa - 1),...
                     z{1}),...
                     x_ind, y_ind, fc_strs);
fclose(fid);

fprintf('\nDrawing circos...\n\n');
if (ispc == 1)
    system(['cmd /C "', bat_fn, '"']);
else
    system(['sh', 32, bat_fn]);
end