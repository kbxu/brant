function brant_visual_check(jobman)
% support only 4d files and structure files


num_chk = jobman.num_chk;
[nifti_list, subj_ids] = brant_get_subjs(jobman.input_nifti);

if strcmpi(jobman.input_nifti.filetype(end-2:end), '.gz')
    cellfun(@gunzip, nifti_list);
end

num_subj = numel(subj_ids);
if num_subj < num_chk
    num_chk = num_subj;
end

if jobman.input_nifti.is4d == 1
    all_tps = cellfun(@get_nii_frame, nifti_list);
else
    all_tps = cellfun(@(x) get_nii_frame(x{1}), nifti_list);
end
curr_tps = all_tps(1);

current_img = strcat(nifti_list{num_chk}, ',0001');
fprintf('\nCurrent file %d/%d %s\n\n', num_chk, num_subj, current_img);
spm_check_registration(char(current_img));

% user_name = java.lang.System.getProperty('user.name');
h_chk_fig = findobj(0, '-regexp', 'Name', sprintf('%s (.*): Graphics', spm('ver')));

if isempty(h_chk_fig)
    h_figures = findobj(0, 'Type', 'figure');
    for m = 1:numel(h_figures)
        h_axes = findobj(h_figures, 'Type', 'axes');
        if numel(h_axes) == num_chk * 3
            h_chk_fig = h_figures(m);
            break;
        end
    end
end

if isempty(h_chk_fig)
    error('Unable to find spm figure for showing');
else
    curr_set = num_chk;
    curr_tp = 1;
    set(h_chk_fig, 'Userdata', all_tps);
    set(h_chk_fig, 'KeyReleaseFcn', {@brant_spm_figure_KeyFun, [curr_set, curr_tp, num_subj, curr_tps], subj_ids, nifti_list});
end

function brant_spm_figure_KeyFun(obj, evd, img_info, subj_ids, nifti_list)
% left and right keys for timepoints
% up and down keys for subject sets

switch(lower(evd.Key))
    case {'uparrow', 'w'}
        if img_info(2) > 1
            img_info(2) = img_info(2) - 1;
        else
            return;
        end
    case {'downarrow', 's'}
        if img_info(2) < img_info(4)
            img_info(2) = img_info(2) + 1;
        else
            return;
        end
    case {'leftarrow', 'a'}
        if img_info(1) > 1
            img_info(1) = img_info(1) - 1;
        else
            return;
        end
    case {'rightarrow', 'd'}
        if img_info(1) < img_info(3)
            img_info(1) = img_info(1) + 1;
        else
            return;
        end
    otherwise 
        return;
end

tps = get(obj, 'Userdata');
img_info(4) = tps(img_info(1));
curr_tp_str = sprintf(',%.3d', img_info(2));
current_img = strcat(nifti_list{img_info(1)}, curr_tp_str);
% current_label = strcat(nifti_list{img_info(1)}, curr_tp_str);

spm_check_registration(char(current_img));
fprintf('Current file %d/%d %s\n\n', img_info(1), img_info(3), current_img);
set(obj, 'KeyReleaseFcn', {@brant_spm_figure_KeyFun, img_info, subj_ids, nifti_list});