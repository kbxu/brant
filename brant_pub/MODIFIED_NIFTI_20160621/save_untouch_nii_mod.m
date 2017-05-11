%  Save NIFTI or ANALYZE dataset that is loaded by "load_untouch_nii.m".
%  The output image format and file extension will be the same as the
%  input one (NIFTI.nii, NIFTI.img or ANALYZE.img). Therefore, any file
%  extension that you specified will be ignored.
%
%  Usage: save_untouch_nii(nii, filename)
%
%  nii - nii structure that is loaded by "load_untouch_nii.m"
%
%  filename  - 	NIFTI or ANALYZE file name.
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function save_untouch_nii_mod(nii, filename)

if ~exist('nii','var') || isempty(nii) || ~isfield(nii,'hdr') || ...
        ~isfield(nii,'img') || ~exist('filename','var') || isempty(filename)
    
    error('Usage: save_untouch_nii(nii, filename)');
end

if ~isfield(nii,'untouch') || nii.untouch == 0
    error('Usage: please use ''save_nii.m'' for the modified structure.');
end

if isfield(nii.hdr.hist,'magic') && strcmp(nii.hdr.hist.magic(1:3),'ni1')
    filetype = 1;
elseif isfield(nii.hdr.hist,'magic') && strcmp(nii.hdr.hist.magic(1:3),'n+1')
    filetype = 2;
else
    filetype = 0;
end

v = version;

%  Check file extension. If .gz, unpack it into temp folder
%
if length(filename) > 2 && strcmp(filename(end-2:end), '.gz')
    
    if ~strcmp(filename(end-6:end), '.img.gz') && ...
            ~strcmp(filename(end-6:end), '.hdr.gz') && ...
            ~strcmp(filename(end-6:end), '.nii.gz')
        
        error('Please check filename.');
    end
    
%     if str2num(v(1:3)) < 7.1 || ~usejava('jvm')
%         error('Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
%     else
%         gzFile = 1;
%         filename = filename(1:end-3);
%     end
end

% [p,f] = fileparts(filename);
% fileprefix = fullfile(p, f);

write_nii(nii, filetype, filename);

%  gzip output file if requested
%
% if exist('gzFile', 'var')
%     if filetype == 1
%         gzip([fileprefix, '.img']);
%         delete([fileprefix, '.img']);
%         gzip([fileprefix, '.hdr']);
%         delete([fileprefix, '.hdr']);
%     elseif filetype == 2
%         gzip([fileprefix, '.nii']);
%         delete([fileprefix, '.nii']);
%     end;
% end;

%   %  So earlier versions of SPM can also open it with correct originator
%  %
% if filetype == 0
%   M=[[diag(nii.hdr.dime.pixdim(2:4)) -[nii.hdr.hist.originator(1:3).*nii.hdr.dime.pixdim(2:4)]'];[0 0 0 1]];
%  save(fileprefix, 'M');
%   elseif filetype == 1
%     M=[];
%    save(fileprefix, 'M');
%end

return					% save_untouch_nii


%-----------------------------------------------------------------------------------
function write_nii(nii, filetype, fileprefix)

hdr = nii.hdr;

if isfield(nii,'ext') && ~isempty(nii.ext)
    ext = nii.ext;
    [ext, esize_total] = verify_nii_ext(ext);
else
    ext = [];
end

switch double(hdr.dime.datatype),
    case   1,
        hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
    case   2,
        hdr.dime.bitpix = int16(8 ); precision = 'uint8';
    case   4,
        hdr.dime.bitpix = int16(16); precision = 'int16';
    case   8,
        hdr.dime.bitpix = int16(32); precision = 'int32';
    case  16,
        hdr.dime.bitpix = int16(32); precision = 'float32';
    case  32,
        hdr.dime.bitpix = int16(64); precision = 'float32';
    case  64,
        hdr.dime.bitpix = int16(64); precision = 'float64';
    case 128,
        hdr.dime.bitpix = int16(24); precision = 'uint8';
    case 256
        hdr.dime.bitpix = int16(8 ); precision = 'int8';
    case 512
        hdr.dime.bitpix = int16(16); precision = 'uint16';
    case 768
        hdr.dime.bitpix = int16(32); precision = 'uint32';
    case 1024
        hdr.dime.bitpix = int16(64); precision = 'int64';
    case 1280
        hdr.dime.bitpix = int16(64); precision = 'uint64';
    case 1792,
        hdr.dime.bitpix = int16(128); precision = 'float64';
    otherwise
        error('This datatype is not supported');
end

%   hdr.dime.glmax = round(double(max(nii.img(:))));
%  hdr.dime.glmin = round(double(min(nii.img(:))));

if filetype == 2
    % nii and nii.gz case
    [pth, fn, fnext] = brant_fileparts(fileprefix);
    
    if strcmpi(fnext(end-2:end), '.gz') == 0
        fileprefix = fullfile(pth, [fn, '.nii']);
    else
        fileprefix = fullfile(pth, [fn, '.nii.gz']);
    end
    
    
%     fid = fopen(sprintf('%s.nii',fileprefix),'w');
    
%     if fid < 0,
%         msg = sprintf('Cannot open file %s.nii.',fileprefix);
%         error(msg);
%     end
    
    hdr.dime.vox_offset = 352;
    
    if ~isempty(ext)
        hdr.dime.vox_offset = hdr.dime.vox_offset + esize_total;
    end
    
    hdr.hist.magic = 'n+1';
    save_nii_hdr_mod(hdr, fileprefix, 'untouch');
%     save_untouch_nii_hdr(hdr, fileprefix);
    
    if ~isempty(ext)
        save_nii_ext_mod(ext, fileprefix);
    end
elseif filetype == 1
%     fid = fopen(sprintf('%s.hdr',fileprefix),'w');
    
%     if fid < 0,
%         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
%         error(msg);
%     end
    
    hdr.dime.vox_offset = 0;
    hdr.hist.magic = 'ni1';
    save_nii_hdr_mod(hdr, fileprefix, 'untouch');
%     save_untouch_nii_hdr(hdr, fid);
    
    if ~isempty(ext)
        save_nii_ext_mod(ext, fileprefix);
    end
    
%     fclose(fid);
%     fid = fopen(sprintf('%s.img',fileprefix),'w');
else
%     fid = fopen(sprintf('%s.hdr',fileprefix),'w');
%     
%     if fid < 0,
%         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
%         error(msg);
%     end
    
    error('Unknown filetype!');
    save_untouch0_nii_hdr(hdr, fileprefix); % haven't done anychange to it
    
%     fclose(fid);
%     fid = fopen(sprintf('%s.img',fileprefix),'w');
end

ScanDim = double(hdr.dime.dim(5));		% t
SliceDim = double(hdr.dime.dim(4));		% z
RowDim   = double(hdr.dime.dim(3));		% y
PixelDim = double(hdr.dime.dim(2));		% x
SliceSz  = double(hdr.dime.pixdim(4));
RowSz    = double(hdr.dime.pixdim(3));
PixelSz  = double(hdr.dime.pixdim(2));

x = 1:PixelDim;

if filetype == 2 && isempty(ext)
    skip_bytes = double(hdr.dime.vox_offset) - 348;
else
    skip_bytes = 0;
end

if double(hdr.dime.datatype) == 128
    
    %  RGB planes are expected to be in the 4th dimension of nii.img
    %
    if(size(nii.img,4)~=3)
        error(['The NII structure does not appear to have 3 RGB color planes in the 4th dimension']);
    end
    
    nii.img = permute(nii.img, [4 1 2 3 5 6 7 8]);
end

%  For complex float32 or complex float64, voxel values
%  include [real, imag]
%
if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792
    real_img = real(nii.img(:))';
    nii.img = imag(nii.img(:))';
    nii.img = [real_img; nii.img];
end

% if skip_bytes
%     fwrite(fid, zeros(1,skip_bytes), 'uint8');
% end

if strcmpi(precision, 'float32') == 1
    precision_mat = 'single';
elseif strcmpi(precision, 'float64') == 1
    precision_mat = 'double';
else
    precision_mat = precision;
end
    
[pth, fn, fnext] = brant_fileparts(fileprefix);
if filetype == 2 % strcmpi(fnext, '.nii') || strcmp(fnext, '.nii.gz')
    if skip_bytes == 0
        foptgz(fileprefix, 'ab', {precision}, {uint32(numel(nii.img))}, uint32(0), {cast(nii.img, precision_mat)});
    else
        foptgz(fileprefix, 'ab', {'uint8', precision}, {uint32(4), uint32(numel(nii.img))}, [uint32(0), uint32(0)], {zeros(1, skip_bytes, 'uint8'), cast(nii.img, precision_mat)});
    end
else
    if strcmp(fnext, '.hdr') || strcmp(fnext, '.hdr.gz')
        fileprefix = fullfile(pth, [fn, strrep(fnext, '.hdr', '.img')]);
    elseif strcmp(fnext, '.HDR') || strcmp(fnext, '.HDR.GZ')
        fileprefix = fullfile(pth, [fn, strrep(fnext, '.HDR', '.IMG')]);
    end
    
    foptgz(fileprefix, 'wb', {precision}, {uint32(numel(nii.img))}, uint32(0), {cast(nii.img, precision_mat)});
end
% fwrite(fid, nii.img, precision);
% %   fwrite(fid, nii.img, precision, skip_bytes);        % error using skip
% fclose(fid);

return;					% write_nii

