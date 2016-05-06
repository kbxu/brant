function data_out = brant_file_pre(data_files, num_niis, is4d_ind, data_outtype)
% convert data filenames to spm compatable filenames

data_out = cell(numel(data_files), 1);
if is4d_ind == 1
%     num_niis = cellfun(@get_nii_frame, data_files);
%     if numel(unique(num_niis)) ~= 1
%         print_diff_vols_msg(num_niis, data_files);
%     end
    
    
    switch(data_outtype)
        case 'data_matrix',
            for m = 1:numel(data_files)
                seq_str = arrayfun(@(x) num2str(x, ',%04d'), 1:num_niis(m), 'UniformOutput', false);
                data_out{m} = cell2mat(strcat(data_files{m}, seq_str'));
            end
        case 'data_cell'
            for m = 1:numel(data_files)
                seq_str = arrayfun(@(x) num2str(x, ',%04d'), 1:num_niis(m), 'UniformOutput', false);
                data_out{m} = strcat(data_files{m}, seq_str');
            end
    end
else
%     num_niis = cellfun(@numel, data_files);
%     if numel(unique(num_niis)) ~= 1
%         print_diff_vols_msg(num_niis, data_files);
%     end

    switch(data_outtype)
        case 'data_matrix',
            for m = 1:numel(num_niis)
                data_out{m} = cell2mat(strcat(data_files{m}, ',0001'));
            end
        case 'data_cell',
            for m = 1:numel(num_niis)
                data_out{m} = strcat(data_files{m}, ',0001');
            end
    end
end

% function print_diff_vols_msg(num_niis, data_files)
% 
% arrayfun(@(x, y) fprintf('Timepoint:%d\t%s\n', x, y{1}), num_niis, data_files);
% try
%     time_now = ceil(clock);
%     log_fn = fullfile(pwd, ['subjects_diff_tps', sprintf('_%d', time_now), '.txt']);
%     warning('The numbers of volume/subject are different! Please visit %s!', log_fn);
%     fid = fopen(log_fn, 'rw');
%     arrayfun(@(x, y) fprintf(fid, 'Timepoint:%d\t%s\n', x, y{1}), num_niis, data_files);
%     fclose(fid);
% catch
%     warning('The numbers of volume/subject are different! Please chcek');
% end
