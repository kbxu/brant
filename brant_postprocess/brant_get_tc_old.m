function tc_total = brant_get_tc(subj_list, timepoints, m)

hdr_tmp = load_nii_hdr(subj_list.subjs{m}{1});
tc_total = zeros([hdr_tmp.dime.dim(2:4), timepoints], 'single');

disp([9, 'Extracting time sequences for subj', 32, num2str(m)]);

% if strcmpi(mode, 'raw')   % if no mask exist, no need to change its header
%     if subj_list.is4d(m) == 1
%         for t = 1:timepoints       
%             tc_tmp = load_untouch_nii(subj_list.subjs{m}{1}, t);
%             tc_total(:, :, :, t) = tc_tmp.img;
%         end
%     else
%         for t = 1:timepoints
%             tc_tmp = load_untouch_nii(subj_list.subjs{m}{t});
%             tc_total(:, :, :, t) = tc_tmp.img;
%         end
%     end
% else
if subj_list.is4d(m) == 1
    for t = 1:timepoints       
        tc_tmp = load_nii(subj_list.subjs{m}{1}, t);
        tc_total(:, :, :, t) = tc_tmp.img;
    end
else
    for t = 1:timepoints
        tc_tmp = load_nii(subj_list.subjs{m}{t});
        tc_total(:, :, :, t) = tc_tmp.img;
    end
end
% end
