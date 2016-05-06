function brant_net_stat(jobman)


outdir = jobman.out_dir{1};
outfn = fullfile(outdir, 'brant_net_stat.mat');
grp_regr_strs = jobman.regr_strs;
% regressors_nm = regexp(grp_regr_strs, '[,;]', 'split');
filter_strs = jobman.filter;
group_strs = jobman.groups;

group_est = parse_strs(group_strs, 'groups', 0);
filter_est = parse_strs(filter_strs, 'filter', 0);
reg_est = parse_strs(grp_regr_strs, 'regressors', 0);

regressors_tbl = jobman.regressors_tbl{1};
net_file = jobman.net_construct{1};
discard_ind = jobman.discard_bad_subj;

ttest_ind = jobman.student_t;


load(net_file);


[data_infos, subj_ind, fil_inds, reg_good_subj, corr_good_subj] = parse_subj_info2(regressors_tbl, subj_ids, group_est, filter_est, reg_est, '', discard_ind);

assert(size(fil_inds, 1) == 1 || size(fil_inds, 1) == 0);

group1_ind = strcmp(data_infos(:, 2), group_est{1});
group2_ind = strcmp(data_infos(:, 2), group_est{2});


% fields to test
field_tmp = fieldnames(net_measure_option);
struct_ind = cellfun(@(x) ~isstruct(net_measure_option.(x)), field_tmp);
field_tmp2 = field_tmp(struct_ind);
sel_ind = cellfun(@(x) net_measure_option.(x) == 1, field_tmp2);

field_strs = field_tmp2(sel_ind);


fields_no_test = {'resilience'};
field_strs = setdiff(field_strs, fields_no_test);

% n_field = size(field_strs, 1);
%

if isempty(field_strs)
    return;
end

save(outfn, 'field_strs');


field_strs_good = setdiff(field_strs, '');
n_field = size(field_strs_good, 1);
    
if exist('calc_rsts_corr', 'var') == 1
    calc_rsts_corr_good = calc_rsts_corr(subj_ind, :);
    size_corr = size(calc_rsts_corr_good, 2);
else
    calc_rsts_corr_good = [];
    size_corr = 0;
end

if exist('calc_rsts_spar', 'var') == 1
    calc_rsts_spar_good = calc_rsts_spar(subj_ind, :);
    size_spar = size(calc_rsts_spar_good, 2);
else
    calc_rsts_spar_good = [];
    size_spar = 0;
end

calc_rsts_all = [calc_rsts_corr_good, calc_rsts_spar_good];

for m = 1:n_field
    
    glob_vecs_corr = cellfun(@(x) x.(field_strs_good{m}).global, calc_rsts_all);
    
    brant_stat_raw(glob_vecs_corr, grp_stat, filter_est, data_infos, fil_inds, reg_good_subj,...
              test_ind, out_info);
end

if exist('calc_rsts_corr', 'var') == 1
    
    
    
    calc_rsts_corr(~subj_ind, :) = [];
    num_thres = size(calc_rsts_corr, 2);
    
    for n = 1:n_field
        calc_stat_corr.(field_strs_corr{n}).pval_r = ones(num_thres, 1);
        calc_stat_corr.(field_strs_corr{n}).pval_l = ones(num_thres, 1);
        calc_stat_corr.(field_strs_corr{n}).tval = zeros(num_thres, 1);
        
        mean_grp1 = zeros(num_thres, 1);
        mean_grp2 = zeros(num_thres, 1);
        
        ste_grp1 = zeros(num_thres, 1);
        ste_grp2 = zeros(num_thres, 1);
        
        num_grp1 = sum(group1_ind);
        num_grp2 = sum(group2_ind);
        
        
        for m = 1:num_thres
            
            glob_vecs = cellfun(@(x) x.(field_strs_corr{n}).global, calc_rsts_corr(:, m));
            
            if ~isempty(reg_good_subj)
                beta_tmp = [reg_good_subj, ones(size(reg_good_subj, 1), 1)] \ glob_vecs;
                glob_vecs = glob_vecs - reg_good_subj * beta_tmp(1:size(reg_good_subj, 2));
            end
            
            if ttest_ind == 1
                [h, pval, ci, tstat] = ttest2(glob_vecs(group1_ind), glob_vecs(group2_ind), 0.05, 'right'); %#ok<*ASGLU>
                calc_stat_corr.(field_strs_corr{n}).pval_r(m) = pval;
                calc_stat_corr.(field_strs_corr{n}).pval_l(m) = 1 - pval;
                calc_stat_corr.(field_strs_corr{n}).tval(m) = tstat.tstat;
            else
                group_ID = zeros(size(group1_ind));
                group_ID(group1_ind) = 1;
                group_ID(group2_ind) = 2;
                
                try
                    stats = brant_ttest2_permutation(glob_vecs, group_ID, 1000);

                    calc_stat_corr.(field_strs_corr{n}).pval_r(m) = stats.pvals(1);
                    calc_stat_corr.(field_strs_corr{n}).pval_l(m) = stats.pvals(2);
                    calc_stat_corr.(field_strs_corr{n}).tval(m) = stats.tvals;
                catch
                end
            end
            
            mean_grp1(m) = mean(glob_vecs(group1_ind));
            mean_grp2(m) = mean(glob_vecs(group2_ind));
            
            ste_grp1(m) = std(glob_vecs(group1_ind)) / sqrt(num_grp1);
            ste_grp2(m) = std(glob_vecs(group2_ind)) / sqrt(num_grp2);
        end
        
        h_fig = plot_rst('threshold of correlation', field_strs_corr{n}, group_est, calc_stat_corr.(field_strs_corr{n}).pval_r, calc_stat_corr.(field_strs_corr{n}).pval_l, thres_corr_use, mean_grp1, ste_grp1, mean_grp2, ste_grp2);
        set(h_fig, 'Color', [1, 1, 1]);
        set(h_fig, 'InvertHardcopy', 'off');
        saveas(h_fig, fullfile(outdir, [field_strs_corr{n}, '_', 'corr.png']));
    end
    
    save(outfn, 'calc_stat_corr', '-append');
end


if exist('calc_rsts_spar', 'var') == 1
    
    field_strs_spar = setdiff(field_strs, '');
    n_field = size(field_strs_spar, 1);
    
    calc_rsts_spar(~subj_ind, :) = [];
    num_thres = size(calc_rsts_spar, 2);
    
    for n = 1:n_field
        calc_stat_spar.(field_strs_spar{n}).pval_r = ones(num_thres, 1);
        calc_stat_spar.(field_strs_spar{n}).pval_l = ones(num_thres, 1);
        calc_stat_spar.(field_strs_spar{n}).tval = zeros(num_thres, 1);
        
        mean_grp1 = zeros(num_thres, 1);
        mean_grp2 = zeros(num_thres, 1);
        
        ste_grp1 = zeros(num_thres, 1);
        ste_grp2 = zeros(num_thres, 1);
        
        num_grp1 = sum(group1_ind);
        num_grp2 = sum(group2_ind);
        
        for m = 1:num_thres
            glob_vecs = cellfun(@(x) x.(field_strs_spar{n}).global, calc_rsts_spar(:, m));
            
            if ~isempty(reg_good_subj)
                beta_tmp = [reg_good_subj, ones(size(reg_good_subj, 1), 1)] \ glob_vecs;
                glob_vecs = glob_vecs - reg_good_subj * beta_tmp(1:size(reg_good_subj, 2));
            end
            
            if ttest_ind == 1
                [h, pval, ci, tstat] = ttest2(glob_vecs(group1_ind), glob_vecs(group2_ind), 0.05, 'right'); %#ok<*ASGLU>
                calc_stat_spar.(field_strs_spar{n}).pval_r(m) = pval;
                calc_stat_spar.(field_strs_spar{n}).pval_l(m) = 1 - pval;
                calc_stat_spar.(field_strs_spar{n}).tval(m) = tstat.tstat;
            else
                group_ID = zeros(size(group1_ind));
                group_ID(group1_ind) = 1;
                group_ID(group2_ind) = 2;
                
                try
                    stats = brant_ttest2_permutation(glob_vecs, group_ID, 1000);

                    calc_stat_spar.(field_strs_spar{n}).pval_r(m) = stats.pvals(1);
                    calc_stat_spar.(field_strs_spar{n}).pval_l(m) = stats.pvals(2);
                    calc_stat_spar.(field_strs_spar{n}).tval(m) = stats.tvals;
                catch
                end
            end
            
            mean_grp1(m) = mean(glob_vecs(group1_ind));
            mean_grp2(m) = mean(glob_vecs(group2_ind));
            
            ste_grp1(m) = std(glob_vecs(group1_ind)) / sqrt(num_grp1);
            ste_grp2(m) = std(glob_vecs(group2_ind)) / sqrt(num_grp2);
        end
        
        h_fig = plot_rst('threshold of sparsity', field_strs_spar{n}, group_est, calc_stat_spar.(field_strs_spar{n}).pval_r, calc_stat_spar.(field_strs_spar{n}).pval_l, thres_spar_use, mean_grp1, ste_grp1, mean_grp2, ste_grp2);
        set(h_fig, 'Color', [1, 1, 1]);
        set(h_fig, 'InvertHardcopy', 'off');
        saveas(h_fig, fullfile(outdir, [field_strs_corr{n}, '_', 'spar.png']));
    end
    
    save(outfn, 'calc_stat_spar', '-append');
end

fprintf('\n\tFinished!\n');


function h_fig = plot_rst(x_str, title_str, group_est, p_val_r, p_val_l, thres_x, mean_grp1, ste_grp1, mean_grp2, ste_grp2)

h_fig = figure;
hold('on');
xlabel(x_str);
% ylabel('mean');
ylabel(strrep(title_str, '_', ' '));

errorbar(thres_x, mean_grp1, ste_grp1, 'r-', 'LineWidth', 2);
errorbar(thres_x, mean_grp2, ste_grp2, 'b-', 'LineWidth', 2);

legend(group_est{1}, group_est{2}, 'location', 'SouthEast');        

y_gca = ylim;
set(gca, 'Ylim', y_gca + abs(y_gca(2) - y_gca(1)) / 10);
star_loc = y_gca(2) + abs(y_gca(2) - y_gca(1)) / 20;
set(gca,'box','on');

p_ind = p_val_r <= 0.05;
if any(p_ind)
    
    p_ind = p_val_r <= 0.05 & p_val_r > 0.001;
    if any(p_ind)
        plot(thres_x(p_ind), star_loc, 'r*');
    end

    p_ind = p_val_r <= 0.001;
    if any(p_ind)
        plot(thres_x(p_ind), star_loc, 'r^');
    end
end

p_ind = p_val_l <= 0.05;
if any(p_ind)
    
    p_ind = p_val_r <= 0.05 & p_val_r > 0.001;
    if any(p_ind)
        plot(thres_x(p_ind), star_loc, 'b*');
    end
    
    p_ind = p_val_l <= 0.001;
    if any(p_ind)
        plot(thres_x(p_ind), star_loc, 'b^');
    end
end
hold('off');