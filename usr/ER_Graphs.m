function A = ER_Graphs(N,p,Kreg)
% ER_Graphs generates a random graph based on the Erdos and Renyi 
% algoritm where all possible pairs of 'N' nodes are connected with 
% probability 'p'. 
% Inputs:
%   N    - number of nodes 
%   p    - rewiring probability,default 0.01
%   Kreg - initial node degree of for regular graph (use 1 or even numbers)
% Output:
%   A    - adjacency matrix(1 for connected nodes, 0 otherwise).
% Note:
%   The result will be perfect while the network is sparse,namely,Kreg<<N.
% Example:
%   To rewire, with probability (p=0.1) a 40-verties regular graph 
%   (vertex deg=10): 
%   A = ER_Graphs(40,0.1,10);

% Created by Pablo Blinder. blinderp@bgu.ac.il
% Update 25/01/2005
% Revised by Hu Yong,Jan,2010

% ##### Input check #####
error(nargchk(1,3,nargin,'struct'));
if nargin < 2
    p    = 0.01;
    Kreg = 2;
elseif nargin < 3
    Kreg = 2;
end

Kreg = abs(fix(Kreg));
if(mod(Kreg,2) && Kreg ~= 1)
    Kreg = Kreg + 1;        %ensure Kreg is a even
    display('Initial node degree must be a even!');
end
% ##### End check #####

% Build regular lattice 
Kreg = Kreg/2;
Kreg = round(Kreg);         %avoid Kreg=0.5
A    = spdiags(ones(N,2*Kreg),[1:Kreg,(N-Kreg):(N-1)],N,N);
% Just like follow:
% for k = 1:Kreg
%     A = sparse(A+diag(ones(1,length(diag(A,k))),k)+...
%         diag(ones(1,length(diag(A,N-k))),N-k));
% end

M     = nnz(A);             %number of edges
% Find connected pairs
[s,t] = find(A);
discon =(rand(length(s),1) <= p);      %vertex-pairs to disconnect
A(s(discon),t(discon)) = 0;

% Cycle trough disconnected vertex-pairs
discon = [s(discon),t(discon)];        %set of disconnected pairs
for n = 1:(M-nnz(A))
    % Choose one of the vertices from the disconnected pairs
    i = unidrnd(size(discon,1));       %random produce a index
    j = double(1+rand>0.5);            %random choice end-point index
    nodei = discon(i,j);               
    
    % Find non-adjacent vertices
    neighbor  = [find(A(:,nodei));find(A(nodei,:))';nodei];
    disnode   = setdiff(1:N,neighbor); %candidate nodes
    if(~isempty(disnode))
        nodej = disnode(unidrnd(length(disnode)));
    else
        continue;       %##there will reduce a chance to reconnect
    end
    
    % Reconnect
    if nodei > nodej
        A(nodej,nodei) = 1;
    else
        A(nodei,nodej) = 1;
    end
end

% Make adjacency matrix symetric
A = max(A,A');