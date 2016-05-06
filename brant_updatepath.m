function brant_updatepath(locpath)
%UPDATEPATH
%       Function adds subdirectories to the local or current path
%       Input:   path to the directories that should be added.
%
%       eg.		 updatepath('c:\matlab\files') will add input path 
%                recursively.
%   Creat:   Hu Yong, 2011-03-03
%   Revised: 2011-06-10

if(nargin < 1)
	locpath = fileparts(which('brant'));
    if isempty(locpath)
        locpath = pwd;
    end
end

addpath(genpath(locpath));
savepath;
fprintf('\tPath updated!\n');
