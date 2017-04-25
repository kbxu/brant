function tps = brant_get_nii_frame(fn)

hdr = load_nii_hdr_mod(fn, 'untouch0');
% hdr = load_nii_hdr_img_raw_c(fn);
tps = hdr.dime.dim(5);