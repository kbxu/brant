function brant_extract_links(fc_file, fc_mask, fc_weight, outfn)
% fc_file from brant->FC->ROI Calculation
% fc_mask is a n*n matrix, stored in a txt file, n is the number of rois
% fc_weight can be a n*n matrix of T value
% outfn specifies the output filename
% example brant_extract_links('paired_t_after_vs_before.mat',
% 'paired_t_after_vs_before_h_unc.txt', 'paired_t_after_vs_before_tval.txt');

fc_info = load(fc_file, 'rois_str');
fc_mask_val = load(fc_mask);
fc_weight_val = load(fc_weight);

assert(isequal(fc_mask_val, fc_mask_val'));
assert(isequal(fc_weight_val, fc_weight_val'));

[x, y] = find(triu(fc_mask_val ~= 0, 1));
fc_strings = [fc_info.rois_str(x), fc_info.rois_str(y)];
wei_val = arrayfun(@(a, b) fc_weight_val(a, b), x, y);

[srt_wei, srt_ind] = sort(wei_val, 'descend');
srt_fc_strings = fc_strings(srt_ind, :);

A = [{'ROI1', 'ROI2', 'weight'}; [srt_fc_strings, num2cell(srt_wei)]];
brant_write_csv(outfn, A);
