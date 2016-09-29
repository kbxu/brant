function [XYZ, s_mat] = brant_get_XYZ(mask_hdr)
% brant_get_XYZ.m can ONLY be used when image header is loaded by load_nii.m!
% assumes s_mat is in accordance with nifti data loaded by load_nii
% with left in left side

% if isfield(mask_hdr, 'untouch') == 1
%     if mask_hdr.untouch == 1
%         error('brant_get_XYZ.m can only be used when image header is loaded by load_nii.m!');
%     end
% end

size_mask = mask_hdr.dime.dim(2:4);
s_mat = [mask_hdr.hist.srow_x; mask_hdr.hist.srow_y; mask_hdr.hist.srow_z];
if (s_mat(1, 1) < 0)
    s_mat(1, :) = s_mat(1, :) * -1;
end
[R,C,P]  = ndgrid(1:size_mask(1),1:size_mask(2),1:size_mask(3));
RCP      = [R(:)'; C(:)'; P(:)'] - 1;
clear R C P
RCP(4,:) = 1;
XYZ = (s_mat * RCP)';
