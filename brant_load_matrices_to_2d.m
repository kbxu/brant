function [data_2d_mat, corr_ind, size_sample] = brant_load_matrices_to_2d(mat_list, sym_ind, paired_ind, varargin)
% data_2d_mat: load matrices for all subjects and output to a 2d group-value matrix
% corr_ind: used for recovering original position of loaded values
% varargin can be corr_mask

if nargin == 4
    corr_mask = varargin{1};
else
    corr_mask = true;
end

size_sample = size(load(mat_list{1}));

if sym_ind == 1
    corr_ind = triu(true(size_sample(1)), 1) & corr_mask;
else
    corr_ind = true(size_sample) & corr_mask;
end

mat_idx = zeros(size(mat_list));
mat_idx(:) = 1:numel(mat_list);
data_2d_mat = arrayfun(@(x, y) brant_load_single_mat(x{1}, corr_ind, y, numel(mat_list)), mat_list, mat_idx, 'UniformOutput', false);

data_2d_mat = cat(1, data_2d_mat{:});
% if paired_ind == 0
%     data_2d_mat = cat(1, data_2d_mat{:});
% end

% if paired_ind == 1
%     data_2d_mat = cellfun(@(x) x(corr_ind), corr_mat, 'UniformOutput', false); % output to cell array
% else
%     data_2d_mat = shiftdim(cat(3, corr_mat{:}), 2);
%     data_2d_mat = double(data_2d_mat(:, corr_ind));
% end


function mat_1d = brant_load_single_mat(mat_file, corr_ind, num_ind, num_tot)

fprintf('\tLoading %d/%d: %s\n', num_ind, num_tot, mat_file);
mat_tmp = load(mat_file);

% % test distribution normalization
% corr_ind_tmp = triu(true(size(mat_tmp)), 1);
% mat_tmp = mat_tmp - mean(mat_tmp(corr_ind_tmp));
% mat_tmp = mat_tmp / std(mat_tmp(corr_ind_tmp));
% %

mat_1d = reshape(mat_tmp(corr_ind), 1, []);