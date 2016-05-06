function [C,Q] = eigenmodule_ds(gMatrix)
% eigenmodule_ds clusters nodes in directed network by using eigen-verctors
% to optimal modularity.
% Input:
%   gMatrix adjancent matrix of network
% Usage:
%   [C, Q] = eigenmodule_ds(gMatrix) returns a the max partition modular 
%            Q,and corresponding communities.
% Example:
%   G = CCM_TestGraph1();
%   [C, Q] = eigenmodule_ds(G);
% Note:
%   for directed network.
% Refer:
%   M.E.J.Newman.Community Structure in Directed Networks(2008).
% See also eigenmodule,CCM_EigenCommunity

% Write by: Mika Rubinov, UNSW(Jul,2008)
% Revised : Jonathan Power(Oct,2008)
%           Mika Rubinov(Dec,2008)
%           Dani Bassett(Sep,2010)
%           Hu Yong(Jan,2011)
% $Revision: x.x, Copywrite (c) 2008-2010

N          = length(gMatrix);           %number of nodes
gMatrix(1:(N+1):end) = 0;               %clear self-edges
M          = nnz(gMatrix);              %number of edges

N_perm     = randperm(N);               %randomly permute order of nodes
gMatrix    = gMatrix(N_perm,N_perm);
D          = sum(gMatrix);              %degree
mmatrix    = gMatrix - (D.'*D)/M;       %modularity matrix
mmatrix    = mmatrix + mmatrix.';       %####different from binary network

num        = 1;                         %number of communities
C          = sparse(N,1);               %index of communities
uncheck    = [1,0];                     %index of uncheck communities

% Preallocation
subg       = (1:N)';                    %index of subgraph
submm      = mmatrix;                   %modularity matrix of subgraph
subnum     = N;                         %number of nodes in subgraph

while(uncheck(1))
    % Find the max-eigen-value of modularity matrix
    [evector,evalue] = eig(submm);
    [temp,position]  = max(diag(evalue));
    temp             = evector(:,position);
    
    subind           = ones(subnum,1);  %division of subgraph
    subind(temp<0)   = -1;
    subQ             = subind.'*submm*subind;%contribution to modularity
    
    % Record
    if subQ > 1e-8                      %positive contribution 
                                        %-- subgraph uncheck(1) is divisible
        % Fine-tuning
    	subQ2        = subQ;            %perpare
        submm(1:(subnum+1):end) = 0;    %modify to enable fine-tuning
        indg         = sparse(subnum,1);%array of unmoved indices
        iiter        = subind;          %index of iteration
        
        while(any(indg))                %start iteration
            qiter    = subQ2 - 4*iiter.*(submm*iiter);%it equivalent to:
                                        %for i = 1:subnum
                                        %    iiter(i)=-iiter(i);qiter(i)=iiter'*submm*iiter;iiter(i)=-iiter(i);
                                        %end
            subQ2    = max(qiter.*indg);
            Imax     = (qiter == subQ2);
            iiter(Imax) = -iiter(Imax);
            indg(Imax)  = NaN;
            % success after fine-tunig
            if subQ2 > subQ
                subQ    = subQ2;
                subind  = iiter;
            end
        end
        
        % Determine
        if abs(sum(subQ)) == subnum     %fail to split uncheck(1)
            uncheck(1)  = [];
        else
            num         = num +1;
            C(subg(subind == 1)) = uncheck(1);
            C(subg(subind == -1)) = num;
            uncheck     = cat(2,num,uncheck);   %the same as [num,uncheck]
        end
    else
        uncheck(1)  = [];               %negative contribution
    end
    
    % Perpare for the next bipartition
    subg            = find(C == uncheck(1));
    temp            = mmatrix(subg,subg);
    submm           = temp - diag(sum(temp));%modularity matrix for uncheck(1)
    subnum          = length(subg);
end

% Tidy
ind   = repmat(C,1,N);                  %compute modularity
Q     = ~(ind - ind.').*mmatrix./(2*M); %####different from binary network
Q     = sum(Q(:));

Ctemp = zeros(N,1);                     %restore original order
Ctemp(N_perm) = C;
C     = Ctemp;

% Tranformation
temp   = C;
C      = cell(0);
for i  = 1:max(temp)
	C{length(C)+1} = find(temp == i)';
end
%%%