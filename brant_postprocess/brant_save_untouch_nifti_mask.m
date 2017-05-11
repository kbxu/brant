function brant_save_untouch_nifti_mask(nii_hdr, mask_ind, mask_t_ind, img2d, raw_fns, prefix, gzind, outdir)
% raw_fns: 4-d file's filename stored as string, or 3-d filenames stored in cell array
% nii_hdr: header of output nii
% mask_ind: 3d binary mask matrix
% mask_t_ind: 1-D temporal mask, true to save the indexed frame, false to discard the frame
% img: 2D image data, need to be reshaped here
% prefix: prefix of output file
% gzind: 1 to output *.gz file, 0 to output *.nii or *.img/*.hdr files
% ourdir: output directory

if ischar(raw_fns)
    raw_fns = {raw_fns};
    num_files = 1;
elseif iscell(raw_fns)
    num_files = numel(raw_fns);
end

if num_files == 1
    
    nii.hdr = nii_hdr;
    nii.untouch = 1;
    % update number of frames
    nii.hdr.dime.dim(5) = sum(mask_t_ind);
    nii_size = nii.hdr.dime.dim(2:5);
    
    if ~isempty(mask_ind)
        nii_2d = zeros([sum(mask_t_ind), prod(nii_size(1:3))], 'single');
        nii_2d(:, mask_ind) = img2d;
        
        nii.img = reshape(shiftdim(nii_2d, 1), nii_size);
    else
        nii.img = reshape(shiftdim(single(img2d), 1), nii_size);
    end
    clear('nii_2d', 'img2d');
    
    [pth, fn, ext] = brant_fileparts(raw_fns{1});
    if gzind == 1
        if ~strcmpi(ext(end-2:end), '.gz')
            ext = [ext, '.gz'];
        end
    else
        if strcmpi(ext(end-2:end), '.gz')
            ext = ext(1:end-3);
        end
    end
    nii.hdr.dime.datatype = 16; % single, 4 bytes
    if isempty(outdir)
        save_untouch_nii_mod(nii, fullfile(pth, [prefix, fn, ext]));
    else
        save_untouch_nii_mod(nii, fullfile(outdir, [prefix, fn, ext]));
    end
else
    
    nii.hdr = nii_hdr;
    nii.untouch = 1;
    nii_size = nii.hdr.dime.dim(2:4);
    
    for m = 1:num_files
        
        if ~mask_t_ind(m)
            % do not save the current mask
            continue;
        end
        
        if isempty(mask_ind)
            nii.img = reshape(img2d(m, :), nii_size(1:3));
        else
            nii.img = zeros(nii_size(1:3), 'single');
            nii.img(mask_ind) = img2d(m, :);
        end
        
        [pth, fn, ext] = brant_fileparts(raw_fns{m});
        if gzind == 1
            if ~strcmpi(ext(end-2:end), '.gz')
                ext = [ext, '.gz']; %#ok<*AGROW>
            end
        else
            if strcmpi(ext(end-2:end), '.gz')
                ext = ext(1:end-3);
            end
        end
        nii.hdr.dime.datatype = 16; % single, 4 bytes
        if isempty(outdir)
            save_untouch_nii_mod(nii, fullfile(pth, [prefix, fn, ext]));
        else
            save_untouch_nii_mod(nii, fullfile(outdir, [prefix, fn, ext]));
        end
    end
end

% if ((isa(nii_2d, 'double') == 0) && (isa(nii_2d, 'single') == 0))
%     nii_2d = single(nii_2d);
% end
