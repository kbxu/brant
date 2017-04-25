function T = CCM_Transitivity(gMatrix, gType, mode)
% CCM_Transitivity calculates transitivity of network.
% Input:
%   gMatrix     connect matrix
%   gType       type of graph: 'binary'(default), 'weighted', 'directed',
%               and 'all' for weighted + directed.
%   mode        'geometric mean'(default), 'arithmetic mean', 'maximum
%                mode', and 'minimum mode'.
% Usage:
%   T = CCM_Transitivity(gMatrix, gType, method) returns transitivity "T".
% Example:
%   G = round(rand(10));G(1:11:end) = 0;%clear diagal elements
%   T = CCM_Transitivity(G, 'directed', 'geometric');
% Note:
%   1)transitivity is the ratio of 'triangles to triplets' in the network
%     (a classical version of the global clustering coefficient).
%   2)one has vaule 0, while which only has a neighbour or none
%   3)the four modes just for weighted network.
%   4)the dircted network termed triplets that fulfill the follow condition 
%     as non-vacuous: j->i->k and k->i-j,if don't satisfy with that as 
%     vacuous,just like: j->i,k->i and i->j,i->k. and the closed triplets 
%     only j->i->k == j->k and k->i->j == k->j
%   5)some fast vision comes from BCT toolkit.
% Refer:
%	[1] Tore Opsahl and Pietro Panzarasa (2009). "Clustering in Weighted 
%       Networks". Social Networks31(2).
%   [2] http://en.wikipedia.org/wiki/Clustering_coefficient#cite_note-5
% See also CCM_ClusteringCoef

% Written by Hu Yong, Nov,2010
% E-mail: carrot.hy2010@gmail.com
% based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010
% See also Net_ClusteringCoefficients

% error(nargchk(1,3,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(1,3,nargin,'struct'));
else
    narginchk(1, 3);
end
if(nargin < 2),     gType = 'binary';   mode = 'geometric';
elseif(nargin < 3),	mode  = 'geometric';    end
N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;%Clear self-edges

switch(upper(gType(1:3)))
case 'BIN'% Binary network
	% clarity format
	gMatrix = double(gMatrix > 0); %ensure binary network
	G2      = gMatrix^2;
	G3      = G2*gMatrix;
	G2(1:(1+N):end) = 0;           %clear self-edges
	T       = trace(G3)./sum(G2(:));
    
% 	% other versions
%     gMatrix = double(gMatrix > 0);
% 	total = 0;   tri = 0;
% 	for i = 1:N
%         neighbor  = (gMatrix(i,:) > 0);
%         num       = sum(neighbor);%number of neighbor-nodes
%      	if(num > 1), 	total = total + num*(num-1);
%                         tri   = tri   + sum(sum(gMatrix(neighbor, neighbor)));
%      	end
%  	end
% 	T = tri/total;
        
case 'WEI'% Weighted network
    % There have 4 calcuative modes
	switch(upper(mode(1:3)))
    case 'GEO', fun = @(g) sqrt(times(g, g'));  % Geometric mean
   	case 'ARI', fun = @(g) g + g';              % Arithmetic mean
    case 'MAX', fun = @(g) max(g, g');          % Maximum mode
   	case 'MIN', fun = @(g) min(g, g');          % Minimun mode
    otherwise,  error('Wrong mode, just for "GEO","ARI","MAX",or "MIN"');
    end
    T   = modefun1(gMatrix, fun);
    
case 'DIR'% Directed network
    total = 0;      tri   = 0;
    for i = 1:N
    	inset   = (gMatrix(:,i) > 0);  %in-nodes set
       	outset  = (gMatrix(i,:) > 0)'; %out-nodes set
        if(any(inset) && any(outset)),
            allset = (inset & outset); %Ensure aji*aik > 0,j belongs to 
                                       %inset,and k belongs to outset                
        	total  = total + (sum(inset)*sum(outset) - sum(allset));
            tri    = tri   + sum(sum(gMatrix(inset, outset)));
        end
    end
    T = tri/total;
       
case 'ALL'% All type
    switch(upper(mode(1:3)))
    case 'GEO', fun = @(g, h) sqrt(times(g, h));% Geometric mean
   	case 'ARI', fun = @(g, h) g + h;          	% Arithmetic mean
    case 'MAX', fun = @(g, h) max(g, h);       	% Maximum mode
   	case 'MIN', fun = @(g, h) min(g, h);       	% Minimun mode
    otherwise,  error('Wrong mode, just for "GEO","ARI","MAX",or "MIN"');
    end
    T   = modefun2(gMatrix, fun);

otherwise,
    error('Wrong type, just for "Binary","Weighted","Directed", or "All"');
end
   
% ###### Subfunction1 ###### 
function T = modefun1(gMatrix, fun)
% Note: fun is a handle-function
N = length(gMatrix);
vtotal = 0;%total value
vtri   = 0;%tri value
for i = 1:N
	neighbor = (gMatrix(i,:) > 0);
	num      = sum(neighbor);
	if(num > 1),
        g = ones(num, 1)*gMatrix(i, neighbor);
        g = fun(g);  % ***
        g(1:(num+1):end) = 0;
        vtotal = vtotal + sum(g(:));
        vtri   = vtri + sum(sum(g.*gMatrix(neighbor, neighbor)));
	end
end
T = vtri/vtotal;

% ###### Subfunction2 ###### 
function T = modefun2(gMatrix, fun)
% Note: fun is a handle-function
N = length(gMatrix);
vtotal = 0;     
vtri   = 0;
for i = 1:N
	inset  = (gMatrix(:,i) > 0)';
    outset = (gMatrix(i,:) > 0);
    if(any(inset) && any(outset))
        allset = (inset & outset);
        gin  = repmat(gMatrix(inset,i), 1, sum(outset));
        gout = repmat(gMatrix(i,outset), sum(inset), 1);
        
        if any(allset),    tmp = fun(gMatrix(i,allset), gMatrix(allset,i)');
        else               tmp = 0;     end
        g = fun(gin, gout);
        vtotal = vtotal + sum(g(:)) - sum(tmp);%minus repeated value
        vtri   = vtri   + sum(sum(g.*gMatrix(inset, outset)));
	end
end
T = vtri/vtotal;
%%%