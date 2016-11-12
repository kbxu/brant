function rst_files = brant_reslice(ref_file, src_file, prefix, varargin)
% use nearest neighbour to reslice masks
% ref_file: reference, cell or string
% src_file: source files, cell array of 3D or 4D files. NOTE: in each cell
% can only be one 3D or one 4D. src_file can be cell of cells to store
% multiple 3D or 4D files, but can't be cell of cells of cells to store
% more than one files in one sub-cell.
% prefix: prefix of output files

if iscell(ref_file)
    ref_file = ref_file{1};
end

interp_ind = 0;  % 0 is nearest neighbour, 4 is 4th degree B-spline
if nargin == 4
    interp_ind = varargin{1};
end

% if strcmpi(ref_file(end-2:end), '.gz')
%     pth = fileparts(ref_file);
%     tmp_ref = load_untouch_nii_mod(ref_file, 1);
%     ref_file = fullfile(pth, ['first_vol_', ref_file(1:end-3)]);
%     save_untouch_nii(tmp_ref, ref_file);
% end

if ischar(src_file)
    src_file = {src_file};
    string_file_ind = 1;
else
    string_file_ind = 0;
end

% tps_tps = brant_get_nii_frame(src_file);
% if tps_tps == 1
%     add_str = ',1';
% else
%     src_file = brant_file_pre(nifti_list, tps_tps, 1, 'data_cell');
%     add_str = '';
% end

rst_files = cell(numel(src_file), 1);
for m = 1:numel(src_file)
    if isempty(src_file{m})
        continue;
    end
    
    gz_ind = 0;
    if strcmpi(src_file{m}(end-2:end), '.gz')
        gz_ind = 1;
        tmpDir = tempname;
        mkdir(tmpDir);
        pth = fileparts(src_file{m});
        if isempty(pth)
            pth = pwd;
        end
        
        gunzip(src_file{m}, tmpDir); % src_file(m) = 
        [pth_src, fn_src, ext_src] = brant_fileparts(src_file{m}); %#ok<ASGLU>
        src_file{m} = fullfile(tmpDir, [fn_src, strrep(ext_src, '.gz', '')]);
    end
    
    job.ref = {[ref_file, ',1']};
    num_frame = brant_get_nii_frame(src_file{m});
    job.source = arrayfun(@(x) [src_file{m}, num2str(x, ',%04d')], 1:num_frame, 'UniformOutput', false)';
%     if num_frame == 1
%         job.source = src_file(m);
%     else % for 4d data
%         job.source = src_file{m};
%     end
    job.roptions.interp = interp_ind;
    job.roptions.mask = 0;
    job.roptions.wrap = [0, 0, 0];
    job.roptions.prefix = prefix;
    
    if strcmpi(spm('ver'), 'SPM12')
        out = spm_run_coreg(job);
    else
        out = spm_run_coreg_reslice(job);
    end
    
    res_ind = regexp(out.rfiles{1}, ',\d+$');
    
    if ~isempty(res_ind)
        file_resliced = out.rfiles{1}(1:res_ind-1); %unique(cellfun(@(x) x(1:res_ind-1), out.rfiles, 'UniformOutput', false));
    else
        file_resliced = out.rfiles{1};
    end
    
    if gz_ind == 1
        gzip(file_resliced, pth);
        [pth_res, fn_res, ext_res] = brant_fileparts(file_resliced); %#ok<ASGLU>
        rst_files{m} = fullfile(pth, [fn_res, ext_res, '.gz']);
%         if strcmpi(out.rfiles{1}(end-1:end), ',1')
%             tmp = gzip(out.rfiles{1}(1:end-2), pth);
%         else
%             tmp = gzip(out.rfiles{1}, pth);
%         end
%         rst_files{m} = tmp{1};
        rmdir(tmpDir, 's');
    else
        rst_files{m} = file_resliced;
%         if strcmpi(out.rfiles{1}(end-1:end), ',1')
%             rst_files{m} = out.rfiles{1}(1:end-2);
%         else
%             rst_files{m} = out.rfiles{1};
%         end
    end
end

if string_file_ind == 1
    rst_files = rst_files{1};
end