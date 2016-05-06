function brant_multi_correction(jobman)

if exist(jobman.out_dir{1}, 'dir') ~= 7
    mkdir(jobman.out_dir{1});
end

num_mats = numel(jobman.stat_mats);

p_thr = jobman.p_thr;
mats = jobman.stat_mats;
fdr_ind = jobman.fdr;
fdr2_ind = jobman.fdr2;
bonf_ind = jobman.bonf;
outdir = jobman.out_dir{1};

if ~any([fdr_ind, fdr2_ind, bonf_ind])
    error('At least one multiple correction method is expected!');
end

stat_load = cellfun(@load, mats);
num_stat = numel(stat_load);

% check group
grp_all = arrayfun(@(x) x.group_est, stat_load, 'UniformOutput', false);
grp_chk = cellfun(@(x) isequal(x, grp_all{1}), grp_all);
if ~all(grp_chk)
    error('The number and the order of test groups are expected to be same!');
end

% check tail
tail_all = arrayfun(@(x) x.tail_rst, stat_load, 'UniformOutput', false);
tail_chk = cellfun(@(x) isequal(x, tail_all{1}), tail_all);
if ~all(tail_chk)
    error('The number and the order of test tails are expected to be same!');
end
tail_rst = tail_all{1};
num_tail = numel(tail_rst);

subjs = arrayfun(@(x) x.subjs, stat_load, 'UniformOutput', false);
t_rst = arrayfun(@(x) x.t_rst, stat_load, 'UniformOutput', false);
size_p = size(stat_load(1).p_rst_unc{1});
p_vector_ind = triu(ones(size_p), 1) > 0.5;

% get un-corrected values
for m = 1:num_tail
    p_rst_unc.(tail_rst{m}) = arrayfun(@(x) x.p_rst_unc{m}, stat_load, 'UniformOutput', false);
    h_rst_unc.(tail_rst{m}) = cellfun(@(x) x < p_thr & x > 0, p_rst_unc.(tail_rst{m}), 'UniformOutput', false);
    p_vector.(tail_rst{m}) = cellfun(@(x) x(p_vector_ind), p_rst_unc.(tail_rst{m}), 'UniformOutput', false);
end

group_est = stat_load(1).group_est; %#ok<*NASGU>
% out_fn = fullfile(outdir, 'p_val_c.mat');

p_fns_all = {'fdr_p', 'fdr2_p', 'bonf_p'};
h_fns_all = {'fdr_h', 'fdr2_h', 'bonf_h'};
c_methods = {'FDR', 'FDR2', 'Bonf'};

p_fns = p_fns_all([fdr_ind, fdr2_ind, bonf_ind] > 0.5);
h_fns = h_fns_all([fdr_ind, fdr2_ind, bonf_ind] > 0.5);

for m = 1:num_tail
    
    fprintf('\tDoing multiple correction for tail %s\n', tail_rst{m});
    out_fn_tail = fullfile(outdir, ['pval_C_tail_', tail_rst{m}, '.mat']);
    tail_out = tail_rst{m};
    save(out_fn_tail, 'mats', 'group_est', 'tail_out', 't_rst', 'p_rst_unc', 'h_rst_unc', 'p_thr', 'subjs');
    
    for n = 1:numel(p_fns)
        [p_val_tmp, sts] = cellfun(@(x) brant_MulCC(x, p_thr, c_methods{n}), p_vector.(tail_rst{m}), 'UniformOutput', false);
        
        sts_ind = cell2mat(sts) == 1;
        h_val_tmp = cell(num_stat, 1);
        h_val_tmp(sts_ind) = cellfun(@(x, y) x < y & x > 0, p_rst_unc.(tail_rst{m})(sts_ind), p_val_tmp(sts_ind), 'UniformOutput', false);

        eval([p_fns{n}, 32, '=', 32, 'cell2mat(p_val_tmp);']);
        eval([h_fns{n}, 32, '=', 32, 'h_val_tmp;']);
        
        save(out_fn_tail, p_fns{n}, h_fns{n}, '-append');
    end
end
fprintf('\tFinished!\n');
