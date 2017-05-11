function [hdr, filetype, fileprefix, machine] = load_nii_hdr_mod(fileprefix, touch_opt)
% fileprefix: full path of input filename
% header information includes 44 parameters
% if from element i offset vector becomes non-zero, the elements after should also be!
% to be compatible with load_nii
% can be replaced with load_nii_hdr
% touch_opt: 'touch' or 'untouch'
% Written by Kaibin XU 2017/04/12
   
[pth, fn, ext] = brant_fileparts(fileprefix);
% fileprefix = fn;
if strcmp(ext, '.img') || strcmp(ext, '.img.gz')
    fileprefix = fullfile(pth, [fn, strrep(ext, '.img', '.hdr')]);
elseif strcmp(ext, '.IMG') || strcmp(ext, '.IMG.GZ')
    fileprefix = fullfile(pth, [fn, strrep(ext, '.IMG', '.HDR')]);
end

machine = 'ieee-le';
offset_ele = zeros(1, 44, 'uint32');
offset_ele(end) = 253;
num_ele = cellfun(@(x) uint32(x),...
           {1, [1, 10], [1, 18], 1, 1, 1, 1,...
           [1, 8], 1, 1, 1, 1, 1, 1, 1, [1, 8], 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
           [1, 80], [1, 24], 1, 1, 1, 1, 1, 1, 1, 1, [1, 4], [1, 4], [1, 4], [1, 16], [1, 4],...
           [1, 5]}, 'UniformOutput', false);
type_ele = ['int32', 'uchar', 'uchar', 'int32', 'int16', 'uchar', 'uint8',...
            'int16', 'float32', 'float32', 'float32', 'int16', 'int16', 'int16', 'int16', 'float32', 'float32', 'float32', 'float32', 'int16', 'uchar', 'uchar', 'float32', 'float32', 'float32', 'float32', 'int32', 'int32',...
            'uchar', 'uchar', 'int16', 'int16', repmat({'float32'}, 1, 9), 'uchar', 'uchar',...
            'int16'];

hdr_vals = foptgz(fileprefix, 'rb', type_ele, num_ele, offset_ele)';

hk_fields = {'sizeof_hdr', 'data_type', 'db_name', 'extents', 'session_error', 'regular', 'dim_info'};
dim_fields = {'dim', 'intent_p1', 'intent_p2', 'intent_p3', 'intent_code', 'datatype', 'bitpix', 'slice_start', 'pixdim', 'vox_offset', 'scl_slope', 'scl_inter', 'slice_end', 'slice_code', 'xyzt_units', 'cal_max', 'cal_min', 'slice_duration', 'toffset', 'glmax', 'glmin'};
hist_fields = {'descrip', 'aux_file', 'qform_code', 'sform_code', 'quatern_b', 'quatern_c', 'quatern_d', 'qoffset_x', 'qoffset_y', 'qoffset_z', 'srow_x', 'srow_y', 'srow_z', 'intent_name', 'magic'};

for m = 1:numel(hk_fields)
    hdr.hk.(hk_fields{m}) = double(hdr_vals{m});
end
hdr.hk.data_type = deblank(cast(hdr.hk.data_type, 'char'));
hdr.hk.db_name = deblank(cast(hdr.hk.db_name, 'char'));
hdr.hk.regular = cast(hdr.hk.regular, 'char');

for m = 1:numel(dim_fields)
    hdr.dime.(dim_fields{m}) = double(hdr_vals{m+7});
end
    
for m = 1:numel(hist_fields)
    hdr.hist.(hist_fields{m}) = double(hdr_vals{m+28});
end
hdr.hist.descrip = deblank(cast(hdr.hist.descrip, 'char'));
hdr.hist.aux_file = deblank(cast(hdr.hist.aux_file, 'char'));
hdr.hist.intent_name = deblank(cast(hdr.hist.intent_name, 'char'));
hdr.hist.magic = deblank(cast(hdr.hist.magic, 'char'));

if ~strcmpi(touch_opt, 'untouch0')
    %  For Analyze data format
    if ~strcmp(hdr.hist.magic, 'n+1') && ~strcmp(hdr.hist.magic, 'ni1')
        hdr.hist.qform_code = 0;
        hdr.hist.sform_code = 0;
    end
end

if strcmp(hdr.hist.magic, 'n+1')
    filetype = 2; % nii and nii.gz
elseif strcmp(hdr.hist.magic, 'ni1')
    filetype = 1; % img/hdr pairs
else
    filetype = 0;
end

if strcmpi(touch_opt, 'touch')
    hdr.hist.originator = cast(hdr_vals{end}, 'double');
end