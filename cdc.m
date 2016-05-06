function cdc(cmd)
%   %   %   %   %   %   %   %   %   %   %   %   %   %   %   %
%   Change working current folder to the folder where the   %
%   specifid command file exists.                           %
%   Last modified at 16:73 18-Sep-2013            %
%   %   %   %   %   %   %   %   %   %   %   %   %   %   %   %
cmd_pth = which(cmd);

if ~isempty(cmd_pth)
    filepath = strcat(fileparts(cmd_pth),'/'); % '\' doesn't work in linux
    cd(filepath);
else
    error('%s not found!', cmd);
end