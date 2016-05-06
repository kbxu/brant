function [ERN] = brant_rand_symDegreeDistribution(symMatrix,Time)
% describe
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% FORMAT function brant_simu_symDegreeDistribution(symMatrix,Time)
% input symMatrix  --- Symmetry binary connect matrix
%       Time --- the simulate times %% default time is size(Matrix,1);
% Output ERN ---- Rand network has the same degree distribution with Matrix
%       
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu, Oct,2007
% Brainnetome Center
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn 
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007, 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also  Span_Simu_symRand

if nargin < 1
    error('two arguments are required.');
elseif nargin == 1
    Time = size(symMatrix,1);
elseif nargin == 2
    %% do nothing
else
    error('pls check your input');
end
%%%%%% if the size of symmatrix is small maybe it can not be change so many
%%%%%% time so that the program will in the circulation for ever
if size(symMatrix,1)<10
    Time = floor(size(symMatrix,1)/2-2)
end
%%%%
Temp = brant_randperm(symMatrix);
for i = 1:Time
%     i
    [ERN] = brant_simu_symRand(Temp);
    Temp = brant_randperm(ERN);
end
