function [data_2d_mat, corr_ind, size_sample] = brant_load_matrices_to_2d(mat_list, sym_ind, paired_ind)
% data_2d_mat: load matrices for all subjects and output to a 2d group-value matrix
% corr_ind: used for recovering original position of loaded values

corr_mat = cellfun(@load, mat_list, 'UniformOutput', false);
size_sample = size(corr_mat{1});

if sym_ind == 1
    corr_ind = triu(true(size_sample(1)), 1);
else
    corr_ind = true(size_sample);
end

if paired_ind == 1
    data_2d_mat = cellfun(@(x) x(corr_ind), corr_mat, 'UniformOutput', false); % output to cell array
else
    data_2d_mat = shiftdim(cat(3, corr_mat{:}), 2);
    data_2d_mat = double(data_2d_mat(:, corr_ind));
end