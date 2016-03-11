function A = graph2dot(adj, xy, prefix, Nodeprop, Edgeprop)
%GRAPH2DOT Creates a Graphviz structure for a directed graph
%
% A = graph2dot(adj, xy, prefix, Nodeprop, Edgeprop)
%
% Input variables:
%
%   adj:    nnode x nnode adjacency matrix.  Rows are tail of edge, columns
%           are head.
%
%   xy:     nnode x 2 array of x and y coordinates of each node, in points.
%           Can be empty to use Graphviz positioning
%
%   prefix: prefix used to label each node.  If not included, 'node' is
%           used.  Node labels will consist of this prefix followed by a
%           two-digit number indicating the node number.
%
%   Nodeprop:   1 x 1 structure with field names corresponding to a
%               Graphviz node propery.  Each field can hold either a single
%               value that should be applied to all nodes, or an nnode x 1
%               cell array of the properties to be applied to each node,
%               respectively.
%
%   Edgeprop:   1 x 1 structure with field names corresponding to a
%               Graphviz edge propery.  Each field can hold either a single
%               value that should be applied to all edges, or an nedge x 1
%               cell array of the properties to be applied to each edge,
%               respectively. nedge = length(find(adj))

% Copyright 2013 Kelly Kearney


% i = source, j = sink
% xy in points
%

% Check input

nnode = size(adj,1);

if ~isequal(size(adj), [nnode nnode])
    error('adj must be nnode x nnode array');
end

if ~isempty(xy) && size(xy,2) ~= 2
    error('xy must be n x 2 array');
end

nedge = length(find(adj));

if nargin < 3 || isempty(prefix)
    prefix = 'node';
end

if nargin < 4 || isempty(Nodeprop)
    Nodeprop = struct();
end

if nargin < 5 || isempty(Edgeprop)
    Edgeprop = struct();
end

isvalid = @(x,n) (iscell(x) && size(x,1)==n) || (ischar(x) && size(x,1) == 1) || isscalar(x);

if ~all(structfun(@(x) isvalid(x,nnode), Nodeprop))
    error('Node properties wrong size');
end

if ~all(structfun(@(x) isvalid(x,nedge), Edgeprop))
    error('Node properties wrong size');
end

% Name of each node

fmt = sprintf('%s%%02d', prefix);
name = cellstr(num2str((1:nnode)', fmt));

% Figure out tail and head node indices

[ii, jj] = ind2sub(size(adj), find(adj));
tail = cellstr(num2str(ii, fmt));
head = cellstr(num2str(jj, fmt));

% Add name, pos, head, and tail fields to node and edge props

Nodeprop.name = name;
if ~isempty(xy)
    Nodeprop.pos = num2cell(xy, 2);
end

Edgeprop.head = head;
Edgeprop.tail = tail;

nodeprops = [fieldnames(Nodeprop) struct2cell(Nodeprop)]';
edgeprops = [fieldnames(Edgeprop) struct2cell(Edgeprop)]';

Node = struct(nodeprops{:});
Edge = struct(edgeprops{:});

% Node = struct('name', name);
% 
% if nargin > 1 && ~isempty(xy)
%     for in = 1:nnode
%         Node(in).pos = xy(in,:);
%     end
% end
% 
% 
% 
% Edge = struct('head', head, 'tail', tail);

A = struct('Graph', [], 'Subgraph', [], 'Node', Node, 'Edge', Edge);

