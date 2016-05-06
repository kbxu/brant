function parse_labels


xml_file = importdata('D:\Program Files\local matlab toolbox\spm12\tpm\labels_Neuromorphometrics.txt', '\n');
labels = cellfun(@(x) regexp(x, '<label><index>(\d+)</index><name>([a-zA-Z0-9 \-]*)</name></label>', 'tokens', 'once'), xml_file, 'UniformOutput', false);
label_ind = ~cellfun(@isempty, labels);
label_inds = cellfun(@(x) str2num(x{1}), labels(label_ind));
label_strs = cellfun(@(x) x{2}, labels(label_ind), 'UniformOutput', false);

% fid = fopen('D:\Program Files\local matlab toolbox\Brat\template\masks\labels_Neuromorphometrics.txt', 'wt');
% for m = 1:numel(label_strs)
%     fprintf(fid, '%-5d%s\n', label_inds(m), regexprep(label_strs{m}, '\W', '_'));
% end
% fclose(fid);

wm_ind = cellfun(@(x) ~isempty(regexp(x, 'White Matter', 'tokens')), label_strs);
wm_strs = label_strs(wm_ind);
disp(wm_strs);

csf_ind = cellfun(@(x) ~isempty(regexp(x, '(Ventricle|CSF)', 'tokens')), label_strs);
csf_strs = label_strs(csf_ind);
disp(csf_strs);

cerebellar_ind = cellfun(@(x) ~isempty(regexp(x, '(Cerebellum|Cerebellar)', 'tokens')), label_strs);
cerebellar_strs = label_strs(cerebellar_ind);
disp(cerebellar_strs);

oth_ind = cellfun(@(x) ~isempty(regexp(x, 'Brain Stem|vessel|Optic Chiasm|Lat Vent', 'tokens')), label_strs);  % ventricle round hippocampus in here
oth_strs = label_strs(oth_ind);
disp(oth_strs);

labels_fn = 'D:\Program Files\local matlab toolbox\spm12\tpm\labels_Neuromorphometrics.nii';
labels_nii = load_nii(labels_fn);
tardir = 'D:\Program Files\local matlab toolbox\spm12\tpm\masks';

create_mask(labels_nii, label_inds(csf_ind), tardir, 'CSF_brain.nii');
create_mask(labels_nii, label_inds(wm_ind), tardir, 'WM_brain.nii');
create_mask(labels_nii, label_inds(oth_ind), tardir, 'others.nii');
create_mask(labels_nii, label_inds(~(wm_ind | csf_ind | oth_ind)), tardir, 'GM_brain.nii');

create_mask(labels_nii, setdiff(label_inds(csf_ind), 11), tardir, 'CSF_cerebrum.nii');
create_mask(labels_nii, label_inds(wm_ind & ~cerebellar_ind), tardir, 'WM_cerebrum.nii');
create_mask(labels_nii, label_inds(cerebellar_ind & ~wm_ind), tardir, 'GM_cerebellum.nii');
create_mask(labels_nii, label_inds(~(wm_ind | csf_ind | oth_ind | cerebellar_ind)), tardir, 'GM_cerebrum.nii');

create_mask(labels_nii, label_inds, tardir, 'whole_brain.nii');


function create_mask(labels_nii, label_inds, tardir, fn)

ind_tmp = 0;
for m = 1:numel(label_inds)
    ind_tmp = (labels_nii.img == label_inds(m)) | ind_tmp;
end

labels_nii.img(~ind_tmp) = 0;
save_nii(labels_nii, fullfile(tardir, fn));