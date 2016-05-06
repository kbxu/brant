function [sData, site] = CCM_TestGraph3(input_type)
% CCM_TestGraph3 generated a test graph, which with 10 nodes,x edges.
% Input:
%	input_type	   no-input or any other strings will draw figure as output
%                  'nograph' represents only data,and don't draw figure
% Usage:
%   sData = CCM_TestGraph3('nograph') 
%   sData = CCM_TestGraph3 returns symmetric adjacent matrix sData
%   [sDatam,site] = CCM_TestGraph3('nograph') returns the coordinate of nodes
% Example:
%	sData = CCM_TestGraph3('nograph');
%   [sData,site] = CCM_TestGraph3;
%
% See also CCM_TestGraph,CCM_TestGraph1,CCM_TestGraph2

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########

error(nargchk(0,1,nargin,'struct'));
if nargin < 1
	input_type = 'figure';
end

% ###### End check ###########

flag = strncmpi(input_type,'nograph',2);

%% Generated a adjancency matrix and coordinate of nodes
N     = 10;
sData = zeros(N);
con   = [1 1 1 1 1 2 2 3 3 4 5 7 7 7 8 8 9;...
         2 4 6 7 10 3 5 4 6 5 6 8 9 10 9 10 10];
for i = 1:length(con)
    sData(con(1,i),con(2,i)) = 1;
end
sData = sData + sData';

site  = zeros(2,N);
theta = -pi + linspace(0,2*pi,7);
site(:,2:6) = [3 + 3*cos(theta(2:6));3*sin(theta(2:6))];
theta = linspace(0,2*pi,6);
site(:,7:10) = [-3 + 3*cos(theta(2:5));3*sin(theta(2:5))];

%% Plot the figure
if(~flag)
    % Figure configuration
    figure('Name','TestGraph3',...
           'NumberTitle','off',...
           'MenuBar','none',...
           'Position',[350 300 400 350],...
           'Color',[1 1 1],...
           'Resize','off',...
           'Visible','on');

    % Axes configuration
    axes('FontSize',13,...
         'FontWeight','demi',...
         'Visible','on');
    title('Test Graph with 10 vertices');
    axis off equal;
    hold on; 

    % Line
    for i=1:N
        for j=1:N
            if i>j && sData(i,j)>0 
                plot(site(1,[i,j]),site(2,[i,j]));
            end
        end
    end
    
    % Point
    plot(site(1,1),site(2,1),'r.','MarkerSize',25);
    plot(site(1,2:6),site(2,2:6),'b.','MarkerSize',20);
    plot(site(1,7:10),site(2,7:10),'g.','MarkerSize',20);

    % Text
    for i=1:N
        text(site(1,i)+0.2,site(2,i)+0.1,num2str(i));
    end
    
    hold off;
end
%%