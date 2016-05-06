function sum = matMinusRowVec(matrix, row_vec)
% size(matrix, 2) and length(row_vec) must be 3
sum = matrix - [ones(size(matrix, 1), 1) * row_vec(1), ones(size(matrix, 1), 1) * row_vec(2), ones(size(matrix, 1), 1) * row_vec(3)];