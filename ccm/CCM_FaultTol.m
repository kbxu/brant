function [AvgFt, NodalFt] = CCM_FaultTol(gMatrix)
%CCM_FaultTol computes fault tolerance of network based on global perspective.
% Input: gMatrix - connect matrix
%   
% Usage:
%   [AvgFt, NodalFt] = CCM_FaultTol(gMatrix) returns the average local fault
%   tolerance of network, and local value of each node.
% Example:
%   G = CCM_TestGraph1('nograph');
%   [AvgFt, NodalFt] = CCM_FaultTol(G);
% Refer:
%   R.Albert, H.Jeong, and A.-L.Barab¨¢si, Nature(London) 406,378 (2000)
%   Error and attack tolerance of complex networks
% Note:
%   CCM_FaultTol is different from CCM_LEfficiency, for perspective.
% See also CCM_LEfficiency, dijk, MEAN, SUM

% Write by: Hu Yong, Mar,2011
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2011

if(issparse(gMatrix)),  sparflag = 1;   else   sparflag = 0;    end
N       = length(gMatrix);
NodalFt = zeros(N, 1);%Preallocate
for i = 1:N
    neig = find(gMatrix(i,:));%First neig nodes
    num  = length(neig);%Number of neigs
    neig(neig > i) = neig(neig > i) - 1;%New index
    
    if(num > 1),%Need have 2 neighbor node at least
        Ind   = [1:(i-1),(i+1):N];      %%DDDDD
        newg = gMatrix(Ind, Ind);
        if(sparflag), newg = sparse(newg);  end
        Distance = dijk(newg, neig);   %%DDDDD
        Effici   = 1./Distance(:, neig);
        Effici(1:(num+1):end) = 0;%Clear diagnal-elements
        NodalFt(i) = sum(Effici(:))./(num*(num-1));
    end
end
AvgFt = sum(NodalFt)/N;

% %%DDDDD -- where different from CCM_LEfficiency