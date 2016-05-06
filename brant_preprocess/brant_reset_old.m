function out = brant_reset(varargin)

switch(upper(varargin{1}))
    
    case 'REALIGN',
        
        out{1} = cell(7,1);
        out{2} = cell(5,1);
        InputVar = brant_default_realign;
        
        out{1}{1} = num2str(InputVar.eoptions.quality);
        out{1}{2} = num2str(InputVar.eoptions.sep);
        out{1}{3} = num2str(InputVar.eoptions.fwhm);
        out{1}{4} = num2str(InputVar.eoptions.rtm);
        out{1}{5} = num2str(InputVar.eoptions.wrap);
        out{1}{6} = InputVar.eoptions.weight;
        out{1}{7} = num2str(InputVar.eoptions.interp);
        
        % write
        out{2}{1} = num2str(InputVar.roptions.which);
        out{2}{2} = num2str(InputVar.roptions.interp);
        out{2}{3} = num2str(InputVar.roptions.wrap);
        out{2}{4} = num2str(InputVar.roptions.mask);
        out{2}{5} = InputVar.roptions.prefix;
        
	case 'NORMALISE',
        out{1} = cell(2,1);
        out{2} = cell(8,1);
        out{3} = cell(6,1);
        InputVar = brant_default_normalise;
        
        out{1}{1} = InputVar.subj.wtsrc;
        out{1}{2} = InputVar.subj.source;
        
        out{2}{1} = InputVar.eoptions.template;
        out{2}{2} = InputVar.eoptions.weight;
        out{2}{3} = num2str(InputVar.eoptions.smosrc);
        out{2}{4} = num2str(InputVar.eoptions.smoref);
        out{2}{5} = InputVar.eoptions.regtype;
        out{2}{6} = num2str(InputVar.eoptions.cutoff);
        out{2}{7} = num2str(InputVar.eoptions.nits);
        out{2}{8} = num2str(InputVar.eoptions.reg);
        
        out{3}{1} = num2str(InputVar.roptions.preserve);
        out{3}{2} = strcat(num2str(InputVar.roptions.bb(1,:)),';',num2str(InputVar.roptions.bb(2,:)));
        out{3}{3} = num2str(InputVar.roptions.vox);
        out{3}{4} = num2str(InputVar.roptions.interp);
        out{3}{5} = num2str(InputVar.roptions.wrap);
        out{3}{6} = InputVar.roptions.prefix;
        
	case 'DENOISE',
        out{1} = cell(2,1);
        out{2} = cell(2,1);
        out{3} = cell(4,1);
        out{4} = cell(2,1);
        InputVar = brant_default_denoise;
        
        out{1}{1} = num2str(InputVar.subj.timepoints);
        out{1}{2} = num2str(InputVar.subj.voxelsize);
        
        out{2}{1} = InputVar.detrend.constant;
        out{2}{2} = InputVar.detrend.linear_drift;
        
        out{3}{1} = InputVar.mask.wm;
        out{3}{2} = InputVar.mask.gm;
        out{3}{3} = InputVar.mask.csf;
        out{3}{4} = InputVar.mask.wholebrain;
        out{3}{5} = InputVar.mask.glob;
        
        out{4}{1} = InputVar.motion.head;
        out{4}{2} = InputVar.motion.deriv;
        
        out{4}{4} = InputVar.prefix;
        
    case 'SMOOTH'
        out{1}{1} = '8 8 8';
        out{1}{2} = 's';
end
