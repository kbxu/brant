function [evector,evalue,num] = maxeigen(gMatrix,b0)
% maxeigen solves the maximum eigenvaule and eigenvector on gMatrix by 
% power iteration.
% Input:
%   gMatrix     a square matrix
%   b0          a initial value of eigen vector
% Usage:
%   [evector,evalue,num] = maxeigen(gMatrix,b0) returns max-eigen
%   "evalue",and correspoind vector "evector",and number of iteration.
% Example:
%   gMatrix = round(rand(10));
%   [evector,evalue] = maxeigen(gMatrix);
% Refer:
%   http://en.wikipedia.org/wiki/Power_iteration
% Note:
%                A*b_k
%   b_(k+1) = -----------
%               ||A*b_k||   ,and evector=b_(k+1),evalue=b_(k+1)'*A*b_(k+1).
% See also xxx

% Write by: Hu Yong,Nov,2010 
% Emial   : carrot.hy2010@gmail.com
% Based on Matlab 2008a
% $Revision: 1.0, Copywrite (c) 2010

% ###### Input check #########
% error(nargchk(1,2,nargin,'struct'));
if verLessThan('matlab', '7.14')
    error(nargchk(1,2,nargin,'struct'));
else
    narginchk(1, 2);
end
N = length(gMatrix);
if nargin < 2
    b0 = rand(N,1);
end
% ###### End check ###########

num         = 0;
flag        = inf;
next_vector = b0;

while flag > 10*eps
    current_vector = next_vector;
    next_vector    = gMatrix*current_vector;
    next_vector    = next_vector/sqrt(sum(next_vector.^2));%normalization
    flag           = sum(abs(next_vector-current_vector));
    num            = num + 1;
    
    if num > 10^4
        fprintf('The input matrix is a singular matrix!\n');
        break;
    end
end

evector = next_vector;
evalue  = next_vector'*gMatrix*next_vector;
%%%