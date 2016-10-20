function brant_updatepath

brant_path = fileparts(which(mfilename));
addpath(genpath(brant_path));
savepath;
fprintf('\tPath updated!\n');
