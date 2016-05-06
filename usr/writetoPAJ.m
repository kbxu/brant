function varargout = writetoPAJ(g, str, fname, arcs)
% WRITETOPAJ write a Pajek "*.net" file from a MATLAB matrix
%   Usage: writetoPAJ(g, str, fname, arcs)
%   Inputs:
%       g       adjacency matrix, double
%       str     name of each node, cell
%       fname   filename minus .net extension, char
%       arcs    1/0 for directed(default)/undirected, logical
%   Writed by:  Chris Honey, Indiana University, 2007
%   Revised:    Hu Yong, 2011-07-02

error(nargchk(1,4,nargin,'struct'));
N = length(g);
% set default define
if nargin<4,    arcs  = true;    end
if nargin<3,    fname = ['paj',datestr(now,'yyyymmdd-HHMMSS')];     end
if nargin<2 || isempty(str)
    str = cell(N,1);
    for n = 1:N,    str{n} = sprintf('%d',n);	end
end

fid = fopen(cat(2, fname, '.net'), 'wt');

% vertices
fprintf(fid, '*vertices %2i\n', N);
for n = 1:N,    fprintf(fid, '%d "%s"\n', n, str{n});   end

% arcs/edges
if arcs % directed graph
    fprintf(fid, '*arcs\n');
else    % undirected graph
    fprintf(fid, '*edges\n');
    g = tril(g);
end

[I, J, val] = find(g);
fprintf(fid,'%d %d %f\n', cat(2,I,J,val)');
fclose(fid);

if nargout>0,   varargout{1} = true;    end