%  Save NIFTI header extension.
%
%  Usage: save_nii_ext(ext, fid)
%
%  ext - struct with NIFTI header extension fields.
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function save_nii_ext_mod(ext, fileprefix)

if ~exist('ext','var')
    error('Usage: save_nii_ext(ext, fid)');
end

if ~isfield(ext,'extension') || ~isfield(ext,'section') || ~isfield(ext,'num_ext')
    error('Wrong header extension');
end

[pth, fn, fileext] = brant_fileparts(fileprefix);
if strcmp(fileext, '.img') || strcmp(fileext, '.img.gz')
    fileprefix = fullfile(pth, [fn, strrep(fileext, '.img', '.hdr')]);
elseif strcmp(fileext, '.IMG') || strcmp(fileext, '.IMG.GZ')
    fileprefix = fullfile(pth, [fn, strrep(fileext, '.IMG', '.HDR')]);
end
    
write_ext(ext, fileprefix);

return;                                      % save_nii_ext


%---------------------------------------------------------------------
function write_ext(ext, fn)

type_ele = cell(1, 3 * ext.num_ext);
vals = cell(1, 3 * ext.num_ext);
num_ele = zeros(1, 3 * ext.num_ext, 'uint32');
for m = 1:ext.num_ext
    vals{(m-1)*3+1} = cast(ext.section(m).esize, 'int32');
    vals{(m-1)*3+2} = cast(ext.section(m).ecode, 'int32');
    vals{(m-1)*3+3} = cast(ext.section(m).edata, 'uint8');
    type_ele{(m-1)*3+1} = 'int32';
    type_ele{(m-1)*3+2} = 'int32';
    type_ele{(m-1)*3+3} = 'uchar';
    num_ele((m-1)*3+1) = numel(ext.section(m).esize);
    num_ele((m-1)*3+2) = numel(ext.section(m).ecode);
    num_ele((m-1)*3+3) = numel(ext.section(m).edata);
end

% foptgz(fileprefix, 'ab',...
%       {'uint8', precision},...
%       {uint32(4), uint32(numel(nii.img))},...
%       {uint32(0), uint32(0)},...
%       {zeros(1, skip_bytes, 'uint8'), nii.img});
foptgz(fn, 'ab',...
       ['uchar', type_ele],...
       num2cell([uint32(numel(ext.extension)), num_ele]),...
       zeros(1, 3 * ext.num_ext + 1, 'uint32'),...
       [cast(ext.extension, 'uint8'), vals]);
% fwrite(fn, ext.extension, 'uchar');
% 
% for i=1:ext.num_ext
%     fwrite(fid, ext.section(i).esize, 'int32');
%     fwrite(fid, ext.section(i).ecode, 'int32');
%     fwrite(fid, ext.section(i).edata, 'uchar');
% end

return;                                      % write_ext

