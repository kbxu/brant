function [outdata, voxdim] = fReadImg(filename)
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Read analyze format file.
% FORMAT function [outdata,voxdim] = fReadImg(filename)
%                 filename - Analyze file (*.{hdr, img})
%                 outdata  - data file.                            
%                 voxdim   - the size of the voxel.
%
% Written by Yong He, April,2004
% Medical Imaging and Computing Group (MIC), 
% National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yhe@nlpr.ia.ac.cn
% Copywrite (c) 2004
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Last Modified by Hu Yong, 01-Mar-2011
% See also fReadNii


% Remove file extension if exists, and check exsitance of pairs
[pathstr, name] = fileparts(deblank(filename));%Separation
filename = fullfile(pathstr,name);
if(~exist([filename,'.img'],'file') | ~exist([filename,'.hdr'],'file'))
    error('*.{hdr,img} should be pairwise.');
end

% Open *.hdr file
byte_type = {'native','ieee-be','ieee-le','s'};     
bn = 1;     fid = 1;
while(fid > 0 & bn < 4) %When bn = 3, "if-else-end" is redundant, but need. 
    fid = fopen([filename,'.hdr'],'r');  
    byteswap = byte_type{bn};  bn = bn + 1;
    fseek(fid, 40, 'bof');  dim = fread(fid,8,'int16');
    if(dim(1) > 15 | dim(1) < 0)
         fclose(fid);     
         fid = fopen([filename,'.hdr'],'r',byte_type{bn});
    else
        break;    
    end
end
if(fid < 0),  error('Error opening header file');  end

fseek(fid, 40+30, 'bof');  dataType = fread(fid, 1, 'int16');
fseek(fid, 40+36, 'bof');  voxdim   = fread(fid, 8, 'float');
fseek(fid, 40+72, 'bof');  scale    = fread(fid, 1, 'float');
fclose(fid);

% Open *.img file
fid = fopen([filename,'.img'],'r',byteswap);
if(fid < 0),   error('Error opening data file');  end

switch(dataType)
case 2,    dtype = 'uint8';
case 4,    dtype = 'int16';
case 8,    dtype = 'int32';
case 16,   dtype = 'float';
case 32,   dtype = 'float32';
case 64,   dtype = 'double';
otherwise, error('Invalid data type!');
end

% Output matrix
switch(dim(1))
case 4
	len = dim(2)*dim(3)*dim(4)*dim(5);  outdata = fread(fid,len,dtype);
	if(dim(5) == 1),  outdata = reshape(outdata,dim(2),dim(3),dim(4));      
    else              outdata = reshape(outdata,dim(2),dim(3),dim(4),dim(5));end
case 3
	len = dim(2)*dim(3)*dim(4);  outdata = fread(fid,len,dtype);
    outdata = reshape(outdata,dim(2),dim(3),dim(4));    
end
fclose(fid);

if(scale ~= 1 & scale ~= 0),  outdata = scale*outdata;  end
voxdim = voxdim(2:4);
%%%