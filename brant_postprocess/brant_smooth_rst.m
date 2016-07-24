function brant_smooth_rst(datadirs, filetype, fwhm, prefix, in_mask)
% datadirs: cell array of data directories
% filetype: match files
% fwhm: e.g. [6,6,6] full width half maximum of Gaussian Kernel
% in_mask: 0, 1. inplicit mask

assert(iscell(datadirs));

sminfo.fwhm  = fwhm;
sminfo.prefix  = prefix;
sminfo.dtype = 0;
sminfo.im = in_mask;

for m = 1:numel(datadirs)
    if ~isempty(datadirs{m})
        fns = dir(fullfile(datadirs{m}, filetype));
        if ~isempty(fns)
            fprintf('\tSmoothing data in %s...\n', datadirs{m});
            fns_full = arrayfun(@(x) fullfile(datadirs{m}, x.name), fns, 'UniformOutput', false);
            sminfo.data = fns_full;
            
            spm_run_smooth(sminfo);
        else
            warning(['No files are found in', 32, datadirs{m}]);
        end
    end
end