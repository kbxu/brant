function [C,module] = CCM_EigenCommunity(gMatrix)
% CCM_EigenCommunity clusters nodes by eigen-value algorithm
% Input:
%   gMatrix     binary symmetric connected matrix
% Usage:
%   [C,module] = CCM_EigenCommunity(gMatrix) returns node-clusteries,and
%   max modular value "module".
% Example:
%   G = CCM_TestGraph1();
%   [C,moudule] = CCM_EigenCommunity(G);
% Refer:
%   M.E.J.Newman   Modularity and community structure in network
% See also eigenmodule,eigenmodule2

% Write by: Hu Yong,Jun,2011 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2011

N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;       %clear self-edges
gMatrix = double(gMatrix > 0);  %ensure binary or directed netwrok

flag    = xor(gMatrix,gMatrix');
if any(flag(:))
    graph_type = 'd';           %directed network
else
    graph_type = 'b';           %binary network
end

% Comupute modular community
switch(graph_type)
    % Binary network
    case 'b'
        [C,module] = eigenmodule_br(gMatrix);
        
    % Directed network
    case 'd'
        [C,module] = eigenmodule_ds(gMatrix);
        
    otherwise % do nothing
end
%%%