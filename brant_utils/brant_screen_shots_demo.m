function brant_screen_shots_demo(nifti_list, subj_ids, mask_overlay, outdir, slices, varargin)

img_strs = {'axial', 'coronal', 'sagital'};
outdir_ss = brant_make_outdir(outdir, [img_strs, {'ortho'}]);

if numel(slices) == 4
    n_tp = slices(4);
else
    n_tp = 1;
end


if ~isempty(mask_overlay)
    mask_nii = load_nii_mod(mask_overlay);
    mask_slice{1} = single(rot90(squeeze(mask_nii.img(:, :, slices(1)))));
    mask_slice{2} = single(rot90(squeeze(mask_nii.img(:, slices(2), :))));
    mask_slice{3} = single(rot90(squeeze(mask_nii.img(slices(3), :, :))));
    
    mask_all = [[mask_slice{2}; mask_slice{1}], [mask_slice{3}; zeros(size(mask_slice{3}, 2), size(mask_slice{1}, 1))]];
else
    mask_slice = {0, 0, 0};
    mask_all = 0;
end

if nargin == 6
    cstr = varargin{1};
    colours = [1 0 0; 1 1 0; 0 1 0; 0 1 1; 0 0 1; 1 0 1];
    cnames_all  = regexp('Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs', '\|', 'split');
    c_ind = strcmpi(cnames_all, cstr);
    color_rgb = colours(c_ind, :);
else
    color_rgb = [1, 0, 0];
end

mask_slice_rgb = cell(3, 1);
for n = 1:3
    mask_slice_rgb{n} = brant_img2rgb(mask_slice{n}, color_rgb);
end
mask_all_rgb = brant_img2rgb(mask_all, color_rgb);
                      
for m = 1:numel(nifti_list)
    fprintf('Loading subject %d/%d, timepoint %d\n', m, numel(nifti_list), n_tp);
    sample_nii = load_nii_mod(nifti_list{m}, n_tp);
    
    sample_slice{1} = rot90(squeeze(sample_nii.img(:, :, slices(1))));
    sample_slice{2} = rot90(squeeze(sample_nii.img(:, slices(2), :)));
    sample_slice{3} = rot90(squeeze(sample_nii.img(slices(3), :, :)));
    
    sample_slice_all = single([[sample_slice{2}; sample_slice{1}], [sample_slice{3}; zeros(size(sample_slice{3}, 2), size(sample_slice{1}, 1))]]);
    
    for n = 1:3
        outimg = repmat(intResize(sample_slice{n}), [1, 1, 3]) + mask_slice_rgb{n};
        imwrite(imresize(outimg, 5), fullfile(outdir_ss{n}, [subj_ids{m}, '.png']));
    end
    
    outimg = repmat(intResize(sample_slice_all), [1, 1, 3]);
    outimg = outimg + mask_all_rgb;
    imwrite(imresize(outimg, 5), fullfile(outdir_ss{4}, [subj_ids{m}, '.png']));
end

fprintf('\nFinished saving screenshots of brains.\n');

function mask_all_rgb = brant_img2rgb(img2d, color_rgb)
mask_all_rgb = cat(3, img2d * color_rgb(1),...
                      img2d * color_rgb(2),...
                      img2d * color_rgb(3));

function outimg = intResize(img)
% to 0~1

img = single(img);
min_data = min(img(:));
max_data = max(img(:));
outimg = (img - min_data) / (max_data - min_data);