function brant_net_calc(jobman)

thres_corr_ind = jobman.thres_int_bin;
thres_spar_ind = jobman.thres_spar_bin;

thres_corr = jobman.thres_int;
thres_spar = jobman.thres_spar;
use_abs_ind = jobman.use_abs_ind;

net_measure_option = jobman.net_calcs;

if strcmpi(jobman.matrix_type, 'binarized network') == 1
    net_type = 'binary';
else
    net_type = 'weighted';
end

outdir = jobman.out_dir{1};
mst_ind = jobman.mst;
num_workers = jobman.par_workers;

fprintf('\tLoading network matrices...\n');
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
    fprintf('\tSubject %s\n', subj_id);
    
    corr_mat = load(mat_list{m});
    num_node = size(corr_mat, 1);
    bad_ind = ~isfinite(corr_mat);
    corr_mat(bad_ind) = 0;
    corr_mat(logical(eye(num_node))) = 0;
    
    sym_ind = isequal(corr_mat, corr_mat');
    if (sym_ind == 0)
        error('Matrix is not symmetric!');
    end
    
    if use_abs_ind == 1
        mat_tmp = abs(double(corr_mat));
    else
        mat_tmp = double(corr_mat);
    end
    
%     if strcmpi(net_type, 'weighted')
%         % the higher the correlation, the shorter the distance
%         mat_tmp = 1 ./ mat_tmp;
%     end
%     if (mst_ind == 1)
%         
%     end
    
    % get the backbone of the network using minimum spanning tree
    if (mst_ind == 1)
        % the higher the correlation coefficient, the shorter the distance
        % Generating the binary graph using minimum spanning tree...
        
%         Inv_Matrix = 10 * max(mat_tmp(:)) - mat_tmp; %
        Inv_Matrix = sparse(10 * max(mat_tmp(:)) - mat_tmp); % for minmum spanning tree & garenteed to be positive
        
        tree = graphminspantree(Inv_Matrix);
        inv_ind = full(tree + tree') > 0;
        mat_tmp(inv_ind) = max(mat_tmp(:));
        
        
%         % use 1 ./ mat_tmp instead?
%         Inv_Matrix = sparse(1 ./ mat_tmp);
%         tree = graphminspantree(Inv_Matrix);
%         inv_ind = full(tree + tree') > 0;
%         mat_tmp(inv_ind) = max(mat_tmp(:));
    end
    
    mat_calc = mat_tmp;
    thres_disp = [];
    thres_str = {};
    if (thres_spar_ind == 1)
        thres_disp = thres_spar_use;
        thres_str = repmat({'sparsity'}, 1, numel(thres_spar_use));
        thres_nodes_num_spar = round(num_node * (num_node - 1) * thres_spar_use / 2);
        ind = triu(true(num_node), 1);
        tmp = sort(mat_calc(ind), 'descend');
        thres_nodes_num_spar_int = tmp(thres_nodes_num_spar);
    else
        thres_nodes_num_spar_int = [];
    end
    
    thres_disp = [thres_corr_use, thres_disp]; %#ok<AGROW>
    thres_str = [repmat({'intensity'}, 1, numel(thres_corr_use)), thres_str]; %#ok<AGROW>
    thres_all = [thres_corr_use'; thres_nodes_num_spar_int];
    
    if strcmpi(net_type, 'weighted')
        net_matrix_all = arrayfun(@(x) (mat_calc >= x) .* mat_calc, thres_all, 'UniformOutput', false);
    else
        net_matrix_all = arrayfun(@(x) mat_calc >= x, thres_all, 'UniformOutput', false);
    end
    
    calc_rsts_all = cell(numel(net_matrix_all), 1);
    if (num_workers > 0)
        parfor n = 1:numel(net_matrix_all)
            fprintf('\tFor subject %s, calculate %s with threshold %g...\n', subj_id, thres_str{n}, thres_disp(n));
            calc_rsts_all{n} = brant_measure(net_measure_option, subj_id, net_matrix_all{n}, net_type);
        end
    else
        for n = 1:numel(net_matrix_all)
            fprintf('\tFor subject %s, calculate %s with threshold %g...\n', subj_id, thres_str{n}, thres_disp(n));
            calc_rsts_all{n} = brant_measure(net_measure_option, subj_id, net_matrix_all{n}, net_type);
        end
    end
    
    calc_rsts_corr = calc_rsts_all(corr_ind); %#ok<NASGU>
    calc_rsts_spar = calc_rsts_all(spar_ind); %#ok<NASGU>
    
     save(fullfile(outdir, [subj_id, '_network.mat']), 'net_measure_option', 'subj_id', 'mst_ind', 'net_type', 'num_node');
                                                  
    if thres_spar_ind == 1
         save(fullfile(outdir, [subj_id, '_network.mat']), 'thres_spar_ind', 'spar_ind',...
                                                           'thres_spar_use', 'thres_nodes_num_spar',...
                                                           'calc_rsts_spar', '-append');
    end
    
    if thres_corr_ind == 1
        save(fullfile(outdir, [subj_id, '_network.mat']), 'thres_corr_ind', 'corr_ind',...
                                                           'thres_corr_use', 'calc_rsts_corr', '-append');
    end
   
end

if (num_workers > 0), brant_parpool('close'); end
fprintf('\n\tFinished!\n');

function net = brant_measure(net_measure_option, subj_id, gMatrix, net_type)

% N = size(gMatrix, 1);

% corr_ind = triu(true(N, N), 1);

if ~any(gMatrix(:))
    net = [];
    return;
end

% net_input: as input of shortest path length related function
if strcmpi(net_type, 'binary')
    net_input_path = gMatrix;
else
    % treat weighted network as inverse when calculating properties
    % related to shortest path length
    net_input_path = 1 ./ gMatrix;
end

 

if (net_measure_option.assortative_mixing == 1)
    tic
    fprintf('\t%s: assortativity coefficient\n', subj_id);
    [net.assortative_mixing.global] = CCM_Assortative(gMatrix);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.neighbor_degree == 1)
    tic
    fprintf('\t%s: neighbors'' degree\n', subj_id);
    [net.neighbor_degree.global, net.neighbor_degree.nodal] = CCM_AvgNeighborDegree(gMatrix);
    fprintf('\tcomputing time %.2f s\n', toc)
end

% if net_measure_option.betweenness_rw == 1
%     fprintf('\t%s: random-walk betweenness.\n', subj_id);
%     [net.betweeness_rw.global, net.betweeness_rw.nodal] = CCM_RBetweenness(gMatrix);
% end
% 
if net_measure_option.betweenness_centrality == 1
    tic
    fprintf('\t%s: shorest-path betweenness\n', subj_id);
    [net.betweenness_centrality.global, net.betweenness_centrality.nodal] = CCM_SBetweenness(net_input_path, 'vertex', net_type);
    fprintf('\tcomputing time %.2f s\n', toc)
end

% if (net_measure_option.betweenness_centrality == 1)
%     fprintf('\t%s: Un-normalized betweenness centrality.\n', subj_id);
%     
%     if (strcmp(computer('arch'), 'win64') == 1)
%         bc = brant_betweenness_centrality(sparse(gMatrix)); %  normalized / ((N - 1) * (N - 2) / 2)
% %         N = size(gMatrix, 1);
% %         bc = bc; %  unnormalized / ((N - 1) * (N - 2) / 2)
%         net.betweenness_centrality.global = mean(bc);
%         net.betweenness_centrality.nodal = bc;
%     else
%         net.betweenness_centrality = brant_SBetweenness(gMatrix, net_type);
%     end
% end

if (net_measure_option.degree == 1)
    tic
    fprintf('\t%s: degree.\n', subj_id);
    [net.degree.global, net.degree.nodal] = CCM_Degree(gMatrix);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.fault_tolerance == 1)
    % a slow one
    tic
    fprintf('\t%s: fault tolerance of network based on global perspective.\n', subj_id);
    [net.fault_tolerance.global, net.fault_tolerance.nodal] = CCM_FaultTol(gMatrix);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.shortest_path_length == 1)
    tic
    fprintf('\t%s: shortest path length.\n', subj_id);
    [net.shortest_path_length.global, net.shortest_path_length.nodal] = CCM_AvgShortestPath(net_input_path);
    fprintf('\tcomputing time %.2f s\n', toc)
%     [net.shortest_path_length.global, net.shortest_path_length.nodal] = brant_AveShortestPathLength(net_input_path);
%     fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.global_efficiency == 1)
    tic
    fprintf('\t%s: global efficiency\n', subj_id);
    [net.global_efficiency.global, net.global_efficiency.nodal] = CCM_GEfficiency(net_input_path); 
    fprintf('\tcomputing time %.2f s\n', toc)
%     [net.global_efficiency.global, net.global_efficiency.nodal] = brant_GlobalEfficiency(net_input_path);
%     fprintf('\tcomputing time %.2f s\n', toc)
end
    
% if any([net_measure_option.local_efficiency,...
%         net_measure_option.global_efficiency,...
%         net_measure_option.shortest_path_length]) == 1
%     fprintf('\t%s: the shortest distance matrix of source nodes.\n', subj_id);
%     if (net_measure_option.shortest_path_length == 1)
%         [net.shortest_path_length.global, net.shortest_path_length.nodal] = brant_AveShortestPathLength(net_input);        
%     end
%     
%     if (net_measure_option.global_efficiency == 1)
%         [net.global_efficiency.global, net.global_efficiency.nodal] = brant_GlobalEfficiency(net_input);
%     end
% end

if (net_measure_option.clustering_coefficient == 1)
    tic
    fprintf('\t%s: clustering coefficients\n', subj_id);
    [net.clustering_coefficient.global, net.clustering_coefficient.nodal] = CCM_ClusteringCoef(gMatrix, net_type);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.local_efficiency == 1)
    tic
    fprintf('\t%s: local-efficiency\n', subj_id);
    [net.local_efficiency.global, net.local_efficiency.nodal] = CCM_LEfficiency(net_input_path);
    fprintf('\tcomputing time %.2f s\n', toc)
end

% if ((net_measure_option.clustering_coefficient == 1) || (net_measure_option.local_efficiency == 1))
%     
%     fprintf('\t%s: clustering coefficients & local efficiency.\n', subj_id);
%     [local_efficiency, clustering_coefficient] = brant_LE_CC(gMatrix, net_measure_option.local_efficiency, net_measure_option.clustering_coefficient);
%     
%     if (net_measure_option.clustering_coefficient == 1)
%         net.clustering_coefficient = clustering_coefficient;
%     end
%     
%     if (net_measure_option.local_efficiency == 1)
%         net.local_efficiency = local_efficiency;
%     end
%     fprintf('\tcomputing time %.2f s\n', toc)
% end

if (net_measure_option.resilience == 1)
    tic
    fprintf('\t%s: resilience\n', subj_id);
    [net.resilience.global] = CCM_Resilience(gMatrix);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.vulnerability == 1)
    tic
    fprintf('\t%s: vulnerability\n', subj_id);
    % internally calls CCM_GEfficiency
    [net.vulnerability.global, net.vulnerability.nodal] = CCM_Vulnerability(net_input_path);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.transitivity == 1)
    tic
    fprintf('\t%s: transitivity\n', subj_id);
    [net.transitivity.global] = CCM_Transitivity(gMatrix, net_type);
    fprintf('\tcomputing time %.2f s\n', toc)
end

if (net_measure_option.small_worldness == 1)
    tic
    fprintf('\t%s: small-worldness\n', subj_id);
    randperm_num = net_measure_option.sw.num_simulation;
    [net.smallworldness_sigma.global,...
     net.smallworldness_lambda.global,...
     net.smallworldness_gamma.global] = CCM_SmallWorldness(net_input_path, randperm_num, net_type, net_measure_option.sw.keep_connectivity);
    fprintf('\tcomputing time %.2f s\n', toc)
%     [net.smallworldness_sigma.global, net.smallworldness_lambda.global, net.smallworldness_gamma.global] = brant_SmallWorldness(gMatrix, randperm_num, net_type, net_measure_option.sw.keep_connectivity, 0);
end

fprintf('\n');
