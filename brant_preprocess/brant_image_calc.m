function brant_image_calc(imgsInOrder, outputfn, outputdir, expression, dmtx)

matlabbatch{1}.spm.util.imcalc.input = imgsInOrder;
matlabbatch{1}.spm.util.imcalc.output = outputfn;
matlabbatch{1}.spm.util.imcalc.outdir = outputdir;
matlabbatch{1}.spm.util.imcalc.expression = expression;
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = dmtx;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run', matlabbatch);