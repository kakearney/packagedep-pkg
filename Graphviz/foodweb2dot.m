function Fw = foodweb2dot(varargin);
%FOODWEB2DOT Creates Graphviz structures for a food web
%
% Fw = foodweb2dot(names, dietcomp, ispp, nlive, param1, val1, ...);
% Fw = foodweb2dot(Ewein, param1, val1, ...);
%
% This function returns several versions of a graph for a food web, which
% can be rendered via Grahpviz utilities.
%
% Input variables:
%
%   names:      n x 1 cell array of strings, names of each functional group
%               that will be used to label each node.
%
%   dietcomp:   n x n diet composition matrix, where dietcomp(i,j) is the
%               fraction of predator j's diet composed of prey i.
%
%   ispp:       n x 1 logical vector indicating whether each functional
%               group is a primary producer or not (true = is)
%
%   nlive:      scalar, number of live, non-detrital groups in the food
%               web.  All nonlive groups must be listed at the end of each
%               array, as in an Ecopath model.
%
% Optional input variables (entered as param/value pairs):
%
%   trophicint: Interval used to create trophic level axis for the
%               rank-matched graph (described below).  Default = 1.
%
%   scale:      Scaling used for all labels.  By default (scale = 1), font
%               size is set at 14 pt, but depending on the size of the full
%               graph may need to increased to be legible.
%
%   xbuffer:    Maximum horizontal distance between any two nodes, in
%               inches, assuming that all nodes were placed at the same
%               vertical level. This option can be used to reduce total
%               graph size, which is sometimes excessively wide due to
%               dot's method of positioning nodes to reduce overlap.
%               Setting this to NaN (the default) uses the original
%               dot-calculated positions.
%
%   ybuffer:    Maximum distance between any two nodes vertically; this is
%               used to limit the compression in the x-direction (assuming
%               xbuffer is assigned) so two nodes do not end up stacked too
%               closely on top of each other.
%
% Output variables:
%
%   Fw:         1 x 3 structure with fields Node, Edge, Graph, and
%               Subgraph, describing the properties of the food web graphs
%               (see attgraphwrite for details of these structures).  Fw(1)
%               relies on dot's positioning algorithms to arrange the
%               various nodes and edges, and is meant to be rendered via
%               dot.  Fw(2) attempts to approximate trophic level in the y
%               direction by adding a trophic level axis consisting of
%               nodes labeled TLX.X, where X.X is the trophic level, with
%               all functional group nodes set to rank=same with the
%               closest of these trophic level nodes.  This is also meant
%               to be redered via dot.  Fw(3) keeps the same trophic level
%               axis but adjusts the functional group nodes so that they
%               are at their exact trophic level rather than the
%               approximations used in Fw(2).  This graph should be
%               rendered using neato with the -n option.  For most purposes
%               Fw(3) is the desired result, but it can be usefull to see
%               the previous two graphs to see how that final graph was
%               progressively built.

% Copyright 2008 Kelly Kearney

%-----------------------------
% Parse and check input
%-----------------------------

if isstruct(varargin{1}) && all(isfield(varargin{1}, {'name', 'dc', 'pp', 'nlive'}))
    B = varargin{1};
    names = B.name;
    dietcomp = B.dc;
    ispp = B.pp == 1;
    nlive = B.nlive;
    pv = varargin(2:end);
else
    [names, dietcomp, ispp, nlive] = deal(varargin{1:4});
    pv = varargin(5:end);
end

% Check sizes

ngroup = length(names);

if ~(isvector(names) && iscell(names) && all(cellfun(@ischar, names)))
    error('Names must be a vector cell array of strings');
end

if ~isequal(size(dietcomp), [ngroup ngroup])
    error('Diet composition matrix must be ngroup x ngroup array');
end

if ~all(dietcomp(:) >= 0 & dietcomp(:) <= 1)
    error('Diet composition values must be between 0 and 1');
end

if ~(islogical(ispp) && length(ispp) == ngroup)
    error('Third input must be a logical array the same length as names');
end

if ~(isscalar(nlive)  && isnumeric(nlive))
    error('Fourth input must be scalar indicating number of live groups');
end

% Optional parameters

Options.trophicint = 1;
Options.scale = 1;
Options.xbuffer = NaN;
Options.ybuffer = NaN;

Options = parse_pv_pairs(Options, pv);

%-----------------------------
% Create graph with no node
% position modifications
%-----------------------------

% Create basic nodes

[A.Node, A.Edge] = foodweb2nodeedge(dietcomp, names);

[A.Node.width] = deal(1);
[A.Node.shape] = deal('box');
[A.Node.height] = deal(1);
[A.Node.fixedsize] = deal(true);

A.Graph = [];
A.Subgraph = [];

%-----------------------------
% Create approximate graph 
% using rank-matching 
%-----------------------------

B = A;

% Group nodes by matching each node to the closest input trophic level

tl = trophiclevel(dietcomp, ispp, nlive, ngroup);
trophic = 1:Options.trophicint:(max(tl)+Options.trophicint);

trophic = sort(trophic, 'descend');
ntrophic = length(trophic);

trophicGroups = ranktrophic(dietcomp, ispp, nlive, trophic);

tlNodeName = arrayfun(@(x) sprintf('"TL%.1f"', x), trophic, 'uni', 0);
nodeName = {A.Node.name};

subgroup = cell(length(trophicGroups),1);
for igroup = 1:length(trophicGroups)
    subgroup{igroup} = [tlNodeName(igroup), nodeName(trophicGroups{igroup})];
end

% Add subgraphs defining nodes of the same rank

B.Subgraph = struct('nodes', subgroup, 'rank', 'same');
  
% Add trophic level axis nodes

TrophicNode = struct('name', tlNodeName, 'shape', 'plaintext');
TrophicEdge = struct('tail', tlNodeName(1:end-1), 'head', tlNodeName(2:end));
ntedge = length(TrophicEdge);

B.Node = catstruct(1, TrophicNode', B.Node);
B.Edge = catstruct(1, TrophicEdge', B.Edge);

%-----------------------------
% Create better graph using
% y-position adjustments
%-----------------------------

C = B;
C.Subgraph = [];

% Render the rank-matched graph to a plain text file

[s,r] = rendergraph('dot', 'tempfw2d.txt', B.Node, B.Edge, B.Graph, B.Subgraph);
if s
    error('Rendering of temporary text output of rank-matched file failed:\n %s', r);
end

% Read in the node and edge positions from the text file

[NewNode, NewEdge] = dottextread('tempfw2d.txt');
delete('tempfw2d.txt');

nodepos = [[NewNode.x]' [NewNode.y]'];

for inew = 1:length(NewNode)
    [tf, iold] = ismember(NewNode(inew).name, {C.Node.name});
    C.Node(iold).pos = nodepos(inew,:) .* 72;
end

% Adjust y positions to proper trophic level

C.Node = adjustnodeypos(C.Node, tl);

% Adjust x positions to eliminate extra space

if ~isnan(Options.xbuffer)
    C.Node = compressnodexpos(C.Node, Options.xbuffer*72, Options.ybuffer*72);
end

%-----------------------------
% Combine into one structure
%-----------------------------

Fw = cat(1, A, B, C);

%-----------------------------
% Set properties
%-----------------------------

for igraph = 1:length(Fw)
    
    isaxis = strncmp('"TL', {Fw(igraph).Edge.head}, 3); 
    
    % Set arrowhead and arrowtail shapes so point from prey to predator
    
    [Fw(igraph).Edge(~isaxis).arrowhead] = deal('none');
    [Fw(igraph).Edge(~isaxis).arrowtail] = deal('normal');
    
    % Remove arrows from trophic level axis edges
    
    [Fw(igraph).Edge(isaxis).arrowhead] = deal('none');
    [Fw(igraph).Edge(isaxis).arrowtail] = deal('none');
    
    % Scale font size
    
    [Fw(igraph).Node.fontsize] = deal(14*Options.scale);
    
end

Graph = struct('splines', 'spline', ...
               'overlap', 'scale', ...
               'outputorder', 'edgesfirst');
           
[Fw.Graph] = deal(Graph);






