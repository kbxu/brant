function brant_fcd(jobman)
% batch script for fcd and fcs

brant_check_empty(jobman.input_nifti.mask{1}, '\tA whole brain mask is expected!\n');
brant_check_empty(jobman.out_dir{1}, '\tPlease specify an output directories!\n');
brant_check_empty(jobman.input_nifti.dirs{1}, '\tPlease input data directories!\n');

outdir = jobman.out_dir{1};
mask_fn = jobman.input_nifti.mask{1};
bn_path = fileparts(which(mfilename));
thres_corr = jobman.threshold_corr;
opt_fc = jobman.metrics;

if strcmpi(opt_fc, 'abs fcs')
    opt_fc = 'fcs_abs';
end


assert((thres_corr <= 1) && (thres_corr >= 0));

is4d_ind = jobman.input_nifti.is4d;
if (is4d_ind == 0)
    error('Current C++ excutable only works on 4-D data.');
end

switch(computer('arch'))
    case {'win64', 'win32'}
        ba_full = fullfile(bn_path, 'BN.win32');
    case 'glnxa64'
        ba_full = fullfile(bn_path, 'BN.unix64');
    otherwise
       error('Not supported operation system!');
end

[split_prefix, split_strs] = brant_parse_filetype(jobman.input_nifti.filetype);

for mm = 1:numel(split_prefix)
    fprintf('\n\tCurrent indexing filetype: %s\n', split_prefix{mm});
    if ~isempty(split_strs), out_dir_tmp = fullfile(outdir, split_strs{mm}); else out_dir_tmp = outdir; end

    if exist(out_dir_tmp, 'dir') ~= 7
        mkdir(out_dir_tmp);
    end
    
    jobman.input_nifti.filetype = split_prefix{mm};
    nifti_list = brant_get_subjs(jobman.input_nifti);
    nmpos = jobman.input_nifti.nm_pos;

    [mask_hdr, mask_ind, size_mask, new_mask_fn] = brant_check_load_mask(mask_fn, nifti_list{1}, out_dir_tmp); %#ok<ASGLU>
    
    text_out = fullfile(out_dir_tmp, [opt_fc, '_subject_list.txt']);
    fid = fopen(text_out, 'wt');
    cellfun(@(x) fprintf(fid, '%s\n', x), nifti_list);
    fclose(fid);

    if (jobman.cpu == 1)
        mode_str = '-mode cpu -cpub 256';
    else
        mode_str = '-mode gpu -gpub 256';
    end

    out_dir_tmp = regexprep(out_dir_tmp, '[\/\\]+$', '');

    if (ispc == 1)
        fprintf('\n\tRunning %s in new command windows...\n', upper(opt_fc));
        bat_file = fullfile(out_dir_tmp, sprintf('%s.bat', opt_fc));
        
        fid = fopen(bat_file, 'wt');
        fprintf(fid, 'set BN="%s"\n', ba_full);
        fprintf(fid, 'set INFILE="%s"\n', text_out);
        fprintf(fid, 'set MASK="%s"\n', new_mask_fn);
        fprintf(fid, 'set OUTDIR="%s"\n', out_dir_tmp);
        fprintf(fid, '%%BN%% -infile %%INFILE%% -coef %s -thres_corr %g -mask %%MASK%% -nmpos %d -out %%OUTDIR%% %s', opt_fc, thres_corr, nmpos, mode_str);
        fclose(fid);
        
%         fprintf('dos command line:\n%s\n', cmd_str);
        if numel(split_prefix) > 1
            fprintf('\n\t%s is running... logs will be output when finished.\n', upper(opt_fc));
            system(['cmd /C', 32, '"', bat_file, '"']);
        else
            system(['start', 32, '"brant fcd/fcs" cmd.exe /K', 32, '"', bat_file, '"']);
        end
    elseif (isunix == 1)
        fprintf('\n\tRunning %s in command windows...\n', upper(opt_fc));
        bat_file = fullfile(out_dir_tmp, sprintf('%s.sh', opt_fc));
        
        fid = fopen(bat_file, 'wt');
        fprintf(fid, '#!/usr/bin/env bash\n\n');
        fprintf(fid, 'BN="%s"\n', ba_full);
        fprintf(fid, 'INFILE="%s"\n', text_out);
        fprintf(fid, 'MASK="%s"\n', new_mask_fn);
        fprintf(fid, 'OUTDIR="%s"\n', out_dir_tmp);
        fprintf(fid, 'chmod u+x ${BN}\n');
        fprintf(fid, '${BN} -infile ${INFILE} -coef %s -thres_corr %g -mask ${MASK} -nmpos %d -out ${OUTDIR} %s', opt_fc, thres_corr, nmpos, mode_str);
        fclose(fid);
        
        if numel(split_prefix) > 1
            fprintf('Please open a shell command window, cd to %s,\nand run sh %s.sh\n', out_dir_tmp, opt_fc);
        end
    else
        error('Not supported platform!');
    end
end
