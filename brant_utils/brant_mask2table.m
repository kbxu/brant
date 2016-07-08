function brant_mask2table(jobman)

is_label_ind = jobman.lab_c;
is_sep_ind = jobman.sep_c;

outdir = jobman.out_dir{1};

% intensity_thr = jobman.int_thr;
clustersize_thr = jobman.cs_thr;

template_in = jobman.template_img{1};
roi_info_fn = jobman.template_info{1};

roi_show_msg = 0;
[rois_inds, rois_str, roi_tags] = brant_get_rois({template_in}, [], roi_info_fn, roi_show_msg);
clear('rois_inds');

template_nii = load_nii(template_in);
template_nii_mask = template_nii.img > 0.5;

mask_in = jobman.mask_in{1};
if ~isempty(mask_in)
    data_hdr = brant_check_load_mask(mask_in, template_in, outdir);
else
    data_hdr = template_nii.hdr;
end
XYZ = brant_get_XYZ(data_hdr);

mask_ind_all = mask_in_nii.img ~= 0; % intensity_thr;
if is_label_ind == 1
    fprintf('\tReading labeled clusters.\n');
    [mask_inds, mask_str, mask_vals] = brant_get_rois({mask_in}, [], '', roi_show_msg);
else
    fprintf('\tBrant will label clusters for 26-neighbour point.\n');
    [labeled_mask, num_vals] = bwlabeln(mask_ind_all, 26);
    mask_vals = (1:num_vals)';
    mask_inds = arrayfun(@(x) labeled_mask == x, mask_vals, 'UniformOutput', false);
end

% mask_vals = setdiff(unique(labeled_mask(mask_ind_all)), 0);
mask_cnt = cellfun(@(x) sum(x(:)), mask_inds);
mask_good_ind = mask_cnt >= clustersize_thr;

mask_vals = mask_vals(mask_good_ind);
mask_good = mask_inds(mask_good_ind);
clear('mask_inds');

mask_coord = cellfun(@(x) mean(XYZ(x(:), :), 1), mask_good, 'UniformOutput', false);
mask_coord_cell = num2cell(cat(1, mask_coord{:}));

mask_tem = cellfun(@(x) template_nii.img(x & template_nii_mask), mask_good, 'UniformOutput', false);
mask_size = cellfun(@numel, mask_tem);
mask_tem_unique = cellfun(@(x) unique(x), mask_tem, 'UniformOutput', false);

mask_tem_ind = zeros(numel(mask_tem), 1);
for m = 1:numel(mask_tem)
    sum_tem = arrayfun(@(x) sum(mask_tem{m} == x), mask_tem_unique{m});
    [max_val, max_ind] = max(sum_tem); %#ok<*ASGLU>
    mask_tem_ind(m) = mask_tem_unique{m}(max_ind);
end

% mask_ind_strs = arrayfun(@(x) find(x == roi_tags), mask_tem_ind);
% mask_label = cellfun(@(x) regexprep(x, '\_', '\\_'), rois_str(mask_ind_strs), 'UniformOutput', false);
mask_label = arrayfun(@(x) rois_str(x == roi_tags), mask_tem_ind);
A = cat(1, {'x', 'y', 'z', 'label', 'vox_num', 'index'}, cat(2, mask_coord_cell, mask_label, num2cell([mask_size, mask_vals])));
% [pth, fn, ext] = fileparts(mask_in);
brant_write_csv(fullfile(outdir, 'brant_roi_info.csv'), A);

if is_sep_ind == 1
    nii_labeled = make_nii(labeled_mask, mask_in_nii.hdr.dime.pixdim(2:4), mask_in_nii.hdr.hist.originator(1:3));
    save_nii(nii_labeled, fullfile(outdir, [fn, '_labeled.nii']));
end

fprintf('\tFinished!\n');
