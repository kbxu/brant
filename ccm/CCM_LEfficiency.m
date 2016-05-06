function [AverLoc, ENodaLoc] = CCM_LEfficiency(gMatrix)
%CCM_LEfficiency computes local-efficiency of graph based on local perspective.
% Input:   gMatrix - connect matrix
% Usage:
%   [AverLoc, ENodaLoc] = CCM_LEfficiency(gMatrix) returns the average local
%    efficient of network, and local-efficient of each node.
% Example:
%   G = round(rand(20));%random 0-1 matrix
%   [AverLoc, ENodaLoc] = CCM_LEfficiency(G);
% Refer:
%   V.Latora,etc. Efficient Behavior of Small-World Networks.(Phys.Rev,lett.2001) 
% See also CCM_GEfficiency, dijk, MEAN, SUM

% Write by: Hu Yong, Nov,2010
% Based on Matlab 2008a
% $Revision: 1.0

if(issparse(gMatrix)),  sparflag = 1;   else   sparflag = 0;    end

N = length(gMatrix);
gMatrix(1:(N+1):end) = 0;%Clear self-edges
ENodaLoc = zeros(N,1);   %Preallocate
for i = 1:N
    neig = (gMatrix(i,:) > 0); %Neighbor nodes  %%DDDDD
    num  = sum(neig);
    if(num > 1)%Need 2 nodes at least
        newg = gMatrix(neig, neig);%Subgraph 	%%DDDDD
        if(sparflag), newg = sparse(newg);  end
        effi = 1./dijk(newg, 1:num);
        effi(1:(num+1):end) = 0;%Clear diagnal-elements
        ENodaLoc(i) = sum(effi(:))/(num*(num-1));
    end
end
AverLoc = sum(ENodaLoc)/N;

% %%DDDDD -- where different from CCM_FaultTol