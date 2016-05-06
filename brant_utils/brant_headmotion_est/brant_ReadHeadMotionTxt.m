function [HeadMotion] = brant_ReadHeadMotionTxt(filename)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% describe of the function
% read the head motion txt file titled by filename
% Y is the matrix of the parameters of head motion
% the 1st, 2nd and 3rd columns are the translation parameters in x, y and
% z direction (in mm), respectively;
% the 4th, 5th and 6th columns are the rotate parameters around 3
% directions (in degree), respectively.

% FORMAT function [HeadMotion] = Span_ReadHeadMotionTXT(filename)
% input filename--- the name of the rp*.txt generated from the realign step of preprocessing

% output HeadMotion--- the Headmotion Matrix 
%      

% Refer: 


% Written by Yong Liu, Oct,2007
% Center for Computational Medicine (CMC), 
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn 
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007, 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
fid = fopen(filename, 'rt');
if fid == -1
    err = strcat('can not open ', filename);
    error(err);
end

HeadMotion = fscanf(fid,'%f');

status = fclose(fid);
if status == -1
    err = strcat('can not close ',filename);
    error(err);
end

numcol = 6;%%% the default value is 6
numrow = length(HeadMotion) / numcol;
B = reshape(HeadMotion, [numcol, numrow]);
HeadMotion = B';
% HeadMotion(:, 4:6) = HeadMotion(:, 4:6) * (180 / pi);
