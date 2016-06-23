function brant_set_path(depend_tool)

switch(lower(depend_tool))
    case 'spm'
        spm_full = which('spm');
        if isempty(spm_full), error('SPM path is not found!');end

        spm_path = fileparts(spm_full);
        rmpath(genpath(spm_path));
        addpath(spm_path);
        spm('fmri');
        spm('quit');
        try
            savepath;
        catch
        end
end