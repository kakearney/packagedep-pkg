function [xy, tlx, tlypp] = foodwebgraphcoord(Ewein, trophicint, NodeProp)
%FOODWEBGRAPHCOORD Calculate node positions for food web graph
%
% [xy, tlx, tlypp] = foodwebgraphcoord(Ewein, trophicint, NodeProp);
% [xy, tlx, tlypp] = foodwebgraphcoord(dietcomp, ispp, nlive, ngroup,
%                                      trophicint)
%
% note: fiddling with trophicint parameter even just a little can create
% very different layouts, so play around
%
% Input variables:
%
%   dietcomp:   ngroup x ngroup diet composition matrix
%
%   ispp:       ngroup x 1 logical matrix, true if group is primary
%               producers
%
%   nlive:      scalar, number of live groups
%
%   ngroup:     number of groups
%
%   trophicint: scalar, spacing between trophic levels used for the
%               rank-matching algorithm (1:trophicint:max).  Fiddling with
%               this paramter can make big differences in the resulting
%               food web arrangement (and not necessarily following any
%               pattern from low to high values), so playing around with
%               this is the best way to find an arrangement that works.
%
% Output variables:
%
%   xy:         ngroup x 2 array of x and y coordinates for each food web
%               node
%
%   tlx:        x coordinate for trophic level axis
%
%   tlypp:      polynomial coefficients for y-coordinate of trophic level
%               axis.  For ticks at any given trophic level tl,
%               polyval(tlypp, tl) will return the y-coordinate of that
%               tick mark.

% Copyright 2010 Kelly Kearney

if nargin > 2
    A = graph2dot(Ewein.dc, [], 'FG', NodeProp);
else
    A = graph2dot(Ewein.dc, [], 'FG');
end

% A = graph2dot(dietcomp, [], 'FG');

% Group nodes by matching each node to the closest input trophic level

% tl = trophiclevel(dietcomp, ispp, nlive, ngroup);
tl = trophiclevel(Ewein);
trophic = 1:trophicint:(max(tl)+trophicint);

trophic = sort(trophic, 'descend');
ntrophic = length(trophic);

trophicGroups = ranktrophic(Ewein.dc, Ewein.pp==1, Ewein.nlive, trophic);

tlNodeName = arrayfun(@(x) sprintf('"TL%.1f"', x), trophic, 'uni', 0);
nodeName = {A.Node.name};

subgroup = cell(length(trophicGroups),1);
for igroup = 1:length(trophicGroups)
    subgroup{igroup} = [tlNodeName(igroup), nodeName(trophicGroups{igroup})];
end

% Add subgraphs defining nodes of the same rank

A.Subgraph = struct('nodes', subgroup, 'rank', 'same');
  
% Add trophic level axis nodes

TrophicNode = struct('name', tlNodeName, 'shape', 'plaintext');
TrophicEdge = struct('tail', tlNodeName(1:end-1), 'head', tlNodeName(2:end));
ntedge = length(TrophicEdge);

A.Node = catstruct(1, TrophicNode', A.Node);
A.Edge = catstruct(1, TrophicEdge', A.Edge);

% Render the rank-matched graph to a plain text file

[s,r] = rendergraph('dot', 'tempfw2d.txt', A);
if s
    error('Rendering of temporary text output of rank-matched file failed:\n %s', r);
end

% Read in the node and edge positions from the text file

[NewNode, NewEdge] = dottextread('tempfw2d.txt');
delete('tempfw2d.txt');

pos = [[NewNode.x]' [NewNode.y]'];
names = {NewNode.name}';

% Find trophic nodes and their trophic level values

istl = strncmp('"TL', names, 3);

tlnames = names(istl);
tlnames = regexprep(tlnames, '"TL', ''); 
tlnames = regexprep(tlnames, '"', '');

tllevel = cellfun(@str2num, tlnames);

% Calculate new y positions

tlypos = pos(istl,2);
pp = polyfit(tllevel, tlypos, 1);
newypos = polyval(pp, [tllevel; tl]);
pos(:,2) = newypos;

xy = pos(~istl,:);
tlx = mean(pos(istl,1));
tlypp = pp;

