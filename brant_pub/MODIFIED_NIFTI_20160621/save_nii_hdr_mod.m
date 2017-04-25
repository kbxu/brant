function save_nii_hdr_mod(hdr, fileprefix, touch_opt)

if ~isequal(hdr.hk.sizeof_hdr,348)
    error('hdr.hk.sizeof_hdr must be 348.');
end

% only for save_nii_mod
if strcmpi(touch_opt, 'touch')
    if hdr.hist.qform_code == 0 && hdr.hist.sform_code == 0
        originator = single(hdr.hist.originator);
        hdr.hist.sform_code = 1;
        hdr.hist.srow_x(1) = hdr.dime.pixdim(2);
        hdr.hist.srow_x(2) = 0;
        hdr.hist.srow_x(3) = 0;
        hdr.hist.srow_y(1) = 0;
        hdr.hist.srow_y(2) = hdr.dime.pixdim(3);
        hdr.hist.srow_y(3) = 0;
        hdr.hist.srow_z(1) = 0;
        hdr.hist.srow_z(2) = 0;
        hdr.hist.srow_z(3) = hdr.dime.pixdim(4);
        hdr.hist.srow_x(4) = (1-originator(1))*hdr.dime.pixdim(2);
        hdr.hist.srow_y(4) = (1-originator(2))*hdr.dime.pixdim(3);
        hdr.hist.srow_z(4) = (1-originator(3))*hdr.dime.pixdim(4);
    end
end

[pth, fn, ext] = brant_fileparts(fileprefix);
if strcmp(ext, '.img') || strcmp(ext, '.img.gz')
    fileprefix = fullfile(pth, [fn, strrep(ext, '.img', '.hdr')]);
elseif strcmp(ext, '.IMG') || strcmp(ext, '.IMG.GZ')
    fileprefix = fullfile(pth, [fn, strrep(ext, '.IMG', '.HDR')]);
end

num_items = 43;
% no originator
offset_ele = zeros(1, num_items, 'uint32');
% offset_ele(end) = 253;
num_ele = num2cell(uint32([1, 10, 18, 1, 1, 1, 1,...
    8, 1, 1, 1, 1, 1, 1, 1, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    80, 24, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 16, 4,...
    ]));
type_ele = ['int32', 'uint8', 'uint8', 'int32', 'int16', 'uint8', 'uint8',...
    'int16', 'float32', 'float32', 'float32', 'int16', 'int16', 'int16', 'int16', 'float32', 'float32', 'float32', 'float32', 'int16', 'uint8', 'uint8', 'float32', 'float32', 'float32', 'float32', 'int32', 'int32',...
    'uint8', 'uint8', 'int16', 'int16', repmat({'float32'}, 1, 9), 'uint8', 'uint8',...
    ];
type_matlc = cellfun(@(x) strrep(strrep(x, 'float32', 'single'), 'float64', 'double'), type_ele, 'UniformOutput', false);
% zero padding
hdr.hk.data_type = [cast(hdr.hk.data_type, 'uint8'), zeros(1, 10-length(hdr.hk.data_type), 'uint8')];
hdr.hk.db_name = [cast(hdr.hk.db_name, 'uint8'), zeros(1, 18-length(hdr.hk.db_name), 'uint8')];
hdr.hk.regular = cast(hdr.hk.regular, 'uint8')';
% hdr.hk.dim_info = cast(hdr.hk.dim_info, 'uint8')';

hdr.hist.descrip = [cast(hdr.hist.descrip, 'uint8'), zeros(1, 80-length(hdr.hist.descrip), 'uint8')];
hdr.hist.aux_file = [cast(hdr.hist.aux_file, 'uint8'), zeros(1, 24-length(hdr.hist.aux_file), 'uint8')];
hdr.hist.intent_name = [cast(hdr.hist.intent_name, 'uint8'), zeros(1, 16-length(hdr.hist.intent_name), 'uint8')];
hdr.hist.magic = [cast(hdr.hist.magic, 'uint8'), zeros(1, 4-length(hdr.hist.magic), 'uint8')];

hk_fields = {'sizeof_hdr', 'data_type', 'db_name', 'extents', 'session_error', 'regular', 'dim_info'};
dim_fields = {'dim', 'intent_p1', 'intent_p2', 'intent_p3', 'intent_code', 'datatype', 'bitpix', 'slice_start', 'pixdim', 'vox_offset', 'scl_slope', 'scl_inter', 'slice_end', 'slice_code', 'xyzt_units', 'cal_max', 'cal_min', 'slice_duration', 'toffset', 'glmax', 'glmin'};
hist_fields = {'descrip', 'aux_file', 'qform_code', 'sform_code', 'quatern_b', 'quatern_c', 'quatern_d', 'qoffset_x', 'qoffset_y', 'qoffset_z', 'srow_x', 'srow_y', 'srow_z', 'intent_name', 'magic'};

hdr_vals = cell(num_items, 1);
for m = 1:numel(hk_fields)
    hdr_vals{m} = cast(hdr.hk.(hk_fields{m}), type_matlc{m});
end
for m = 1:numel(dim_fields)
    hdr_vals{m+7} = cast(hdr.dime.(dim_fields{m}), type_matlc{m+7});
end
for m = 1:numel(hist_fields)
    hdr_vals{m+28} = cast(hdr.hist.(hist_fields{m}), type_matlc{m+28});
end
% hdr_vals{end} = hdr.hist.originator;
foptgz(fileprefix, 'wb', type_ele, num_ele, offset_ele, hdr_vals);





