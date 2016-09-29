function num_niis = brant_check_tps(is4d_ind, process_str, nifti_list, working_dir)
% check and output time points
% works only for unzipped files!

if (is4d_ind == 1)
    num_niis = cellfun(@brant_get_nii_frame, nifti_list);
    if numel(unique(num_niis)) ~= 1
        print_diff_vols_msg(working_dir, process_str, num_niis, nifti_list);
    end
else
    num_niis = cellfun(@numel, nifti_list);
    if (numel(unique(num_niis)) ~= 1)
        print_diff_vols_msg(working_dir, process_str, num_niis, nifti_list);
    end
end

function print_diff_vols_msg(working_dir, process_str, num_niis, data_files)

arrayfun(@(x, y) fprintf('Timepoint:%d\t%s\n', x, y{1}), num_niis, data_files);
try
    time_now = ceil(clock);
    log_fn = fullfile(working_dir, ['brant_', process_str, '_diff_tps', sprintf('_%d', time_now), '.txt']);
    warning('The numbers of volume/subject are different! Please visit %s!', log_fn);
    fid = fopen(log_fn, 'rw');
    arrayfun(@(x, y) fprintf(fid, 'Timepoint:%d\t%s\n', x, y{1}), num_niis, data_files);
    fclose(fid);
catch
    warning('The numbers of volume/subject are different! Please chcek');
end
