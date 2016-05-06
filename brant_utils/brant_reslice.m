function brant_reslice(ref_file, src_file, prefix)
% ref_file: reference, cell or string
% src_file: source files, cell array or string
% prefix: prefix of output files

if iscell(ref_file)
    ref_file = ref_file{1};
end

if ischar(src_file)
    src_file = {src_file};
end

tmp_vol = spm_vol(ref_file);
if numel(tmp_vol) > 1
    add_str = ',1';
else
    add_str = '';
end


job.ref = {[ref_file, add_str]};
job.source = src_file;
job.roptions.interp = 0; % 0 is nearest neighbour, 4 is 4th degree B-spline
job.roptions.mask = 0;
job.roptions.wrap = [0, 0, 0];
job.roptions.prefix = prefix;

if strcmpi(spm('ver'), 'SPM12')
    spm_run_coreg(job);
else
    spm_run_coreg_reslice(job);
end
