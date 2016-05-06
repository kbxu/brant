function outfn = brant_net_construct(jobman)

thres_corr_ind = jobman.thres_corr_bin;
thres_spar_ind = jobman.thres_spar_bin;

thres_corr = jobman.threshold_corr;
thres_spar = jobman.threshold_spar;

jobman.binary = 1;
if jobman.binary == 1
    net_type = 'binary';
else
    net_type = 'weighted';
end

outdir = jobman.out_dir{1};
time_now = ceil(clock);
outfn = fullfile(outdir, ['brant_net_calc', sprintf('_%d', time_now), '.mat']);
if exist(outfn, 'file') == 2
    delete(outfn);
end

corr_fn = jobman.corr_mat{1};
corr_field = jobman.corr_field;

mst_ind = jobman.mst;

corr_mat = load(corr_fn, corr_field);
load(corr_fn, 'subj_ids');
num_subj = size(corr_mat.(corr_field), 3);
num_node = size(corr_mat.(corr_field), 1);

% change here!
bad_ind = ~isfinite(corr_mat.(corr_field));
corr_mat.(corr_field)(bad_ind) = 0;
diag_ind = eye(num_node) == 1;
for m = 1:num_subj
    tmp = squeeze(corr_mat.(corr_field)(:, :, m));
    tmp(diag_ind) = 0;
    corr_mat.(corr_field)(:, :, m) = tmp;
end

raw_corr_mat = double(corr_mat.(corr_field));
raw_corr_mat = raw_corr_mat .* (raw_corr_mat > 0); % use positive links

if mst_ind == 0
    abs_corr_mat = abs(raw_corr_mat);
    
    max_net_thr_all = squeeze(min(max(abs_corr_mat)));
    bin_tmp = arrayfun(@(x) sum(abs_corr_mat(:, :, x) > max_net_thr_all(x)), 1:num_subj, 'UniformOutput', false);
    min_net_cost_all = cellfun(@(x) sum(x) / num_node / (num_node-1), bin_tmp);
    
    max_net_thr = min(max_net_thr_all(:));
    min_net_cost = max(min_net_cost_all(:));
    
    if thres_corr_ind == 1
        
        thres_corr_use = max(0, min(thres_corr)):0.01:min(max_net_thr, max(thres_corr));
        if isequal(thres_corr, thres_corr_use) == 0
            fprintf('Thresholds of correlation have been reset based on data\n');
        else
            fprintf('Thresholds of correlation are\n');
        end
        fprintf('\t%.3f\n', thres_corr_use);
    end
    
    if thres_spar_ind == 1
        if min_net_cost >= max(thres_spar)
            fprintf('Please check your input for sparsity threshold.\n');
            thres_spar_use = ceil(min_net_cost * 100) / 100:0.01:ceil(min_net_cost*100) / 100 + 0.1;
        elseif min_net_cost <= max(thres_spar) && min_net_cost > min(thres_spar)
            fprintf('Please check your input for sparsity threshold.\n') ;
            thres_spar_use = ceil(min_net_cost*100) / 100:0.01:max(thres_spar);
        else
            fprintf('The maximum sparsity for the samples is %d\n', min_net_cost);
            thres_spar_use = thres_spar;
        end
        fprintf('The minimum sparsity for the samples is %f\n', min_net_cost);
    end
else
    if thres_spar_ind == 1
        thres_spar_use = thres_spar;
    end
    
    if thres_corr_ind == 1
        thres_corr_use = thres_corr;
    end
    
    net_tmp = zeros(num_node, num_node, num_subj);
    for n = 1:num_subj
        mat_tmp = squeeze(raw_corr_mat(:, :, n));
        Inv_Matrix = 10 * max(mat_tmp(:)) - mat_tmp;%% for minmum spraning tree
        Inv_Matrix = sparse(Inv_Matrix);
        tree = graphminspantree(Inv_Matrix);
        Inv_Matrix = full(tree + tree') > 0;
        mat_tmp(Inv_Matrix) = max(mat_tmp(:));
        net_tmp(:,:,n) = mat_tmp;
    end
    
    abs_corr_mat = abs(net_tmp);
end

save(outfn, 'raw_corr_mat', 'abs_corr_mat', 'mst_ind', 'subj_ids', 'net_type', 'num_subj', 'num_node');

%%%% begin to generate the networks for each subject
if thres_corr_ind == 1
    fprintf('Generating the network matrices with thresholds of correlation...\n');
    num_corr = length(thres_corr_use);
    net_matrix_corr = false(num_node, num_node, num_subj, num_corr);
    for k = 1:num_corr
        net_matrix_corr(:, :, :, k) = abs_corr_mat >= thres_corr_use(k);
    end
    
    if strcmpi(net_type, 'weighted')
        for k = 1:num_corr
            net_matrix_corr(:, :, :, k) = abs_corr_mat .* net_matrix_corr(:, :, :, k);
        end 
    end
    save(outfn, 'net_matrix_corr', 'thres_corr_use', '-append');
end


if thres_spar_ind == 1
    fprintf('Generating the network matrices with thresholds of sparsity...\n');
    num_spar = length(thres_spar_use);
    net_matrix_spar = false(num_node, num_node, num_subj, num_spar);
    thres_nodes_num_spar = round(num_node * (num_node - 1) * thres_spar_use / 2);
    
    ind = triu(ones(num_node), 1) == 1;
    for n = 1:num_subj
        temp_mat = abs_corr_mat(:, :, n);
        tmp = sort(temp_mat(ind), 'descend');
        for k = 1:num_spar
            net_matrix_spar(:, :, n, k) = temp_mat >= tmp(thres_nodes_num_spar(k));
        end
    end
    
    if strcmpi(net_type, 'weighted')
        for k = 1:num_corr
            net_matrix_spar(:, :, :, k) = abs_corr_mat .* net_matrix_spar(:, :, :, k);
        end 
    end
    
    save(outfn, 'net_matrix_spar', 'thres_spar_use', 'thres_nodes_num_spar', '-append');
end
fprintf('Finished\n');
