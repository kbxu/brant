function brant_screen_shots_demo(nifti_list, subj_ids, mask_overlay, outdir, slices)

if numel(slices) == 4
    n_tp = slices(4);
else
    n_tp = 1;
end

if ~isempty(mask_overlay)
    mask_nii = load_nii_mod(mask_overlay);
    mask_slice{1} = rot90(squeeze(mask_nii.img(:, :, slices(1))));
    mask_slice{2} = rot90(squeeze(mask_nii.img(:, slices(2), :)));
    mask_slice{3} = rot90(squeeze(mask_nii.img(slices(3), :, :)));
    
    mask_all = single([[mask_slice{2}; mask_slice{1}], [mask_slice{3}; zeros(size(mask_slice{3}, 2), size(mask_slice{1}, 1))]]);
else
%     mask_slice = {0, 0, 0};
    mask_all = 0;
end

img_strs = {'axial', 'coronal', 'sagital'};

for m = 1:numel(nifti_list)
    fprintf('Loading subject %d/%d, timepoint %d\n', m, numel(nifti_list), n_tp);
    sample_nii = load_nii_mod(nifti_list{m}, n_tp);
    
    sample_slice{1} = rot90(squeeze(sample_nii.img(:, :, slices(1))));
    sample_slice{2} = rot90(squeeze(sample_nii.img(:, slices(2), :)));
    sample_slice{3} = rot90(squeeze(sample_nii.img(slices(3), :, :)));
    
    sample_slice_all = single([[sample_slice{2}; sample_slice{1}], [sample_slice{3}; zeros(size(sample_slice{3}, 2), size(sample_slice{1}, 1))]]);
    
    outimg = repmat(intResize(sample_slice_all), [1, 1, 3]);
    outimg(:, :, 1) = outimg(:, :, 1) + mask_all;
    imwrite(imresize(outimg, 5), fullfile(outdir, [subj_ids{m}, '.png']));
        
%     for n = 1:3
%         outimg = repmat(intResize(sample_slice{n}), [1, 1, 3]);
%         outimg(:, :, 1) = outimg(:, :, 1) + mask_slice{n};
%         imwrite(imresize(outimg, 5), fullfile(outdir, [subj_ids{m}, '_', img_strs{n}, '.png']));
%     end
end

function outimg = intResize(img)
% to 0~1

img = single(img);
min_data = min(img(:));
max_data = max(img(:));
outimg = (img - min_data) / (max_data - min_data);