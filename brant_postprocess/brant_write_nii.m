function brant_write_nii(result_3d, mask_ind, mask_hdr, subj_id, calc_type, outdir, nor_m, nor_z, out_nor)

% result_3d: the output image matrix
% mask_ind: mask index in 1-d
% mask_hdr: header of mask loaded by load_nii
% subj_id: subject name
% calc_type: for output filename only
% outdir: directory to restore output file
% nor_m: index of output normalizd by divided by mean
% nor_z: index of output normalizd by substracted by mean and divided by standard error
% out_nor: directories to restore normalised output file

size_mask = mask_hdr.dime.dim(2:4);

%%%% write the result out
filename = fullfile(outdir, [calc_type, '_raw_', subj_id, '.nii']);
nii = make_nii(result_3d, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
save_nii(nii, filename);

if any([nor_m, nor_z])
%     mask_new = brant_check_mask(result_3d, mask_ind);
    data_vec = result_3d(mask_ind);
    
    data_good_ind = (isfinite(data_vec)) & (data_vec ~= 0);
    mean_data = mean(data_vec(data_good_ind));
end


if nor_m == 1
    result_3d_nor = nan(size_mask, 'single');
    result_3d_nor(mask_ind) = data_vec / mean_data;

    filename = fullfile(out_nor{1}, [calc_type, '_m_', subj_id, '.nii']);
    nii = make_nii(result_3d_nor, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
    save_nii(nii, filename);
end

if nor_z == 1
    std_data = std(data_vec(data_good_ind));
    
    result_3d_nor = nan(size_mask, 'single');
    result_3d_nor(mask_ind) = (data_vec - mean_data) ./ std_data;

    filename = fullfile(out_nor{2}, [calc_type, '_z_', subj_id, '.nii']);
    nii = make_nii(result_3d_nor, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
    save_nii(nii, filename);
end
