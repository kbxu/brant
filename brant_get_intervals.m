function int_array = brant_get_intervals(start_pt, end_pt, len_int)
% works only for integer
% start_pt: start point
% end_pt: end point
% len_int: length of interval

assert(start_pt < end_pt);

num_pts = end_pt - start_pt + 1;

num_blk = ceil(double(num_pts) / double(len_int));

int_tmp = start_pt:len_int:end_pt;
int_array = zeros(num_blk, 2);
for m = 1:num_blk
    if m == num_blk
        int_array(m, :) = [int_tmp(m), min(end_pt, int_tmp(m) + len_int - 1)];
    else
        int_array(m, :) = [int_tmp(m), int_tmp(m) + len_int - 1];
    end
end
