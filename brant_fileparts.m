function [pth,nam,ext] = brant_fileparts(fname)

[pth,nam,ext] = fileparts(fname);

if strcmp(ext,'.gz')
    ext = [nam(end-3:end), '.gz'];
    nam = nam(1:end-4);
end
