function conn_ind = brant_isconnected(gBin)
% gBin should be symmetric matrix with zero diagnal elements

% conn_ind = false;

src_pts = unidrnd(size(gBin, 1));
left_ind = true(size(gBin, 1), 1);
left_ind(src_pts) = false;

while(any(left_ind))
    
    src_nbr = gBin(:, src_pts);
    
    tmp_ind = src_nbr(:, 1);
    for n = 2:size(src_nbr, 2)
        tmp_ind = tmp_ind | src_nbr(:, n);
    end
    
    src_pts = left_ind & tmp_ind;
    if ~any(src_pts)
        conn_ind = false;
        return;
    end
    
    left_ind(src_pts) = false;
end

conn_ind = true;
