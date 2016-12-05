function brant_save_nii(is4d, raw_name, prefix, mask_hdr, data_4d, outdir, gzip_ind)

if gzip_ind == 1
    ext_out = '.nii.gz';
end

if is4d == 1
    [filedir, nm_tmp, ext] = brant_fileparts(raw_name);
    nm = regexprep(nm_tmp, '.(nii|nii.gz|hdr|img)$', '', 'ignorecase');
    if isempty(outdir)
        destdir = filedir;
    else
        destdir = outdir;
    end
    if gzip_ind == 1
        filename = fullfile(destdir, [prefix, nm, ext_out]);
    else
        filename = fullfile(destdir, [prefix, nm, ext]);
    end
    nii = make_nii(data_4d, mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
    save_nii(nii, filename);
else
    for t = 1:numel(raw_name)
        [filedir, nm_tmp, ext] = fileparts(raw_name{t});
        nm = regexprep(nm_tmp, '.(nii|nii.gz|hdr|img)$', '', 'ignorecase');
        if isempty(outdir)
            destdir = filedir;
        else
            destdir = outdir;
        end
        if gzip_ind == 1
            filename = fullfile(destdir, [prefix, nm, ext_out]);
        else
            filename = fullfile(destdir, [prefix, nm, ext]);
        end
        nii = make_nii(data_4d(:, :, :, t), mask_hdr.dime.pixdim(2:4), mask_hdr.hist.originator(1:3)); 
        save_nii(nii, filename);
    end
end
