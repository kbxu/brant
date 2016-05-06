function brant_sd_matlab(mask, subj_vols, corr_thres, dist_thres, tardir)

% test
mask = '/DATA/231/kbxu/matlab_local_toolbox/Brant/template/AAL_mask_3mm.nii';
% mask = '/DATA/231/kbxu/test_sd/roi_001_X0_Y0_Z0_radius30mm_type_sphere.nii';
subj_vols = {'/DATA/231/kbxu/test_sd/r3NC_05_0208.nii'};
corr_thres = 0.5;
dist_thres = [14, 16];
tardir = '/DATA/231/kbxu/test_sd/out_r3';

num_corr = numel(corr_thres);
num_dist = numel(dist_thres);

wb_mask = load_nii(mask);
mask_ind = wb_mask.img > 0.5;

size_mask = wb_mask.hdr.dime.dim(2:4);

mask_ind_1D = find(mask_ind);
n_vox_mask = numel(mask_ind_1D);
[mask_x, mask_y, mask_z] = ind2sub(wb_mask.hdr.dime.dim(2:4), mask_ind_1D);

[R, C, P]  = ndgrid(0:size_mask(1) - 1,0:size_mask(2) - 1,0:size_mask(3) - 1);
RCP = [R(:)'; C(:)'; P(:)'];
clear('R', 'C', 'P');
RCP(4,:) = 1;

s_mat = [wb_mask.hdr.hist.srow_x; wb_mask.hdr.hist.srow_y; wb_mask.hdr.hist.srow_z];
XYZ = s_mat * RCP;

XYZ_masked = XYZ(:, mask_ind_1D);


for m = 1:numel(subj_vols)
    
    [ooo, subj_str] = fileparts(subj_vols{m}); %#ok<ASGLU>
    
    TC_total_tmp = load_nii(subj_vols{m});
    
    TC = zeros([size(TC_total_tmp.img, 4), n_vox_mask], 'single');
    for n_mask = 1:n_vox_mask
        TC(:, n_mask) = single(squeeze(TC_total_tmp.img(mask_x(n_mask), mask_y(n_mask), mask_z(n_mask), :)));
    end
    clear('TC_total_tmp');
    
    if n_vox_mask < 2^8
        data_class = 'uint8';
        data_type = 2;
    elseif n_vox_mask < 2^16
        data_class = 'uint16';
        data_type = 512;
    elseif n_vox_mask < 2^32
        data_class = 'uint32';
        data_type = 768;
    else
        error('Data type not supported!');
    end
    
    TC_out_gt = zeros([num_corr * num_dist, n_vox_mask], data_class);
    TC_out_st = zeros([num_corr * num_dist, n_vox_mask], data_class);
        
    tic
    for n_mask = 1:n_vox_mask
        
        corr_wb = corr(TC(:, n_mask), TC);

        if rem(n_mask, 1000) == 0
            fprintf('.');
            toc
        end
        
        for n_corr = 1:num_corr
            
            n_corr_ind = (n_corr - 1) * num_dist;
            
            corr_wb_ind = corr_wb > corr_thres(n_corr);
            corr_wb_ind(n_mask) = 0;
            
            if any(corr_wb_ind)
                corr_ind_XYZ = XYZ_masked(:, corr_wb_ind);
                dist_eu = brant_pdist2(XYZ_masked(:, n_mask), corr_ind_XYZ);

                for n_dist = 1:num_dist
                    dist_ind = dist_eu > dist_thres(n_dist);
                    TC_out_gt(n_corr_ind + n_dist, n_mask) = sum(dist_ind(:));
                    TC_out_st(n_corr_ind + n_dist, n_mask) = length(dist_eu) - 1 - TC_out_gt(n_corr_ind + n_dist, n_mask);
                end
            end
        end
    end
    
    fprintf('\nCalculation finished\n');
    
    for n_corr = 1:num_corr
        tar_corr = fullfile(tardir, ['corr_', num2str(corr_thres(n_corr), '%4.2f')]);
        if exist(tar_corr, 'dir') ~= 7
            mkdir(tar_corr);
        end
        
        for n_dist = 1:num_dist
            TC_out_gt_nii = zeros(size_mask, class(TC_out_gt));
            TC_out_st_nii = zeros(size_mask, class(TC_out_st));

            TC_out_gt_nii(mask_ind) = TC_out_gt((n_corr - 1) * num_dist + n_dist, :);
            TC_out_st_nii(mask_ind) = TC_out_st((n_corr - 1) * num_dist + n_dist, :);

            brant_save_nii(1, {fullfile(tar_corr, [subj_str, '.nii'])},...
                        ['long_term_', num2str(dist_thres(n_dist), '%4.1f'), '_'], wb_mask.hdr, TC_out_gt_nii, data_type);

            brant_save_nii(1, {fullfile(tar_corr, [subj_str, '.nii'])},...
                        ['short_term_', num2str(dist_thres(n_dist), '%4.1d'), '_'], wb_mask.hdr, TC_out_st_nii, data_type);
        end
    end
end

function dist_eu = brant_pdist2(src_pts, tar_pts)

cols = size(tar_pts, 2);
diff_pts = tar_pts - repmat(src_pts, [1, cols]);
sum_diff_squ = sum(diff_pts.^2, 1);
dist_eu = sqrt(sum_diff_squ);
