function brant_copyfile(filename, outdir)
% mimic copyfile in matlab, but do it for hdr/img pairs
% filename should be one specific filename as string, not using *
% if in outdir exists the same filename, copy by force and overwrite it
% outdir must not be a filename

if (length(filename) > 3) && (length(filename) <= 6)
    if strcmpi(filename(end-2:end), 'hdr') || strcmpi(filename(end-2:end), 'img')
        copyfile([filename(1:end-3), 'hdr'], outdir, 'f');
        copyfile([filename(1:end-3), 'img'], outdir, 'f');
    else
        copyfile(filename, outdir, 'f');
    end
elseif (length(filename) > 6)
    if strcmpi(filename(end-5:end), 'hdr.gz') || strcmpi(filename(end-5:end), 'img.gz')
        copyfile([filename(1:end-6), 'hdr.gz'], outdir, 'f');
        copyfile([filename(1:end-6), 'img.gz'], outdir, 'f');
    else
        copyfile(filename, outdir, 'f');
    end
else
    copyfile(filename, outdir, 'f');
end
