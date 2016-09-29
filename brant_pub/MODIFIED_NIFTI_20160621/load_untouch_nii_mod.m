%  Load NIFTI or ANALYZE dataset. Support both *.nii and *.hdr/*.img
%  file extension. If file extension is not provided, *.hdr/*.img will
%  be used as default.
%
%  A subset of NIFTI transform is included. For non-orthogonal rotation,
%  shearing etc., please use 'reslice_nii.m' to reslice the NIFTI file.
%  It will not cause negative effect, as long as you remember not to do
%  slice time correction after reslicing the NIFTI file. Output variable
%  nii will be in RAS orientation, i.e. X axis from Left to Right,
%  Y axis from Posterior to Anterior, and Z axis from Inferior to
%  Superior.
%
%  Usage: nii = load_untouch_nii_mod(filename, [img_idx])
%
%  filename  - 	NIFTI or ANALYZE file name.
%
%  img_idx (optional)  -  a numerical array of 4th dimension indices,
%	which is the indices of image scan volume. The number of images
%	scan volumes can be obtained from get_nii_frame.m, or simply
%	hdr.dime.dim(5). Only the specified volumes will be loaded.
%	All available image volumes will be loaded, if it is default or
%	empty.
%
%  tolerance (optional) - distortion allowed in the loaded image for any
%	non-orthogonal rotation or shearing of NIfTI affine matrix. If
%	you set 'tolerance' to 0, it means that you do not allow any
%	distortion. If you set 'tolerance' to 1, it means that you do
%	not care any distortion. The image will fail to be loaded if it
%	can not be tolerated. The tolerance will be set to 0.1 (10%), if
%	it is default or empty.
%
%  preferredForm (optional)  -  selects which transformation from voxels
%	to RAS coordinates; values are s,q,S,Q.  Lower case s,q indicate
%	"prefer sform or qform, but use others if preferred not present".
%	Upper case indicate the program is forced to use the specificied
%	tranform or fail loading.  'preferredForm' will be 's', if it is
%	default or empty.	- Jeff Gunter
%
%  Returned values:
%
%  nii structure:
%
%	hdr -		struct with NIFTI header fields.
%
%	filetype -	Analyze format .hdr/.img (0);
%			NIFTI .hdr/.img (1);
%			NIFTI .nii (2)
%
%	fileprefix - 	NIFTI filename without extension.
%
%	machine - 	machine string variable.
%
%	img - 		3D (or 4D) matrix of NIFTI data.
%
%  Part of this file is copied and modified from:
%  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function nii = load_untouch_nii_mod(filename, img_idx)

% if strcmpi(filename(end-2:end), 'img') == 1 %ismac == 1
%     nii = load_untouch_nii(filename, img_idx);
%     return;
% end

if ~exist('filename','var')
    error('Usage: nii = load_untouch_nii_mod(filename, [img_idx])');
end

if ~exist('img_idx','var') || isempty(img_idx)
    img_idx = [];
end

img_idx = double(img_idx);

%  new load header and image
[nii.hdr, img] = load_nii_hdr_img_raw_c(filename, img_idx);
nii.machine = 'ieee-le';

[pth, fileprefix] = brant_fileparts(filename);
nii.fileprefix = fullfile(pth, fileprefix);

nii.hdr.dime.dim = double(nii.hdr.dime.dim);
% if ~strcmp(nii.hdr.hist.magic, 'n+1') && ~strcmp(nii.hdr.hist.magic, 'ni1')
%     nii.hdr.hist.qform_code = 0;
%     nii.hdr.hist.sform_code = 0;
% end

if strcmp(nii.hdr.hist.magic, 'n+1')
    nii.filetype = 2;
elseif strcmp(nii.hdr.hist.magic, 'ni1')
    nii.filetype = 1;
else
    nii.filetype = 0;
end

[nii.img, nii.hdr] = load_nii_img_mod(nii.hdr,img,img_idx);

nii.hdr.hist = rmfield(nii.hdr.hist, 'originator');

%  Perform some of sform/qform transform
% nii = xform_nii(nii, tolerance, preferredForm);
nii.untouch = 1;
nii.ext = [];

fields_org = {'hdr', 'filetype', 'fileprefix', 'machine', 'ext', 'img', 'untouch'};
nii = orderfields(nii, fields_org);

%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
% cut off support for RGB and dimension higher than 4
function [img,hdr] = load_nii_img_mod(hdr,img,img_idx)

if ~exist('img_idx','var') || isempty(img_idx) || (hdr.dime.dim(5)<1)
    img_idx = [];
end

if ~isempty(img_idx) && ~isnumeric(img_idx)
    error('"img_idx" should be a numerical array.');
end

if length(unique(img_idx)) ~= length(img_idx)
    error('Duplicate image index in "img_idx"');
end

if ~isempty(img_idx) && (min(img_idx) < 1 || (max(img_idx) > hdr.dime.dim(5)))
    max_range = hdr.dime.dim(5);
    
    if max_range == 1
        error(['"img_idx" should be 1.']);
    else
        range = ['1 ' num2str(max_range)];
        error(['"img_idx" should be an integer within the range of [' range '].']);
    end
end

[img,hdr] = read_image_mod(hdr,img,img_idx);


%---------------------------------------------------------------------
function [img,hdr] = read_image_mod(hdr,img,img_idx)
%  Set bitpix according to datatype
%
%  /*Acceptable values for datatype are*/
%
%     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN
%     1 Binary                         (ubit1, bitpix=1) % DT_BINARY
%     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8
%     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16
%     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32
%    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32
%    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
%    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64
%   128 uint8 RGB                 (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24
%   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8
%   511 Single RGB              (Use float32, bitpix=96) % DT_RGB96, NIFTI_TYPE_RGB96
%   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16
%   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32
%  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
%  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64
%  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128
%  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
%  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
%
switch hdr.dime.datatype
    case   1,
        hdr.dime.bitpix = 1;  precision = 'ubit1';
    case   2,
        hdr.dime.bitpix = 8;  precision = 'uint8';
    case   4,
        hdr.dime.bitpix = 16; precision = 'int16';
    case   8,
        hdr.dime.bitpix = 32; precision = 'int32';
    case  16,
        hdr.dime.bitpix = 32; precision = 'float32';
    case  32,
        hdr.dime.bitpix = 64; precision = 'float32';
    case  64,
        hdr.dime.bitpix = 64; precision = 'float64';
    case 128,
        hdr.dime.bitpix = 24; precision = 'uint8';
    case 256
        hdr.dime.bitpix = 8;  precision = 'int8';
    case 511
        hdr.dime.bitpix = 96; precision = 'float32';
    case 512
        hdr.dime.bitpix = 16; precision = 'uint16';
    case 768
        hdr.dime.bitpix = 32; precision = 'uint32';
    case 1024
        hdr.dime.bitpix = 64; precision = 'int64';
    case 1280
        hdr.dime.bitpix = 64; precision = 'uint64';
    case 1792,
        hdr.dime.bitpix = 128; precision = 'float64';
    otherwise
        error('This datatype is not supported');
end

hdr.dime.dim(hdr.dime.dim < 1) = 1;

if isempty(img_idx)
    img_idx = 1:hdr.dime.dim(5);
end

% img = img(:, :, :, img_idx);

hdr.dime.glmax = double(max(img(:)));
hdr.dime.glmin = double(min(img(:)));

if ~isempty(img_idx)
    hdr.dime.dim(5) = length(img_idx);
end