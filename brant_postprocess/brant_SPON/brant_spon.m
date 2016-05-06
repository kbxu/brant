function brant_spon(jobman, jobtype)

[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);

% check num_tps at some where
% num_tps = jobman.timepoint;
mask = jobman.mask{1};

if strcmp(jobtype, 'ReHo') == 1
    reho_ind = 1;
    reho_num_nbr = jobman.neighbout_num;
end

num_subj = numel(nifti_list);

% mask roi files
mask_nii = load_nii(mask);
mask_size = mask_nii.hdr.dime.dim(2:4);
mask_ind = find(mask_nii.img > 0.5);
[mask_x, mask_y, mask_z] = ind2sub(mask_size, mask_ind);
num_mask = numel(mask_ind);

if strcmp(jobtype, 'ReHo') == 1
    
    
    
    n_vox_slice = prod(mask_size(1:2));
    n_vox_vol = prod(mask_size(1:3));
    [nbr_x, nbr_y, nbr_z, ind_out] = brant_nbr_vox(mask_ind, reho_num_nbr, mask_size, n_vox_slice, n_vox_vol);
    
    sum_nbr = arrayfun(@(x, y, z) sum(mask_nii.img(ind_out(x, :))), 1:num_mask);
    mask_border = mask_ind(sum_nbr < (reho_num_nbr + 1));
    num_border = sum(mask_border);
    mask_inside = mask_ind(sum_nbr == (reho_num_nbr + 1));
    num_inside = sum(mask_inside);
end

for m = 1:num_subj
    
    fprintf('\tExtracting time serieses from subject %s\n', subj_ids{m});
    [data_2d_mat, data_size] = brant_4D_to_mat(nifti_list{m}, mask_x, mask_y, mask_z, 'cell', subj_ids{m};
%     data_uni_tmp = cellfun(@(x) numel(unique(x)), data_2d_mat);
%     data_uni = data_uni_tmp == num_tps;
%     data_non_uni = ~data_uni;
    num_tps = data_size(4);
    
    if any(data_size(1:3) ~= mask_size)
        error('Size of %s is different from roi, please check!', subj_ids{m});
    end
    
    if reho_ind == 1
        data_2d_sorted = cellfun(@sort, data_2d_mat, 'UniformOutput', false);
        
        
        data_cell = cell(num_mask, 1);
        rank_2d = zeros([num_tps, num_mask], 'single');
        
        for n = 1:num_tps
            rank_2d_tmp = cellfun(@(x, y) mean(find(x(n) == y)), data_2d_mat, data_2d_sorted);
            ave_rank = arrayfun(@(x) mean(rank_2d_tmp(ind_out(x, :))), mask_inside);
            
            for o = 1:numel(mask_inside)
                o
                ave_rank = mean(rank_2d_tmp(ind_out(mask_inside(o), :)));
            end
        end
        
        
    end
end
