function brant_net_calc(jobman)

thres_corr_ind = jobman.thres_corr_bin;
thres_spar_ind = jobman.thres_spar_bin;

thres_corr = jobman.threshold_corr;
thres_spar = jobman.threshold_spar;
mat_type = jobman.matrix_type;

net_measure_option = jobman.net_calcs;

jobman.binary = 1;
if (jobman.binary == 1)
    net_type = 'binary';
else
    net_type = 'weighted';
end

outdir = jobman.out_dir{1};
mst_ind = jobman.mst;
num_workers = jobman.par_workers;

fprintf('Loading network matrices...\n');
[mat_list, subj_ids] = brant_get_subjs(jobman.input_matrix);

num_subj = numel(mat_list);
if (num_workers > 0)
    brant_parpool('open', num_workers);
end

thres_corr_use = [];
num_corr = 0;
corr_ind = [];
if (thres_corr_ind == 1)
    thres_corr_use = thres_corr;
    num_corr = length(thres_corr);
    corr_ind = 1:num_corr;
end

thres_spar_use = [];
% num_spar = 0;
spar_ind = [];
if (thres_spar_ind == 1)
    thres_spar_use = thres_spar;
    num_spar = length(thres_spar);
    spar_ind = (num_corr + 1):(num_corr + num_spar);
end

for m = 1:num_subj
    
    subj_id = subj_ids{m};
    fprintf('Subject %s\n', subj_id);
    
    corr_mat = load(mat_list{m});
    num_node = size(corr_mat, 1);
    bad_ind = ~isfinite(corr_mat);
    corr_mat(bad_ind) = 0;
    corr_mat(eye(num_node) == 1) = 0;
    
    sym_ind = isequal(corr_mat, corr_mat');
    if (sym_ind == 0)
        error('Matrix is not symmetric!');
    end
    
    switch(mat_type)
        case {'raw value'}
            mat_tmp = double(corr_mat);
        case {'absolute value'}
            mat_tmp = abs(double(corr_mat));
        otherwise
            error('Unknown matrix type!');
    end
    
    if (mst_ind == 1)
        % Generating the binary graph using minimum spanning tree...
        Inv_Matrix = 10 * max(mat_tmp(:)) - mat_tmp; %% for minmum spanning tree
        Inv_Matrix = sparse(Inv_Matrix);
        tree = graphminspantree(Inv_Matrix);
        inv_ind = full(tree + tree') > 0;
        mat_tmp(inv_ind) = max(mat_tmp(:));
    end
    
    mat_calc = mat_tmp;
    
    if (thres_spar_ind == 1)
        thres_nodes_num_spar = round(num_node * (num_node - 1) * thres_spar_use / 2);
        ind = triu(true(num_node), 1);
        tmp = sort(mat_calc(ind), 'descend');
        thres_nodes_num_spar_int = tmp(thres_nodes_num_spar);
    else
        thres_nodes_num_spar_int = [];
    end
    thres_all = [thres_corr_use'; thres_nodes_num_spar_int];
    
    if strcmpi(net_type, 'weighted')
        net_matrix_all = arrayfun(@(x) (mat_calc >= x) .* mat_calc, thres_all, 'UniformOutput', false);
    else
        net_matrix_all = arrayfun(@(x) mat_calc >= x, thres_all, 'UniformOutput', false);
    end
    
    calc_rsts_all = cell(numel(net_matrix_all), 1);
    if (num_workers > 0)
        parfor n = 1:numel(net_matrix_all)
            calc_rsts_all{n} = brant_measure(net_measure_option, subj_id, net_matrix_all{n}, net_type);
        end
    else
        for n = 1:numel(net_matrix_all)
            calc_rsts_all{n} = brant_measure(net_measure_option, subj_id, net_matrix_all{n}, net_type);
        end
    end
    
    calc_rsts_corr = calc_rsts_all(corr_ind); %#ok<NASGU>
    calc_rsts_spar = calc_rsts_all(spar_ind); %#ok<NASGU>
    
    save(fullfile(outdir, [subj_id, '_network.mat']), 'net_measure_option', 'thres_spar_ind', 'thres_corr_ind',...
                                                      'corr_ind', 'spar_ind',...
                                                      'mst_ind', 'net_type', 'num_node', 'thres_corr_use',...
                                                      'thres_spar_use', 'thres_nodes_num_spar', 'mat_type',...
                                                      'subj_id', 'calc_rsts_corr', 'calc_rsts_spar');
end

if (num_workers > 0), brant_parpool('close'); end
fprintf('\nFinished!\n');

function net = brant_measure(net_measure_option, subj_id, gMatrix, net_type)

N = size(gMatrix, 1);

corr_ind = triu(true(N, N), 1);

if ~any(gMatrix(:))
    net = [];
    return;
end

if (net_measure_option.assortative_mixing == 1)
    fprintf('%s: assortativity coefficient of network.\n', subj_id);
    [net.assortative_mixing.global] = CCM_Assortative(gMatrix);
end

if (net_measure_option.neighbor_degree == 1)
    fprintf('%s: neighbors'' degree of nodes in network.\n', subj_id);
    [net.neighbor_degree.global, net.neighbor_degree.nodal] = CCM_AvgNeighborDegree(gMatrix);
end

% if net_measure_option.betweenness_rw == 1
%     fprintf('%s: random-walk betweenness.\n', subj_id);
%     [net.betweeness_rw.global, net.betweeness_rw.nodal] = CCM_RBetweenness(gMatrix);
% end
% 
% if net_measure_option.betweenness_spe == 1 || net_measure_option.betweenness_spv == 1
%     fprintf('%s: shorest-path betweenness.\n', subj_id);
%     [net.betweeness_spv, net.betweeness_spe] = brant_SBetweenness(gMatrix, net_type);
% end

if (net_measure_option.betweenness_centrality == 1)
    fprintf('%s: Un-normalized betweenness centrality.\n', subj_id);
    
    if (strcmp(computer('arch'), 'win64') == 1)
        bc = brant_betweenness_centrality(sparse(gMatrix)); %  normalized / ((N - 1) * (N - 2) / 2)
        N = size(gMatrix, 1);
%         bc = bc; %  unnormalized / ((N - 1) * (N - 2) / 2)
        net.betweenness_centrality.global = mean(bc);
        net.betweenness_centrality.nodal = bc;
    else
        net.betweenness_centrality = brant_SBetweenness(gMatrix, net_type);
    end
end

if (net_measure_option.degree == 1)
    fprintf('%s: node degree.\n', subj_id);
    [net.degree.global, net.degree.nodal] = CCM_Degree(gMatrix);
end

if (net_measure_option.fault_tolerance == 1)
    fprintf('%s: fault tolerance of network based on global perspective.\n', subj_id);
    [net.fault_tolerance.global, net.fault_tolerance.nodal] = CCM_FaultTol(gMatrix);
end

if any([net_measure_option.local_efficiency,...
        net_measure_option.global_efficiency,...
        net_measure_option.shortest_path_length]) == 1
    fprintf('%s: the shortest distance matrix of source nodes.\n', subj_id);
    dist = graphallshortestpaths(sparse(gMatrix), 'Directed', false);
    
    
    if (net_measure_option.shortest_path_length == 1)
        net.shortest_path_length.nodal = sum(dist, 2) / (N - 1);
        net.shortest_path_length.global = mean(net.shortest_path_length.nodal);
    end
    
    if (net_measure_option.global_efficiency == 1)
        eff_mat = 1 ./ dist;
        eff_mat(~isfinite(eff_mat)) = 0;
        net.global_efficiency.nodal = sum(eff_mat, 2) / (N - 1);
        net.global_efficiency.global = 2 * sum(eff_mat(corr_ind)) / (N * (N - 1));
    end
end

if ((net_measure_option.clustering_coefficient == 1) || (net_measure_option.local_efficiency == 1))
    if (net_measure_option.clustering_coefficient == 1)
        fprintf('%s: clustering coefficients.\n', subj_id);
    end
    
    if (net_measure_option.local_efficiency == 1)
        fprintf('%s: local-efficiency of graph based on local perspective.\n', subj_id);
    end
    [local_efficiency, clustering_coefficient] = brant_LE_CC(gMatrix, net_measure_option.local_efficiency, net_measure_option.clustering_coefficient);
    
    if (net_measure_option.clustering_coefficient == 1)
        net.clustering_coefficient = clustering_coefficient;
    end
    
    if (net_measure_option.local_efficiency == 1)
        net.local_efficiency = local_efficiency;
    end
end

if (net_measure_option.resilience == 1)
    fprintf('%s: cmulative degree distribution of network.\n', subj_id);
    [net.resilience.global] = CCM_Resilience(gMatrix);
end

if (net_measure_option.vulnerability == 1)
    fprintf('%s: vulnerability of networks.\n', subj_id);
    [net.vulnerability.global, net.vulnerability.nodal] = CCM_Vulnerability(gMatrix);
end

if (net_measure_option.transitivity == 1)
    fprintf('%s: transitivity of network.\n', subj_id);
    [net.transitivity.global] = CCM_Transitivity(gMatrix);
end

if (net_measure_option.small_worldness == 1)
    fprintf('%s: small-worldness of network.\n', subj_id);
    randperm_num = net_measure_option.sw.num_simulation;
    [net.smallworldness_sigma.global, net.smallworldness_lambda.global, net.smallworldness_gamma.global] = brant_SmallWorldness(gMatrix, randperm_num, net_type, net_measure_option.sw.keep_connectivity, 0);
end

fprintf('\n');
