function [xy, yaxx, pp] = calcnodecoord(adj, width, height, yrel, dy, plotflag)
%CALCNODECOORD Calculate coordinates for fixed-y, free-x node positioning
%
% [xy, yaxx, pp] = calcnodecoord(adj, width, height, yrel, dy, flag)
%
% This function uses a a variation on the Graphviz dot algorithm in order
% to calculate node positions for a directed graph with fixed
% y-coordinates.  
%
% Input variables:
%
%   adj:    nnode x nnode adjacency matrix
%
%   width:  nnode x 1, width (inches) of each node
%
%   height: nnode x 1, height (inches) of each node
%
%   yrel:   nnode x 1, y-coordinate of each node, on a relative scale
%
%   dy:     y-axis interval used for rank-matching algorithm.  Fiddling
%           with this paramter can make big differences in the resulting
%           node arrangement (and not necessarily following any pattern
%           from low to high values) 
%
%   flag:   if true, plots resulting nodes (red) as well as the
%           rank-matched intermediates (blue) to the current axis.
%
% Output variables:
%
%   xy:     nnode x 2, x and y coordinates for each node (inches)
%
%   yaxx:   default x coordinate of axis
%
%   pp:     1 x 2 coefficients of linear fit polynomial mapping the
%           relative-y values onto the new y axis.

% Copyright 2012 Kelly Kearney

% Basic graph properties

NodeProp.shape = 'box';
NodeProp.fixedsize = true;
NodeProp.width = num2cell(width);
NodeProp.height = num2cell(height);

A = graph2dot(adj, [], 'FG', NodeProp);

% Group nodes together by rounded trophic level

yref = min(yrel):dy:(max(yrel)+dy);
yref = sort(yref, 'descend');
[blah, rankidx] = arrayfun(@(x) min(abs(x - yref)), yrel);
nrank = length(yref);

refNodeName = arrayfun(@(x) sprintf('"Y%.1f"', x), yref, 'uni', 0);
nodeName = {A.Node.name}';

[tmpidx, tmpgroup] = aggregate(rankidx, nodeName); 
subgroup = cell(nrank,1);
subgroup(tmpidx) = tmpgroup;

for ii = 1:nrank
    subgroup{ii} = [refNodeName{ii}; subgroup{ii}];
    if ischar(subgroup{ii})
        subgroup{ii} = {subgroup{ii}};
    end
end

A.Subgraph = struct('nodes', subgroup, 'rank', 'same');

% Add y-axis nodes

YaxNode = struct('name', refNodeName, 'shape', 'plaintext');
YaxEdge = struct('tail', refNodeName(1:end-1), 'head', refNodeName(2:end));
naxedge = length(YaxEdge);

A.Node = catstruct(1, YaxNode', A.Node);
A.Edge = catstruct(1, YaxEdge', A.Edge);

% Render the rank-matched graph to a plain text file

[s,r] = rendergraph('dot', 'tempfw2d.txt', A);
if s
    error('Rendering of temporary text output of rank-matched file failed:\n %s', r);
end

% Read in the node and edge positions from the text file

[NewNode, NewEdge] = dottextread('tempfw2d.txt');
delete('tempfw2d.txt');

xpos = [NewNode.x]';
ypos = [NewNode.y]';

% pos = [[NewNode.x]' [NewNode.y]'];
names = {NewNode.name}';

% Find trophic nodes and their trophic level values

isax = strncmp('"Y', names, 2);

yaxnames = names(isax);
yaxnames = regexprep(yaxnames, '"Y', ''); 
yaxnames = regexprep(yaxnames, '"', '');

yaxval = cellfun(@str2num, yaxnames);

% Calculate new y positions

yaxx = mean(xpos(isax));

xpos2 = xpos;
xpos2(isax) = yaxx;

yaxypos = ypos(isax);
pp = polyfit(yaxval, yaxypos, 1);
ypos2 = polyval(pp, [yaxval; yrel]);


if plotflag
    hold on;
    plot(xpos(isax), ypos(isax), 'b+');
    plot(xpos2(isax), ypos2(isax), 'rx');
    plotboxes([xpos(~isax)  ypos(~isax)],  width, height, '--b');
    plotboxes([xpos2(~isax) ypos2(~isax)], width, height, 'r');
    text(xpos(~isax), ypos(~isax), cellstr(num2str((1:size(adj,1))')), 'fontsize', 8);
    axis tight equal;
%     gridxy([], ypos(isax), 'linestyle', ':');
end 

xy = [xpos2(~isax) ypos2(~isax)];



function plotboxes(xydata, width, height, varargin);

xscale = 1;
yscale = 1;

xlim = [xydata(:,1)*xscale - width./2,  xydata(:,1)*xscale + width./2];
ylim = [xydata(:,2)*yscale - height./2, xydata(:,2)*yscale + height./2];

xbox = [xlim(:,1) xlim(:,2) xlim(:,2) xlim(:,1) xlim(:,1)];
ybox = [ylim(:,1) ylim(:,1) ylim(:,2) ylim(:,2) ylim(:,1)];

plot(xbox', ybox', varargin{:});











