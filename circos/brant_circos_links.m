function [band_strs, link_strs] = brant_circos_links(link_mat, subrg, rgs, rgs_ord, varargin)
% link_strs: output an cell array written as circos link format
% link_mat: matrix of links
% subrgs: sub-regions of each link
% rgs: regions for each sub-regions.
% rgs_ord: order of regions, cellarray of rgs.
% varargins: define color, weight and etc., of links

assert(isequal(link_mat, link_mat') && (size(link_mat, 1) == numel(subrg)) && (numel(rgs) == numel(subrg)));
chr_unit = 1000;
num_sub_rgs = numel(rgs);
num_rgs = numel(rgs_ord);

if nargin == 6
    color_strs = varargin{1};
    weight_ind = varargin{2};
elseif nargin == 5
    color_strs = varargin{1};
    weight_ind = 0;
else
    color_strs = {'red', 'blue'};
    weight_ind = 0;
end

%% get strings for bands
rgs_ind = arrayfun(@(x, y) sum(strcmpi(x{1}, rgs(1:y))), rgs, (1:num_sub_rgs)');
rgs_ord_ind = cellfun(@(x) find(strcmpi(x, rgs_ord)), rgs);
rgs_num_sub = cellfun(@(x) sum(strcmpi(x, rgs)), rgs_ord);

color_band = cell(num_sub_rgs, 1);
color_band(1:2:num_sub_rgs) = {'gpos'};
color_band(2:2:num_sub_rgs) = {'gneg'};

band_str1 = arrayfun(@(x, y, z)...
    sprintf('chr - lobe%d %s 0 %d chr%d', x, y{1}, z * chr_unit - 1, rem(x, 22)+1),...
    (1:num_rgs)', rgs_ord, rgs_num_sub, 'UniformOutput', false);
band_str2 = arrayfun(@(x, y, z, o)...
    sprintf('band lobe%d %s %s %d %d %s', x, y{1}, y{1}, (z - 1) * chr_unit, (z - 1) * chr_unit + (chr_unit - 1), o{1}),...
    rgs_ord_ind, rgs, rgs_ind, color_band, 'UniformOutput', false);

band_strs = [band_str1; band_str2];

if nargout == 1
    return;
end

%% get strings for links
[link_x, link_y] = find(triu(link_mat, 1));
if weight_ind == 1
    link_vals = arrayfun(@(x, y) link_mat(x, y), link_x, link_y);
else
    link_vals = arrayfun(@(x, y) sign(link_mat(x, y)), link_x, link_y);    
end

num_links = numel(link_vals);
link_colors = cell(num_links, 1);
link_colors(link_vals > 0) = color_strs(1);
link_colors(link_vals < 0) = color_strs(2);
link_adds = arrayfun(@(x, y)...
    sprintf('thickness=%d,color=%s', x, y{1}),...
    abs(link_vals), link_colors, 'UniformOutput', false);

link_strs = arrayfun(@(x, y, z) sprintf('lobe%d %d %d lobe%d %d %d %s',...
    rgs_ord_ind(x), (rgs_ind(x) - 1) * chr_unit, (rgs_ind(x) - 1) * chr_unit + (chr_unit - 1),...
    rgs_ord_ind(y), (rgs_ind(y) - 1) * chr_unit, (rgs_ind(y) - 1) * chr_unit + (chr_unit - 1), link_adds{z}),...
    link_x, link_y, (1:num_links)', 'UniformOutput', false);