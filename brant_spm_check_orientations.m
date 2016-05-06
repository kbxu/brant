function sts = brant_spm_check_orientations(V)
% only check for dimensions, header must be loaded by load_nii

% Check the dimensions and orientations of the images
% FORMAT sts = spm_check_orientations(V)
%
% V    - a struct array as returned by spm_vol
% sts  - status (true means OK)
%
% When used without LHS, this function throws an error accordingly.
%__________________________________________________________________________
% Copyright (C) 2005-2011 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_check_orientations.m 4199 2011-02-10 20:07:17Z guillaume $

sts = true;

if numel(V) <= 1 || isa(V,'gifti'), return; end

V_info = struct;
for m = 1:numel(V)
    V_info(m).dim = V(m).dime.dim(2:4);
    V_info(m).pixdim = V(m).dime.pixdim(2:4);
end


dims = cat(1,V_info.dim);
if any(any(diff(dims,1,1),1))
    sts = false;
    fprintf('\n    ** The images do not all have the same dimensions. **\n');
    fprintf('The function assumes that a voxel in one image corresponds with\n');
    fprintf('the same  voxel in another.   This  is not a safe assumption if\n');
    fprintf('the  image dimensions differ.   Please  ensure  that  you  have\n');
    fprintf('processed all the image data in the same way (eg. check spatial\n');
    fprintf('normalisation bounding-boxes, voxel-sizes etc).\n');
    fprintf('Here are the dimensions of the image volumes.  This list can be\n');
    fprintf('used to determine which file(s) are causing the problem.\n\n');
    for i=1:numel(V_info)
        fprintf('[%d %d %d]\n',V_info(i).dim);
    end
    fprintf('\n');
    if ~nargout, error('The dimensions must be identical for this procedure.'); end
end

pixdims = cat(1,V_info.pixdim);
if any(any(diff(pixdims,1,1),1))
    sts = false;
    fprintf('\n    ** The images do not all have the same bounding boxes. **\n');
    for i=1:numel(V_info)
        fprintf('[%d %d %d]\n',V_info(i).pixdim);
    end
    fprintf('\n');
    if ~nargout, error('The bounding box must be identical for this procedure.'); end
end








% matx = reshape(cat(3,V.mat),[16,numel(V)]);
% if any(any(abs(diff(matx,1,2))>1e-4))
%     sts = false;
%     fprintf('\n** The images do not all have same orientation and/or voxel sizes. **\n');
%     fprintf('The function assumes that a voxel in one image  corresponds exactly\n');
%     fprintf('with  the same voxel in another.   This is not a safe assumption if\n');
%     fprintf('the orientation information  in the headers or .mat files says that\n');
%     fprintf('the images are oriented differently. Please ensure that you process\n');
%     fprintf('all data correctly. For example, you may have realigned the images,\n');
%     fprintf('but not actually resliced them to be in voxel-wise alignment.\n');
%     fprintf('Here are the orientation matrices of the image volumes.   This list\n');
%     fprintf('can be used to determine which file(s) are causing the problem.\n\n');
%     for i=1:numel(V)
%         fprintf('[%g %g %g %g; %g %g %g %g; %g %g %g %g]  %s\n',...
%                 V(i).mat(1:3,:)', V(i).fname);
%     end
%     fprintf('\n');
%     if ~nargout, error('The orientations etc must be identical for this procedure.'); end
% end
