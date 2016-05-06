function brant_net_measure(jobman)

net_file = jobman.net_construct{1};
net_calcs_info = load(net_file);
net_type = net_calcs_info.net_type;

num_subj = numel(net_calcs_info.subj_ids);

net_measure_option = jobman.net_calcs;
save(net_file, 'net_measure_option', '-append');

if isfield(net_calcs_info, 'thres_corr_use')
    fprintf('\nCalculating for thresholds of correlation coefficient...\n');
    num_thres = length(net_calcs_info.thres_corr_use);
    calc_rsts_corr = cell(num_subj, num_thres);
    for m = 1:num_subj
        for n = 1:num_thres
            fprintf('\nSubject %s %d/%d, threshold of correlation: %f\n', net_calcs_info.subj_ids{m}, m, num_subj, net_calcs_info.thres_corr_use(n));
            gMatrix = squeeze(net_calcs_info.net_matrix_corr(:, :, m, n));
            calc_rsts_corr{m, n} = brant_measure(net_measure_option, gMatrix, net_type);
        end
    end
    save(net_file, 'calc_rsts_corr', '-append');
end
fprintf('\n');

if isfield(net_calcs_info, 'thres_spar_use')
    fprintf('\nCalculating for thresholds of sparsity...\n');
    num_thres = length(net_calcs_info.thres_spar_use);
    calc_rsts_spar = cell(num_subj, num_thres);
    for m = 1:num_subj
%         fprintf('Subject %s %d/%d...\n', net_calcs_info.subj_ids{m}, m, num_subj);
        for n = 1:num_thres
            fprintf('\nSubject %s %d/%d, threshold of sparsity: %f\n', net_calcs_info.subj_ids{m}, m, num_subj, net_calcs_info.thres_spar_use(n));
            gMatrix = squeeze(net_calcs_info.net_matrix_spar(:, :, m, n));
            calc_rsts_spar{m, n} = brant_measure(net_measure_option, gMatrix, net_type);
        end
    end
    save(net_file, 'calc_rsts_spar', '-append');
end
fprintf('\nFinished!\n');

function net = brant_measure(net_measure_option, gMatrix, net_type) %#ok<*DEFNU>
if net_measure_option.assortative == 1
    fprintf('Calculating assortativity coefficient of network.\n');
    [net.assortative.global] = CCM_Assortative(gMatrix);
end
if net_measure_option.neighbor_degree == 1
    fprintf('Calculating neighbors'' degree of nodes in network.\n');
    [net.neighbor_degree.global, net.neighbor_degree.nodal] = CCM_AvgNeighborDegree(gMatrix);
end
if net_measure_option.betweenness_rw == 1
    fprintf('Calculating random-walk betweenness.\n');
    [net.betweeness_rw.global, net.betweeness_rw.nodal] = CCM_RBetweenness(gMatrix);
end
if net_measure_option.betweenness_spe == 1
    fprintf('Calculating shorest-path betweenness about edges.\n');
    [net.betweeness_spe.global, net.betweeness_spe.nodal] = CCM_SBetweenness(gMatrix, 'Edge', net_type);
end
if net_measure_option.betweenness_spv == 1
    fprintf('Calculating shorest-path betweenness about vertex.\n');
    [net.betweeness_spv.global, net.betweeness_spv.nodal] = CCM_SBetweenness(gMatrix, 'Vertex', net_type);
end
if net_measure_option.clustering_coefficient == 1
    fprintf('Calculating clustering coefficients.\n');
    [net.clustering_coefficient.global, net.clustering_coefficient.nodal] = CCM_ClusteringCoef(gMatrix);
end
if net_measure_option.degree == 1
    fprintf('Calculating node degree.\n');
    [net.degree.global, net.degree.nodal] = CCM_Degree(gMatrix);
end
if net_measure_option.faulttol == 1
    fprintf('Calculating fault tolerance of network based on global perspective.\n');
    [net.faulttol.global, net.faulttol.nodal] = CCM_FaultTol(gMatrix);
end
if net_measure_option.global_efficiency == 1
    fprintf('Calculating global-efficiency of networks.\n');
    [net.global_efficiency.global, net.global_efficiency.nodal] = CCM_GEfficiency(gMatrix);
end
if net_measure_option.local_efficiency == 1 
    fprintf('Calculating local-efficiency of graph based on local perspective.\n');
    [net.local_efficiency.global, net.local_efficiency.nodal] = CCM_LEfficiency(gMatrix);
end
if net_measure_option.resilience == 1 
    fprintf('Calculating cmulative degree distribution of network.\n');
    [net.resilience.global] = CCM_Resilience(gMatrix);
end
if net_measure_option.shortest_path_length == 1
    fprintf('Calculating the shortest distance matrix of source nodes.\n');
    [net.shortest_path_length.global, net.shortest_path_length.nodal] = CCM_AvgShortestPath(gMatrix);
end
if net_measure_option.vulnerability == 1
    fprintf('Calculating the vulnerability of networks.\n');
    [net.vulnerability.global, net.vulnerability.nodal] = CCM_Vulnerability(gMatrix);
end
if net_measure_option.transitivity == 1
    fprintf('Calculating transitivity of network.\n');
    [net.transitivity.global] = CCM_Transitivity(gMatrix);
end

if net_measure_option.small_worldness == 1
    fprintf('Calculating small-worldness of network.\n');
    randperm_num = net_measure_option.sw.num_simulation;
    fprintf('Small world measure could be very slow for random simulation for %d times, be patient\n',randperm_num);
    [net.smallworldness_sigma.global, net.smallworldness_lambda.global,net.smallworldness_gamma.global] = CCM_SmallWorldness(gMatrix,randperm_num,net_type,1);
end
