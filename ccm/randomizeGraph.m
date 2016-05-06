function G = randomizeGraph(G, T, gType)
%randomizeGraph was used to randomizing graph's connected matrix.
% Inputs:
%   G       adjacency matrix of Graph, no has vaule inf!
%   T       times of swap, default max(100, M)
%   gType 	type of network,'binary' or 'directed'(default).
% Usage:
%   G = randomizeGraph(G, T, gType) return a new adjacency matrix having
%   the same degree sequence. 
% Example:
%	G  = CCM_TestGraph1('nograph');
%   newGraph = randomizeGraph_kc(G, 100, 'binary');
% Note:
%   If i1--j1 and i2--j2, will modify to i1--j2,i2--j1.
% See also isconnected, CCM_SmallWorldness

% Write by: Hu Yong,Dec,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

N = length(G);     %number of nodes
G(1:(N+1):end) = 0;%clear self-edges
M = nnz(G);        %number of edges

% Check connectivity of original graph
if(~isconnected(G)),  fprintf('WARNING: input graph isn''t conneted!\n');   end

if(nargin < 2),       T = max(M, 100);  gType = 'directed';
elseif(nargin < 3),   gType = 'directed';
elseif(nargin > 3),   error('Too many input.');
end

num  = 0;% record times of swap
switch(upper(gType(1:3)))
case 'BIN'% binary network    
	[I, J] = find(tril(G));
    M = M/2;
    while(num < T + 1)
        % Randomly choice edge1 & edge2
        edge1 = unidrnd(M);      edge2 = unidrnd(M);
        while(edge1 == edge2),   edge2 = unidrnd(M);    end
            
       	% Restore to nodes
       	i1 = I(edge1);   j1 = J(edge1);
       	i2 = I(edge2);   j2 = J(edge2);
        
       	% Check,ensure the four nodes different
       	if(~isempty(intersect([i1,j1],[i2,j2]))),   continue;     end
       
        % Flip edge i1-j1 with 50% probability to explore all possible    
        if(rand(1) > 0.5)
            I(edge2) = j2;   J(edge2) = i2;
            i2 = I(edge2);   j2 = J(edge2);
        end
            
     	% Swap
       	if((G(i1,j2) == 0) && (G(i2,j1) == 0)),
        	% i1-j1 ==> i1-j2
          	G(i1,j2) = G(i1,j1);   G(j2,i1) = G(j1,i1);            
           	G(i1,j1) = 0;          G(j1,i1) = 0;
           
            % i2-j2 ==> i2-j1
           	G(i2,j1) = G(i2,j2);   G(j1,i2) = G(j2,i2);
         	G(i2,j2) = 0;          G(j2,i2) = 0;
            
            num = num + 1;
        end
    end   

case 'DIR'% directed network
	[I, J] = find(G);
	while(num < T + 1)
    	% Randomly choice edge1 & edge2
       	edge1 = unidrnd(M);      edge2 = unidrnd(M);
        while(edge1 == edge2),   edge2 = unidrnd(M);    end

    	% Restore to nodes
      	i1 = I(edge1);           j1 = J(edge1);
      	i2 = I(edge2);           j2 = J(edge2);
       
        % Check,ensure the four nodes different
       	if(~isempty(intersect([i1,j1],[i2,j2]))),   continue;    end

       	% Swap
      	if((G(i1,j2) == 0) && (G(i2,j1) == 0)),
        	% i1-j1 ==> i1-j2
          	G(i1,j2) = G(i1,j1);   G(i1,j1) = 0;
            
          	% i2-j2 ==> i2-j1
         	G(i2,j1) = G(i2,j2);   G(i2,j2) = 0;
            
            num = num + 1;
        end
	end   

otherwise% Wrong type
    error('Wrong type, just for "Binary" or "Directed".');
end
