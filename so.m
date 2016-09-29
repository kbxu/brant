function so(cmd)
% system open
% cmd can either be a path or a command in matlab search path
% kb on 20150417

% seems a little buggy on linux mint18
linux_f_browser = {'caja',...   %Mate
                   'nemo',...   %Cinnamon
                   'thunar',... %xfce
                   'KDE',...    %dolphin
                   'nautilus'}; %ubuntu and mac maybe?

if (exist(cmd, 'file') == 2)
    pth = fileparts(which(cmd));
    if (exist(pth, 'dir') ~= 7)
        error('Path not found!');
    end
elseif ((any(cmd == '.') && (length(cmd) <= 2)) || (exist(cmd, 'dir') == 7))
    pth = cmd;
end

switch(computer)
    case {'PCWIN64', 'PCWIN'}
        cmd_str = ['explorer', 32, pth];
    case {'GLNXA64', 'MACI64'}
        chk_cmd = cellfun(@(x) system(['which', 32, x]), linux_f_browser);
        cmd_ind = find(chk_cmd == 0, 1);
        if ~isempty(cmd_ind)
            cmd_str = [linux_f_browser{cmd_ind}, 32, pth];
        else
            error('Unknown file broswer!');
        end
    otherwise
        error('oooooOperation system not recognized!ooooo');
end

system(cmd_str);