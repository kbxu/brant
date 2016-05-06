function S = CCM_Synchronization(gMatrix)
% CCM_Synchronization is designed to calculate synchronization for graph.
% Input:
%	gMatrix	    symmetric adjacency matrix
% Usage:
%	S = Net_Synchronization(gMatrix) returns the synchronous vaule of graph
% Example:
%	G = CCM_TestGraph1('nograph');
%   S = CCM_Synchronization(G);
% Refer:
%	Motter et al. Enhancing complex-network synchronization Europhys.(2005) 
% See also EIG, UNIQUE, EIGS

% Write by  : Huandong Li, Nov,2009
% E-mail    : hdli@nlpr.ia.ac.cn
% Center for Computational Medicine (CCM),
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% Revised by: Hu Yong,Dec,2010 
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2009

N = length(gMatrix); 
gMatrix(1: (N+1) :end) = 0;  %clear self-edges
if((N > 0) && (N <= 2000)),  %when N = 2k, it seems that more or less huge.
    D = unique(eig(gMatrix));%had sorted automatically     
    S = D(end)./D(2);
else
    fprintf('* WARNING: size of matrix is great than 2k, result maybe inaccuracy.\n');
    S = NaN;
    for i = 6:100  %find 100-max magnitude eigenvalues
        eValue = eigs(gMatrix, i, 'lm');%get i-largest magnitude eigenvalues
        po_ev  = unique(eValue(eValue > 0));%positive value
        ne_ev  = unique(eValue(eValue < 0));%negative value
        if((length(po_ev) >= 1) && (length(ne_ev) > 1)),
            S = po_ev(end)/ne_ev(2);
            break;
        end
    end
end   
    