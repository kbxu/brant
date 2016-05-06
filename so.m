function so(cmd)
% system open
% cmd can either be a path or a command in matlab search path
% kb on 20150417

if exist(cmd, 'file') == 2
    pth = fileparts(which(cmd));
    if exist(pth, 'dir') ~= 7
        error('Path not found!');
    end
elseif (any(cmd == '.') && length(cmd) <= 2) || exist(cmd, 'dir') == 7
    pth = cmd;
end

switch(computer)
    case {'PCWIN64', 'PCWIN'}
        cmd_str = ['explorer', 32, pth];
    case {'GLNXA64', 'MACI64'}
        cmd_str = ['nautilus', 32, pth];
    otherwise
        error('oooooOperation system not recognized!ooooo');
end

system(cmd_str);