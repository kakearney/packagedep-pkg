function Node = colornodes(Node, vals, cmap, nameregexp)
%COLORNODES Add fillcolor field to a Graphviz node structure
%
% Node = colornodes(Node, vals, cmap, nameregexp)
% Node = colornodes(Node, vals, cmap)
%
% This function adds fillcolor fields to a node structure, based on input
% values and colormap.
%
%
% Input variables:
%
%   Node:       node structure (see attgraphwrite.m)
%
%   vals:       vector of values used to interpolate colormap to each node.
%               Each value corresponds to a single node.  The number of
%               selected nodes (see nameregexp) must match the length of
%               this vector.  The minimum value will correspond to the
%               first cmap color and the maximum value to the last cmap
%               color.
%
%   cmap:       n x 3 colormap
%
%   nameregexp: regular expression pattern string used to select nodes to
%               color.  Only nodes whose 'name' field matches the pattern
%               will be modified.  If not included, all nodes will be
%               modified.
%
% Output variables:
%
%   Node:       node structure, same as input but with added 'fillcolor'
%               and 'style' fields ('style' must be 'filled' in order for
%               Graphviz to apply a fillcolor). 

% Copyright 2008 Kelly Kearney

if nargin > 3
    idx = find(cellfun(@(x) ~isempty(x), regexp({Node.name}, nameregexp)));
else
    idx = 1:length(Node);
end

if ~isequal(length(idx), length(vals))
    error('Number of nodes matching regular expression must equal the number of values');
end

step = linspace(min(vals),max(vals),size(cmap,1));
    
for inode = 1:length(idx)
    Node(idx(inode)).fillcolor = rgb2hsv(interp1(step, cmap, vals(inode)));
    Node(idx(inode)).style = 'filled';
end
    






