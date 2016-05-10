function [tMatrix, zScore] = img2times(theDir, Mask, roi)
%img2times  tranforms {*.img,*.hdr} to a time series matrix, and compute 
%           z-score of rois.
%	theDir	directory of data files
%	Mask	the mask file name
%	roi     'AAL'(128 regions,default) have two-mode, 3x3x3 and 2x2x2,
%            or a txt-file listing ROI {*.img,*.hdr} file name.
%
%   tMatrix size TxN, where T is the time point, N is the number of roi
%	zScore 	z-score
%Write by Hu Yong, 2011-Mar-2
% See also fReadImg, fastcorr

if(nargin < 3),   roi = 'AAL';   N = 116;   end
if(~strcmpi(roi, 'AAL')),
try% Check roi is defined by user or not
	fid = fopen(roi);
	roiList = {};
	while(~feof(fid))
		theLine = strtrim(fgetl(fid));%Get a line & deblank
        if(isempty(theLine)),  continue;  end
        if(exist(theLine,'file'))%Check existence of file
			roiList = [roiList; theLine];
		else
			fprintf('WARNING: file doesn''t exist.\n');
		end
    end
    N = size(roiList,1);	roi = 'Define';
catch
	error(sprintf('Please input a valid ROI-list or use the default AAL.\n'));
end
end


filelist = dir(fullfile(theDir, '*.hdr'));%List the hdr-file
T        = size(filelist, 1);%length of time points
if(T == 0),     
	error(sprintf('No file in %s.\n', theDir));
elseif(T <= 10) 
	fprintf('WARNING: time point is too short.\n');   
end

%[outdata, voxdim]   = fReadImg(fullfile(theDir, filelist(1).name));
[Maskdata, Maskdim] = fReadImg(Mask);%Get the size of data

% Transform to 4D-matrix (Maybe show information -- Out of memory)
to4Dmat  = zeros([size(Maskdata),T]);
for(i = 1:T)
	[outdata, voxdim] = fReadImg(fullfile(theDir,filelist(i).name));
	if(~isequal(voxdim,Maskdim))%Check the size  
		fprintf('Mask''s voxel size doesn''t match with the img data: %s.\n',filelist{i}); 
		error('Input error');
	end
	to4Dmat(:,:,:,i) = outdata.*Maskdata;
end


% Construct time series
tMatrix = zeros(T,N);
switch(upper(roi))
case 'DEFINE'%User defined
for(i = 1:N)
	roiVox   = findVoxel(fReadImg(roiList{i}));
	n_roiVox = size(roiVox,1);
	if(n_roiVox == 0), 
		fprintf('number of voxels in roi = 0\n');
		tMatrix(:,i) = 0;   continue;
	end
	
	% Note: function MEAN/SUM has size limit!
	for(j = 1:n_roiVox)
		tMatrix(:,i) = tMatrix(:,i) + squeeze(to4Dmat(roiVox(j,1),roiVox(j,2),roiVox(j,3),:));
	end
	tMatrix(:,i) = tMatrix(:,i)/n_roiVox;
end

case 'AAL'%Default
% Load AAL ROI (Name & ID) matrix - (AreaName,VoxelID)
P = fileparts(which('data_declar.m'));%Find the path

if(isequal(Maskdim, [2,2,2]')), %2x2x2 AAL
	load(fullfile(P, 'AAL_ROI_2.mat'));
elseif(isequal(Maskdim, [3,3,3]')), %3x3x3 AAL
	load(fullfile(P, 'AAL_ROI_3.mat'));
else	
    error('There are just have two-format AAL (2x2x2 & 3x3x3).');   
end

for(i = 1:N)
	roiVox   = VoxelID{i};   n_roiVox = size(roiVox,1);
	if(n_roiVox == 0), 
		fprintf('number of voxels in roi = 0\n');
		tMatrix(:,i) = 0;   continue;
	end
	
	% Note: function MEAN/SUM has size limit!
	for(j = 1:n_roiVox)
		tMatrix(:,i) = tMatrix(:,i) + squeeze(to4Dmat(roiVox(j,1),roiVox(j,2),roiVox(j,3),:));
	end
	tMatrix(:,i) = tMatrix(:,i)/n_roiVox;
end
end

% Calculate correlation
pcorr = fastcorr(tMatrix);%The same as function corr()
zScore = log((1+pcorr)./(1-pcorr))/2;%Fisher's Z transformation
zScore(1:(N+1):end) = 1;%Values on diagonal line are 0

	
function vox = findVoxel(data)
%findVoxel finds the index of non-zeros
% data is a 3-D data
% vox  is a  Nx3 array

N   = nnz(data);
vox = zeros(N,3);   pt  = 0;
for i = 1:size(data,3)
	[I,J] = find(data(:,:,i));   ptadd = size(I,1);%Increment of pt
    vox(pt+1 : pt+ptadd,:) = cat(2,I,J,i*ones(ptadd,1));
    pt = pt + ptadd;
end