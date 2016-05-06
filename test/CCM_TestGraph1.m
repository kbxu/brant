function [sData, site] = CCM_TestGraph1(input_type)
% CCM_TestGraph1 generated a test graph, which with 9 nodes,15 edges.
% Input:
%	input_type	   no-input or any other strings will draw figure as output
%                  'nograph' represents only data,and don't draw figure
% Usage:
%   sData = CCM_TestGraph1('nograph') 
%   sData = CCM_TestGraph1 returns symmetric adjacent matrix sData
%   [sDatam,site] = CCM_TestGraph1('nograph') returns the coordinate of nodes
% Example:
%	sData = CCM_TestGraph1('nograph');
%   [sData,site] = CCM_TestGraph1;
%
% See also CCM_TestGraph,CCM_TestGraph2

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

error(nargchk(0,1,nargin,'struct'));
if(nargin < 1),	input_type = 'figure';  end

%% Generated a adjancency matrix and coordinate of nodes
sData = zeros(9);
con   = [1 1 2 2 2 3 3 4 4 5 6  6 7 7 8;...
         2 5 3 4 5 4 5 5 7 6 7 9 8 9 9];
for i = 1:size(con,2)
    sData(con(1,i),con(2,i)) = 1;
end
sData = sData + sData';
site  = [2,1,1,3,3,5,5,7,7;5,3,1,1,3,3,1,1,3];

%% Plot the figure
if isempty(strmatch(input_type(1:2),'no'))
    % Figure configuration
    figure('Name','TestGraph1',...
           'NumberTitle','off',...
           'MenuBar','none',...
           'Position',[350 300 400 400],...
           'Color',[1 1 1],...
           'Resize','off',...
           'Visible','on');

    % Axes configuration
    axes('FontSize',13,...
         'FontWeight','demi',...
         'Visible','on');
    title('Test Graph with 9 vertices');
    axis off equal;
    hold on; 

    % Line
    for i = 1:9
        for j = (i+1):9
            if sData(i,j)>0 
                plot(site(1,[i,j]),site(2,[i,j]));
            end
        end
    end
        
    % Point
    plot(site(1,1:5),site(2,1:5),'r.','MarkerSize',20);
    plot(site(1,6:9),site(2,6:9),'g.','MarkerSize',20);


    % Text
    for i = 1:9
        text(site(1,i)+0.1,site(2,i)+0.1,num2str(i));
    end
    hold off;
end
%%