function brant_cvt_help(indir, outdir)

% brant_cvt_help('D:\Program Files\matlab_toolbox\Brant\help', 'C:\Users\kaibin\Desktop\sphinx-brant')

filetype = '*.txt';

cd(indir);
files = dir(filetype);

if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end

for m = 1:numel(files)
    
    tmp = importdata(files(m).name, '\n');
    title_str = regexp(tmp{1}, 'Help information for (.*):', 'tokens', 'once');
    
    if ~isempty(title_str)
        disp(files(m).name);
        tmp{1} = title_str{1};
        tmp{2} = '================================';
        tmp(end) = [];

        fid = fopen(fullfile(outdir, files(m).name), 'w');
        for n = 1:2
            fprintf(fid, '%s\r\n', tmp{n});
        end
        for n = 3:numel(tmp)
            if isempty(tmp{n})
                continue
            end
            fprintf(fid, '* %s\n\n', tmp{n});
        end
        fclose(fid);
    end
end
