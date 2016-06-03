function brant_pps = brant_preprocess_defaults

brant_path = fileparts(which('brant'));

% subject settings
brant_pps.subj.text.inputfile = '';
brant_pps.subj.text.dirs = '';
% brant_pps.subj.text.files = '';
brant_pps.subj.spm.dirs = '';
% brant_pps.subj.spm.files = '';
brant_pps.subj.filetype = 'brant*.nii';
brant_pps.subj.is4d = 1;

brant_pps.subj.out.selected = 0;
brant_pps.subj.out.dir = pwd;
brant_pps.subj.out.nmpos = 1;

% reserved
brant_pps.pref.parallel = 'off';
brant_pps.pref.parallel_workers = 2;
brant_pps.pref.sync = 1;
brant_pps.pref.order = {'slicetiming', 'realign', 'coregister', 'normalise', 'denoise', 'smooth'};
brant_pps.pref.dirs_in_text = 0;
brant_pps.pref.norm12_ind = strcmp(spm('ver'), 'SPM12') == 1;

% index
brant_pps.ind.slicetiming = 0;
brant_pps.ind.realign = 0;
brant_pps.ind.coregister = 0;
brant_pps.ind.normalise = 0;
brant_pps.ind.normalise12 = 0;
brant_pps.ind.denoise = 0;
% brant_pps.ind.filter = 0;
brant_pps.ind.smooth = 0;

% slice timing
brant_pps.slicetiming.slice_order = 0;
brant_pps.slicetiming.tr = 0;
brant_pps.slicetiming.refslice = 0;
brant_pps.slicetiming.prefix = 'a';

% realign
% estimate
brant_pps.realign.eoptions.quality = 0.9;
brant_pps.realign.eoptions.sep = 4;
brant_pps.realign.eoptions.fwhm = 5;
brant_pps.realign.eoptions.rtm = 1;
brant_pps.realign.eoptions.wrap = [0 0 0];
% brant_pps.realign.eoptions.weight = '';
brant_pps.realign.eoptions.interp = 4;
% write
brant_pps.realign.roptions.which = [2 1];
brant_pps.realign.roptions.interp = 4;
brant_pps.realign.roptions.wrap = [0 0 0];
brant_pps.realign.roptions.mask = 1;
brant_pps.realign.roptions.prefix = 'r';

%
brant_pps.coregister.subj.filetype_ref = 'mean*.nii';
brant_pps.coregister.subj.filetype_src = 'co*.nii';
% brant_pps.coregister.subj.filetype_other = '';
brant_pps.coregister.eoptions.cost_fun = 'nmi';
brant_pps.coregister.eoptions.sep = [4 2];
brant_pps.coregister.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
brant_pps.coregister.eoptions.fwhm = [7 7];
brant_pps.coregister.roptions.interp = 0;
brant_pps.coregister.roptions.wrap = [0 0 0];
brant_pps.coregister.roptions.mask = 0;
brant_pps.coregister.roptions.prefix = 'r';

% normalise
% subject infomations
% brant_pps.normalise.subj.source = '';
% brant_pps.normalise.subj.wtsrc = '';
% brant_pps.normalise.subj.filetype = 'mean*.nii';
brant_pps.normalise.subj.filetype_src = 'mean*.nii';
brant_pps.normalise.subj.filetype_wt = '';

% estimate
if isequal(spm('ver'), 'SPM8')
    brant_pps.normalise.eoptions.template = fullfile(fileparts(which('spm')),'templates', 'EPI.nii');
elseif isequal(spm('ver'), 'SPM12')
    brant_pps.normalise.eoptions.template = fullfile(fileparts(which('spm')),'toolbox', 'OldNorm', 'EPI.nii');
end
brant_pps.normalise.eoptions.weight = '';   % template weighting image
brant_pps.normalise.eoptions.smosrc = 8;    % source image smoothing
brant_pps.normalise.eoptions.smoref = 0;    % template image smoothing
brant_pps.normalise.eoptions.regtype = 'mni';
brant_pps.normalise.eoptions.cutoff = 25;
brant_pps.normalise.eoptions.nits = 30;
brant_pps.normalise.eoptions.reg = 1;
% write
brant_pps.normalise.roptions.preserve = 0;
brant_pps.normalise.roptions.bb = [-90 -126 -72;90 90 108];
brant_pps.normalise.roptions.vox = [3, 3, 3];
brant_pps.normalise.roptions.interp = 5;
brant_pps.normalise.roptions.wrap = [0 0 0];
brant_pps.normalise.roptions.prefix = 'w';




brant_pps.normalise12.subj.filetype_src = 'mean*.nii';
brant_pps.normalise12.eoptions.biasreg = 0.0001;
brant_pps.normalise12.eoptions.biasfwhm = 60;
if isequal(spm('ver'), 'SPM8')
    brant_pps.normalise12.eoptions.tpm = '';
elseif isequal(spm('ver'), 'SPM12')
    brant_pps.normalise12.eoptions.tpm = fullfile(fileparts(which('spm')), 'tpm', 'TPM.nii');
end

brant_pps.normalise12.eoptions.affreg = 'mni';
brant_pps.normalise12.eoptions.reg = [0 0.001 0.5 0.05 0.2];
brant_pps.normalise12.eoptions.fwhm = 0;
brant_pps.normalise12.eoptions.samp = 3;
brant_pps.normalise12.woptions.bb = [-90 -126 -72;90 90 108];
brant_pps.normalise12.woptions.vox = [3, 3, 3];
brant_pps.normalise12.woptions.interp = 4;






% denoise
% brant_pps.denoise.subj.tsnr_mask = 'none';
% brant_pps.denoise.subj.tsnr_thres = 20;
brant_pps.denoise.subj.wb_mask = fullfile(brant_path, 'template', 'fmaskEPI_V2mm.nii');
...brant_pps.denoise.subj.wb_mask_other = '';
brant_pps.denoise.subj.gsr = 0;
brant_pps.denoise.subj.nogsr = 0;
brant_pps.denoise.subj.bothgsr = 1;
brant_pps.denoise.subj.prefix_denoise = 'd';
brant_pps.denoise.subj.prefix_filter = 'f';
brant_pps.denoise.subj.reslice_mask_ind = 1;

brant_pps.denoise.detrend_mask.tissue_trends_ind = 1;
brant_pps.denoise.detrend_mask.detrend = 1;
brant_pps.denoise.detrend_mask.gs = fullfile(brant_path, 'template', 'fmaskEPI_V2mm.nii');
brant_pps.denoise.detrend_mask.wm = fullfile(brant_path, 'template', 'mask_WM.nii');
brant_pps.denoise.detrend_mask.csf = fullfile(brant_path, 'template', 'mask_CSF.nii');
brant_pps.denoise.detrend_mask.user_mask = '';
brant_pps.denoise.detrend_mask.tissue_deriv = 1;

brant_pps.denoise.motion.hm_model_ind = 1;
brant_pps.denoise.motion.filetype = 'rp*.txt';
brant_pps.denoise.motion.params_6 = 0;
brant_pps.denoise.motion.params_12 = 1;
brant_pps.denoise.motion.params_24 = 0;
brant_pps.denoise.motion.scrub_FD = []; %0.5;
brant_pps.denoise.motion.use_temp_mask = 0;

brant_pps.denoise.filter.filter_ind = 1;
brant_pps.denoise.filter.tr = 0;
brant_pps.denoise.filter.lower_cutoff = 0.01;
brant_pps.denoise.filter.upper_cutoff = 0.08;


% % filter
% brant_pps.filter.tsnr_mask = 'group tsnr';
% brant_pps.filter.tsnr_thres = 20;
% brant_pps.filter.wb_mask = fullfile(brant_path, 'template', 'fmaskEPI_V3mm.nii');
% brant_pps.filter.lower_cutoff = 0.01;
% brant_pps.filter.upper_cutoff = 0.08;
% brant_pps.filter.tr = 0;
% brant_pps.filter.timepoints = 0;
% brant_pps.filter.prefix = 'f';
% brant_pps.filter.gzip = 0;

% smooth
brant_pps.smooth.fwhm  = [6 6 6];
brant_pps.smooth.prefix  = 's6';
brant_pps.smooth.dtype = 0;
brant_pps.smooth.im = 1;
