function [gMatrix, coord] = CCM_TestGraph0(ngroup, nNode, distb)
%CCM_TestGraph0 generates random graph for testing.
%	Input:
%			ngroup	-  number of groups, default 4.
%					   if ngroup = 0, just generate matrix with default setting.
%					   if ngroup = 1 or empty,  generate matrix and graph.
%			nNode   -  number of nodes in each group, default 32.
%			distb   -  array with 2 numbers,[zin, zout], zin < nNode
%					   and zout < (ngroup-1)*nNode, default [8, 8].
%	Output:
%			gMatrix -  adjacency matrix, binary and symmetric.
%			coord   -  coordinate of the points.
%	Note:  	connetctivity is random. Maybe not all but almost nodes have
%           the required edges.
% 	Example:
%			gMatrix = CCM_TestGraph0(4, 32, [8, 4]);

% Writed By Yong Hu, Oct-28, 2010
% Revised, Mar-13, 2011

if((nargin < 1) | isempty(ngroup)),	
	ngroup = 4;	
	nNode  = 32;
	distb  = [8, 8];
	FigSign   = 'figure';%sign of figure
elseif((nargin < 2) | (ngroup == 1) | (ngroup == 0))
	nNode  = 32;
	distb  = [8, 8];
	FigSign   = 'figure';
	if(ngroup == 1),	ngroup = 4; 	end
	if(ngroup == 0),	
		ngroup = 4;	
		FigSign = 'nograph';
	end
elseif(nargin < 3)
	distb  = min(8, fix(nNode/2))*ones(1,2);
elseif((length(distb) ~= 2) || (distb(1) >= nNode) ...
	|| (distb(2) >= (ngroup-1)*nNode))
	error('Invalid [zin, zout].');
end
if(~exist('FigSign','var') | ~strcmpi(FigSign, 'nograph')),	FigSign = 'figure';	end

Rmax = 30;%Radius of centre-circle
Rmin = 10;%Radius of group-circle

% Produce ngroup - centres
centr = zeros(ngroup, 2);
tmp   = linspace(0, 2*pi, ngroup+1);
tmp(end) = [];
centr(:,1) = Rmax * cos(tmp);
centr(:,2) = Rmax * sin(tmp);

% Produce coordinates
if(ngroup > 5)
    coord = Rmin * rand(ngroup*nNode, 2);%Gather
else
    coord = Rmin * randn(ngroup*nNode, 2);%Scatter
end

for(i = 1:ngroup)
	tmp = ((i-1)*nNode+1):i*nNode;
	coord(tmp, :) = coord(tmp, :) + repmat(centr(i,:), nNode, 1);
end

% Get adjacency matrix
gMatrix = adjMatrix(ngroup, nNode, distb);

% Figure
if(~strcmpi(FigSign, 'nograph')),
	% Figure configuration
    figure('Name','TestGraph0',...
           'NumberTitle','off',...
           'MenuBar','none',...
           'Position',[250 200 500 500],...
           'Color',[1 1 1],...
           'Resize','on',...
           'Visible','on');

    % Axes configuration
    axes('FontSize',13,...
         'FontWeight','demi',...
         'Visible','on');
    title(sprintf('Test Graph with %d vertices', nNode*ngroup));
    axis off equal;
    hold on; 
    
    pcolor = jet(ngroup+1);%Color

    
    % Line
    for i = 1:nNode*ngroup
        for j = (i+1):nNode*ngroup
            if(gMatrix(i,j)>0),  
                plot(coord([i,j],1), coord([i,j],2),'Color',pcolor(end,:));  
            end
        end
    end    
	
    % Point
	for i = 1:ngroup
		tmp = ((i-1)*nNode+1):i*nNode;
		plot(coord(tmp,1), coord(tmp,2),'.','MarkerSize',20,'Color',pcolor(i,:));
	end


%     % Text
%     for i = 1:nNode*ngroup
%        text(coord(i,1)+0.1, coord(i,2)+0.2, num2str(i));
%     end
    hold off;
end
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = adjMatrix(N, M, D)
% g - gMatrix
% N - ngroup
% M - nNode
% D - distb

mark  = zeros(N*M, 2);%Record zin & zout of each node
g     = zeros(N*M, N*M);
for i = 1 : N*M
	num = fix((i-1)/M);%i belong to group num
	samegroup  = setdiff((num*M + 1): (num+1)*M, i);%the same group with node-i
	diffgroup  = setdiff(1:N*M, (num*M + 1): (num+1)*M);
	
	
	inneed  = D(1) - mark(i,1);
	outneed = D(2) - mark(i,2);
	if(inneed > 0)
		tmp = samegroup(mark(samegroup, 1) < D(1));
		if(~isempty(tmp))
			select = randperm(length(tmp));%random perm
			select = select(1:min(inneed, length(tmp)));%select
			select = tmp(select);
			
			g(i, select)  = 1;
			g(select, i)  = 1;
			mark(select, 1) = mark(select, 1) + 1;
			mark(i,1) = mark(i,1) + length(select);
		end
	end
			
	if(outneed > 0)
		tmp = diffgroup(mark(diffgroup, 2) < D(2));
		if(~isempty(tmp))
			select = randperm(length(tmp));
			select = select(1:min(outneed, length(tmp)));
			select = tmp(select);
			
			g(i, select)  = 1;
			g(select, i)  = 1;
			mark(select, 2) = mark(select, 2) + 1;
			mark(i, 2) = mark(i, 2) + length(select);
		end
	end
end
%%%