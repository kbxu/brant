function [sData,site] = CCM_TestGraph2(input_type)
% CCM_TestGraph2 generated a test graph, which with 20 nodes,41 edges.
% Input:
%	input_type	   no-input or any other strings will draw figure as output
%                  'nograph' represents only data,and don't draw figure
% Usage:
%   sData = CCM_TestGraph2('nograph') 
%   sData = CCM_TestGraph2 returns symmetric adjacent matrix sData
%   [sDatam,site] = CCM_TestGraph2('nograph') returns the coordinate of nodes
% Example:
%	sData = CCM_TestGraph2('nograph');
%   [sData,site] = CCM_TestGraph2;
% Refer:
%   Original graph please see,
%   M.E.J.Newman  Modularity and community structure in networks
% See also CCM_TestGraph,CCM_TestGraph1

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010
%%

error(nargchk(0,1,nargin,'struct'));
if(nargin < 1), 	input_type = 'figure';   end

flag = strncmpi(input_type,'nograph',2);

%% Generated a adjancency matrix
sData = zeros(20);
con   = [1 1 1 1 1 1 1 2 2 2 2 3 3 4 5 5 8 8 8 9 9 9 10 11 11 ...
         12 13 13 13 14 14 14 15 15 16 16 16 17 17 18 18;...
         2 3 4 5 6 7 15 3 4 6 7 5 8 5 6 13 9 10 12 10 11 ...
         12 12 12 19 14 14,15,20 15,19,20 17,20 17,19,20 18,20 19,20];
for i = 1:size(con,2)
    sData(con(1,i),con(2,i)) = 1;
end
sData = sData + sData';

%% Generated coordinate of nodes
site  = zeros(2,20);
Theta = linspace(0,2*pi,8);
site(:,1)     = [11;12];
site(:,2:7)   = site(:,1)*ones(1,6) + 3*[cos(-Theta(1:6)+2*pi/7);...
                sin(-Theta(1:6)+2*pi/7)];
site(:,12)    = [17;5];
site(:,8:11)  = site(:,12)*ones(1,4) + 3*[cos(-Theta(1:4)+4*pi/7);...
                sin(-Theta(1:4)+4*pi/7)];
site(:,20)    = [5;5];
site(:,13:19) = site(:,20)*ones(1,7) + 3*[cos(Theta(1:7));sin(Theta(1:7))];

%% Plot the figure
if(~flag)
    % Figure configuration
    figure('Name','TestGraph2',...
           'NumberTitle','off',...
           'MenuBar','none',...
           'Position',[350 300 500 450],...
           'Color',[1 1 1],...
           'Resize','off',...
           'Visible','on');

    % Axes configuration
    axes('FontSize',13,...
         'FontWeight','demi',...
         'Visible','on');
    title('Test Graph with 20 vertices');
    axis off equal;
    hold on; 

    % Line
    for i = 1:20
        for j = 1:20
            if i > j && sData(i,j) > 0 
                plot(site(1,[i,j]),site(2,[i,j]));
            end
        end
    end
    
    % Point
    plot(site(1,1:7),site(2,1:7),'r.','MarkerSize',20);
    plot(site(1,8:12),site(2,8:12),'g.','MarkerSize',20);
    plot(site(1,13:20),site(2,13:20),'y.','MarkerSize',20);

    % Text
    for i = 1:20
        text(site(1,i)+0.2,site(2,i)+0.1,num2str(i));
    end
    hold off;
end
%%