function brant_net_calc_old(jobman)

thres_corr_ind = jobman.thres_corr_bin;
thres_spar_ind = jobman.thres_spar_bin;

thres_corr = jobman.threshold_corr;
thres_spar = jobman.threshold_spar;
mat_type = jobman.matrix_type;

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

mst_ind = jobman.mst;

fprintf('Loading network matrices...\n');
% the following assignments were modified and commented by kb at 2016020
[mat_list, subj_ids] = brant_get_subjs(jobman.input_matrix);

switch(mat_type)
    case {'raw value (corr_r)', 'absolute value (corr_r)'}
        corr_str = 'corr_r';
    case {'raw value', 'absolute value', 'raw value (corr_z)', 'absolute value (corr_z)'}
        corr_str = 'corr_z';
    otherwise
        error('Unknown matrix type!');
end

corr_all = cellfun(@(x) load(x, corr_str), mat_list);
corr_mat = cat(3, corr_all.(corr_str));
clear('corr_all');
% corr_fn = jobman.corr_mat{1};
% corr_field = jobman.corr_field;
% corr_mat = load(corr_fn, corr_field);
% load(corr_fn, 'subj_ids');

num_subj = size(corr_mat, 3);
num_node = size(corr_mat, 1);

bad_ind = ~isfinite(corr_mat);
corr_mat(bad_ind) = 0;
diag_ind = eye(num_node) == 1;
for m = 1:num_subj
    tmp = squeeze(corr_mat(:, :, m));
    tmp(diag_ind) = 0;
    corr_mat(:, :, m) = tmp;
end

% raw_corr_mat = double(corr_mat);

switch(mat_type)
    case {'raw value', 'raw value (corr_r)', 'raw value (corr_z)'}
        multi_mat_calc = double(corr_mat);
    case {'absolute value', 'absolute value (corr_r)', 'absolute value (corr_z)'}
        multi_mat_calc = abs(double(corr_mat));
    otherwise
        error('Unknown matrix type!');
end

% if strcmp(mat_type, 'raw value')
%     multi_mat_calc = double(corr_mat);
% elseif strcmp(mat_type, 'absolute value')
%     multi_mat_calc = abs(double(corr_mat));
% else
%     error('Unknown matrix type!');
% end
clear('corr_mat');

if mst_ind == 0
    % threshold for each node to have an edge
    max_net_thr_all = squeeze(min(max(multi_mat_calc)));
    
    % cost when all node have at least an edge
    min_net_cost_all = arrayfun(@(x) sum(sum(multi_mat_calc(:, :, x) > max_net_thr_all(x))) / num_node / (num_node-1), (1:num_subj)');
    
    max_net_thr = min(max_net_thr_all);
    min_net_cost = max(min_net_cost_all);
    
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
    
    fprintf('Generating the binary network using minimum spanning tree...\n');
%     net_tmp = zeros(num_node, num_node, num_subj);
    for n = 1:num_subj
        mat_tmp = multi_mat_calc(:, :, n); % multi_mat_calc here was raw_corr_mat before 20151229
        Inv_Matrix = 10 * max(mat_tmp(:)) - mat_tmp; %% for minmum spanning tree
        Inv_Matrix = sparse(Inv_Matrix);
        tree = graphminspantree(Inv_Matrix);
        inv_ind = full(tree + tree') > 0;
        mat_tmp(inv_ind) = max(mat_tmp(:));
        multi_mat_calc(:, :, n) = mat_tmp;
    end
%     multi_mat_calc = net_tmp;
%     clear('net_tmp');
end

save(outfn, 'mst_ind', 'subj_ids', 'net_type', 'num_subj', 'num_node', 'mat_type');

%%%% begin to generate the networks for each subject
if thres_corr_ind == 1
    fprintf('Generating the network matrices with thresholds of correlation...\n');
    num_corr = length(thres_corr_use);
    net_matrix_corr = false(num_node, num_node, num_subj, num_corr);
    for k = 1:num_corr
        net_matrix_corr(:, :, :, k) = multi_mat_calc >= thres_corr_use(k);
    end
    
    if strcmpi(net_type, 'weighted')
        for k = 1:num_corr
            net_matrix_corr(:, :, :, k) = multi_mat_calc .* net_matrix_corr(:, :, :, k);
        end 
    end
    save(outfn, 'thres_corr_use', '-append');
end


if thres_spar_ind == 1
    fprintf('Generating the network matrices with thresholds of sparsity...\n');
    num_spar = length(thres_spar_use);
    net_matrix_spar = false(num_node, num_node, num_subj, num_spar);
    thres_nodes_num_spar = round(num_node * (num_node - 1) * thres_spar_use / 2);
    
    ind = triu(ones(num_node), 1) == 1;
    for n = 1:num_subj
        temp_mat = multi_mat_calc(:, :, n);
        tmp = sort(temp_mat(ind), 'descend');
        for k = 1:num_spar
            net_matrix_spar(:, :, n, k) = temp_mat >= tmp(thres_nodes_num_spar(k));
        end
    end
    
    if strcmpi(net_type, 'weighted')
        for k = 1:num_corr
            net_matrix_spar(:, :, :, k) = multi_mat_calc .* net_matrix_spar(:, :, :, k);
        end 
    end
    
    save(outfn, 'thres_spar_use', 'thres_nodes_num_spar', '-append');
end
clear('multi_mat_calc');
fprintf('Finished\n');


% Calculating network properties...
net_measure_option = jobman.net_calcs;
save(outfn, 'net_measure_option', '-append');

rng('default');

if net_measure_option.small_worldness == 1
    num_workers = net_measure_option.sw.num_paral;
    if num_workers > 0
        brant_parpool('open', num_workers);
    end
else
    num_workers = 0;
end

if exist('thres_corr_use', 'var') == 1
    fprintf('\nCalculating for thresholds of correlation coefficient...\n');
    num_thres = length(thres_corr_use);
    calc_rsts_corr = cell(num_subj, num_thres);
    for m = 1:num_subj
        for n = 1:num_thres
            fprintf('\nSubject %s %d/%d, threshold of correlation: %f\n', subj_ids{m}, m, num_subj, thres_corr_use(n));
            gMatrix = squeeze(net_matrix_corr(:, :, m, n));
            calc_rsts_corr{m, n} = brant_measure(net_measure_option, gMatrix, net_type);
        end
    end
    save(outfn, 'calc_rsts_corr', '-append');
end
fprintf('\n');

if exist('thres_spar_use', 'var') == 1
    fprintf('\nCalculating for thresholds of sparsity...\n');
    num_thres = length(thres_spar_use);
    calc_rsts_spar = cell(num_subj, num_thres);
    for m = 1:num_subj
        for n = 1:num_thres
            fprintf('\nSubject %s %d/%d, threshold of sparsity: %f\n', subj_ids{m}, m, num_subj, thres_spar_use(n));
            gMatrix = squeeze(net_matrix_spar(:, :, m, n));
            calc_rsts_spar{m, n} = brant_measure(net_measure_option, gMatrix, net_type);
        end
    end
    save(outfn, 'calc_rsts_spar', '-append');
end

if num_workers > 0
    brant_parpool('close');
end
fprintf('\nFinished!\n');

function net = brant_measure(net_measure_option, gMatrix, net_type) %#ok<*DEFNU>

% tic
if net_measure_option.assortative == 1
    fprintf('Calculating assortativity coefficient of network.\n');
    [net.assortative.global] = CCM_Assortative(gMatrix);
end
% toc
% 
% tic
if net_measure_option.neighbor_degree == 1
    fprintf('Calculating neighbors'' degree of nodes in network.\n');
    [net.neighbor_degree.global, net.neighbor_degree.nodal] = CCM_AvgNeighborDegree(gMatrix);
end
% toc
% 
% tic
if net_measure_option.betweenness_rw == 1
    fprintf('Calculating random-walk betweenness.\n');
    [net.betweeness_rw.global, net.betweeness_rw.nodal] = CCM_RBetweenness(gMatrix);
end
% toc
% 

if net_measure_option.betweenness_spe == 1 || net_measure_option.betweenness_spv == 1
    tic
    fprintf('Calculating shorest-path betweenness.\n');
    [net.betweeness_spv, net.betweeness_spe] = brant_SBetweenness(gMatrix, net_type);
    toc
end

% tic
% if net_measure_option.betweenness_spe == 1
%     fprintf('Calculating shorest-path betweenness about edges.\n');
%     [net.betweeness_spe2.global, net.betweeness_spe2.nodal] = CCM_SBetweenness(gMatrix, 'Edge', net_type);
% end
% if net_measure_option.betweenness_spv == 1
%     fprintf('Calculating shorest-path betweenness about vertex.\n');
%     [net.betweeness_spv2.global, net.betweeness_spv2.nodal] = CCM_SBetweenness(gMatrix, 'Vertex', net_type);
% end
% toc
% 
% tic
if net_measure_option.degree == 1
    fprintf('Calculating node degree.\n');
    [net.degree.global, net.degree.nodal] = CCM_Degree(gMatrix);
end
% toc
% 
% tic
if net_measure_option.faulttol == 1
    fprintf('Calculating fault tolerance of network based on global perspective.\n');
    [net.faulttol.global, net.faulttol.nodal] = CCM_FaultTol(gMatrix);
end
% toc
% 
% tic
if any([net_measure_option.local_efficiency, net_measure_option.global_efficiency,...
        net_measure_option.shortest_path_length]) == 1
    fprintf('Calculating the shortest distance matrix of source nodes.\n');
    dist = graphallshortestpaths(sparse(gMatrix), 'Directed', false);
    
    N = size(gMatrix, 1);
    if net_measure_option.shortest_path_length == 1
        net.shortest_path_length.nodal = sum(dist, 2) / (N - 1);
        net.shortest_path_length.global = mean(net.shortest_path_length.nodal);
    end
    
    
    if net_measure_option.global_efficiency == 1
        eff_mat = 1./ dist;
        eff_mat(~isfinite(eff_mat)) = 0;
    
        net.global_efficiency.nodal = sum(eff_mat, 2) / (N - 1);
        net.global_efficiency.global = mean(net.global_efficiency.nodal);
    end
end
% toc
% 
% tic
LE_ind = net_measure_option.local_efficiency;
CC_ind = net_measure_option.clustering_coefficient;
if CC_ind == 1 || LE_ind == 1
    if CC_ind == 1
        fprintf('Calculating clustering coefficients.\n');
    end
    
    if LE_ind == 1
        fprintf('Calculating local-efficiency of graph based on local perspective.\n');
    end
    [net.local_efficiency, net.clustering_coefficient] = brant_LE_CC(gMatrix, LE_ind, CC_ind);
end
% toc

% if net_measure_option.clustering_coefficient == 1
%     fprintf('Calculating clustering coefficients.\n');
%     [net.clustering_coefficient.global, net.clustering_coefficient.nodal] = CCM_ClusteringCoef(gMatrix);
% end
% if net_measure_option.local_efficiency == 1 
%     fprintf('Calculating local-efficiency of graph based on local perspective.\n');
%     [net.local_efficiency.global, net.local_efficiency.nodal] = CCM_LEfficiency(gMatrix);
% end

% if net_measure_option.shortest_path_length == 1
%     fprintf('Calculating the shortest distance matrix of source nodes.\n');
%     dist = graphallshortestpaths(sparse(gMatrix), 'Directed', false);
%     net.shortest_path_length.nodal = sum(dist, 2) / (size(gMatrix, 1) - 1);
%     net.shortest_path_length.global = mean(net.shortest_path_length.nodal);
% %     [net.shortest_path_length.global, net.shortest_path_length.nodal] = CCM_AvgShortestPath(gMatrix);
% end

% tic
if net_measure_option.resilience == 1 
    fprintf('Calculating cmulative degree distribution of network.\n');
    [net.resilience.global] = CCM_Resilience(gMatrix);
end
% toc
% 
% tic
if net_measure_option.vulnerability == 1
    fprintf('Calculating the vulnerability of networks.\n');
    [net.vulnerability.global, net.vulnerability.nodal] = CCM_Vulnerability(gMatrix);
end
% toc
% 
% tic
if net_measure_option.transitivity == 1
    fprintf('Calculating transitivity of network.\n');
    [net.transitivity.global] = CCM_Transitivity(gMatrix);
end
% toc
% 

if net_measure_option.small_worldness == 1
    tic
    fprintf('Calculating small-worldness of network.\n');
    randperm_num = net_measure_option.sw.num_simulation;
%     fprintf('Small world measure could be very slow for random simulation for %d times, be patient\n',randperm_num);
    [net.smallworldness_sigma.global, net.smallworldness_lambda.global, net.smallworldness_gamma.global] = brant_SmallWorldness(gMatrix, randperm_num, net_type, net_measure_option.sw.keep_connectivity, net_measure_option.sw.num_paral > 0);
%     [net.smallworldness_sigma.global, net.smallworldness_lambda.global,net.smallworldness_gamma.global] = CCM_SmallWorldness(gMatrix,randperm_num,net_type,1);
    toc
end