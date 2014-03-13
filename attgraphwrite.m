function filedata = attgraphwrite(varargin)
%ATTGRAPHWRITE Write an attributed graph text file
%
% filedata = attgraphwrite(Node, Edge, Graph, Subgraph)
% filedata = attgraphwrite(All)
%
% This function returns the text of an attributed graph file, the input
% format for the Graphviz library.  See www.graphviz.org for more details
% on this software.
%
% Input variables:
%
%   Node:       n x 1 structre, describing each node in the graph.  The
%               fieldnames of the structure correspond to node properties.
%               See dot documentation for a list of properties and possible
%               values. All fields are optional except for the following:
%
%               name:   string to be used as node name
%
%   Edge:       n x 1 structure, describing each edge in the graph.  The
%               fieldnames of the structure correspond to edge properties.
%               See dot documentation for  list of properties and possible
%               values. All fields are optional except for the following:
%
%               head:   string with name of head node
%
%               tail:   string with name of tail node
%
%   Graph:      1 x 1 structure with graph properties.  The fieldnames of
%               the structure correspond to edge properties.  See dot
%               documentation for  list of properties and possible values.
%               If empty, all defaults are used.
%
%   Subgraph:   n x 1 structure with properties of any subgraphs.
%               Currently only nodes, not edges, can be included in a
%               subgraph.  All fields are optional except the following:
%
%               nodes:  cell array of strings, names of each node to be
%                       included in the subgraph.
%
%   All:        1 x 1 structure holding with fields Node, Edge, Graph, and
%               Subgraph, each holding the structures described above.

% Copyright 2008 Kelly Kearney

%---------------------
% Check input
%---------------------

if nargin == 1 && all(isfield(varargin{1}, {'Node', 'Edge', 'Graph', 'Subgraph'}))
    Node = varargin{1}.Node;
    Edge = varargin{1}.Edge;
    Graph = varargin{1}.Graph;
    Subgraph = varargin{1}.Subgraph;
elseif nargin == 4
    Node = varargin{1};
    Edge = varargin{2};
    Graph = varargin{3};
    Subgraph = varargin{4};
end

%---------------------
% Translate properties 
% into formatted 
% strings
%---------------------

% Graph properties

if isempty(Graph)
    graphstr = cell(0,1);
else
    graphprop = fieldnames(Graph);
    graphval = struct2cell(Graph);
    graphstr = graphpropstr(graphprop, graphval);
end

% Node definitions

nnode = length(Node);

nodestr = cell(nnode,1);
for inode = 1:nnode
    nodestr{inode} = node2str(Node(inode));
end

% Edge definitions

nedge = length(Edge);

edgestr = cell(nedge,1);
for iedge = 1:nedge
    edgestr{iedge} = edge2str(Edge(iedge));
end

% Subgraph definitions

nsgraph = length(Subgraph);
subgraphstr = cell(nsgraph,1);
for is = 1:nsgraph
    subgraphstr{is} = subgraph2str(Subgraph(is));
end

%---------------------
% Write to file
%---------------------

filedata = [{'digraph matlabattgraph {'}; graphstr; nodestr; edgestr; subgraphstr; {'}'}];    

%--------------------------
% Create node attribute 
% strings
%--------------------------

function str = node2str(Node)

attrib = fieldnames(Node);
val = struct2cell(Node);

default = cellfun(@isempty, val);
notattrib = strcmpi(attrib, 'name');

attrib = attrib(~default & ~notattrib);
val = val(~default & ~notattrib);

attributes = attribstr(attrib, val);
str = sprintf('%s %s', Node.name, attributes); 


%--------------------------
% Create edge attribute 
% strings
%--------------------------

function str = edge2str(Edge)
attrib = fieldnames(Edge);
val = struct2cell(Edge);

default = cellfun(@isempty, val);
notattrib = strcmpi(attrib, 'tail') | strcmpi(attrib, 'head');

attrib = attrib(~default & ~notattrib);
val = val(~default & ~notattrib);

attributes = attribstr(attrib, val);
str = sprintf('%s->%s %s', Edge.tail, Edge.head, attributes); 

%--------------------------
% Create subgraph attribute 
% strings
%--------------------------

function str = subgraph2str(Subgraph)

attrib = fieldnames(Subgraph);
val = struct2cell(Subgraph);

[isspecial, loc] = ismember(attrib, {'nodes', 'name'});
default = cellfun('isempty', val);

% notattrib = strcmpi(attrib, 'nodes');

attrib = attrib(~default & ~isspecial);
val = val(~default & ~isspecial);

attributes = graphpropstr(attrib, val);
 
subnodestr = sprintf(';%s', Subgraph.nodes{:});

if isempty(attrib)
    subnodestr = subnodestr(2:end);
end

if any(loc == 2)
    str = sprintf('subgraph %s {%s%s}', Subgraph.name, attributes, subnodestr);
else
    str = sprintf('{%s%s}', attributes, subnodestr);
end


%--------------------------
% Create general attribute 
% strings
%--------------------------

function str = attribstr(param, val)

if isempty(param)
    str = '';
else

    is1 = cellfun(@ischar, val);
    is2 = cellfun(@(x) isscalar(x) && isnumeric(x), val);
    is3 = cellfun(@isnumeric, val) & ~is2;
    is4 = cellfun(@(x) islogical(x) && isscalar(x), val);

    str = cell(1, length(param));

    for iatt = 1:length(param)
        if is1(iatt)
            if isempty(regexp(val{iatt}, '^".*"$')) && ~isempty(regexp(val{iatt}, '\W'))
                str{iatt} = sprintf('%s="%s"', param{iatt}, val{iatt});
            else
                str{iatt} = sprintf('%s=%s', param{iatt}, val{iatt});
            end
        elseif is2(iatt)
            str{iatt} = sprintf('%s=%.2f', param{iatt}, val{iatt});
        elseif is3(iatt)
            temp = num2str(val{iatt}, '%.2f,');
            temp = ['"' temp(1:end-1) '"'];
            str{iatt} = sprintf('%s=%s', param{iatt}, temp);
        elseif is4(iatt)
            if val{iatt}
                str{iatt} = sprintf('%s=true', param{iatt});
            else
                str{iatt} = sprintf('%s=false', param{iatt});
            end
        end
    end

    format = ['[' repmat('%s,', 1, length(param)-1) '%s]'];
    str = sprintf(format, str{:});
end

%--------------------------
% Create graph property 
% strings
%--------------------------

function str = graphpropstr(param, val)

if isempty(param)
    str = '';
else

    is1 = cellfun(@ischar, val);
    is2 = cellfun(@(x) isscalar(x) && isnumeric(x), val);
    is3 = cellfun(@isnumeric, val) & ~is2;
    is4 = cellfun(@(x) islogical(x) && isscalar(x), val);

    str = cell(1, length(param));

    for iatt = 1:length(param)
        if is1(iatt)
            if isempty(regexp(val{iatt}, '^".*"$')) && ~isempty(regexp(val{iatt}, '\W'))
                str{iatt} = sprintf('%s="%s"', param{iatt}, val{iatt});
            else
                str{iatt} = sprintf('%s=%s', param{iatt}, val{iatt});
            end
        elseif is2(iatt)
            str{iatt} = sprintf('%s=%.2f', param{iatt}, val{iatt});
        elseif is3(iatt)
            temp = num2str(val{iatt}, '%.2f,');
            temp = ['"' temp(1:end-1) '"'];
            str{iatt} = sprintf('%s=%s', param{iatt}, temp);
        elseif is4(iatt)
            if val{iatt}
                str{iatt} = sprintf('%s=true', param{iatt});
            else
                str{iatt} = sprintf('%s=false', param{iatt});
            end
        end
    end

    format = [repmat('%s;', 1, length(param)-1) '%s'];
    str = sprintf(format, str{:});
end
    
