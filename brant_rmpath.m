function brant_rmpath

brant_path = fileparts(which(mfilename));
rmpath(genpath(brant_path));
savepath;
