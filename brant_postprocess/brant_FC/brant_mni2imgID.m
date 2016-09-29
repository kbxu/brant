function [imgID] = brant_mni2imgID(Coordinate, V_mat)
% transform the MNI coordinate to voxel ID
% voxel_size = 3 x 3 x 3 mm
% BB = 1 : the bounding box is [61 73 61], i.e. [-90:90 -126:90 -72:108]
% if nargin <=2
%     BB=1;
% end
[m, n] = size(Coordinate);
if (m == 3) && (n ~= 3)
    Coordinate = Coordinate';
elseif (m ~= 3) && (n ~= 3)
    error('wrong matrix of Coordinate');
end

imgID = (Coordinate - [V_mat(1, 4), V_mat(2, 4), V_mat(3, 4)]) ./ [V_mat(1, 1), V_mat(2, 2), V_mat(3, 3)];

% temp = abs(round(imgID) - imgID);
% if any(temp)
%     fprintf('\tThere exists non-integer VoxelID\n');
% end

imgID = round(imgID);
