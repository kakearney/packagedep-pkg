function varargout = rendergraph(renderer, outfile, varargin)
%RENDERGRAPH Render a graph using Graphviz functions
%
% rendergraph(renderer, outfile, infile)
% rendergraph(renderer, outfile, intext)
% rendergraph(renderer, outfile, Node, Edge, Graph, Subgraph)
% rendergraph(renderer, outfile, All)
% [status,result] = rendergraph(renderer, outfile, ...)
%
% This function provides a shortcut to a limited number of Graphviz
% rendering functions.  To access the full range of functionality, you can
% use the Graphviz command-line functions directly.
%
% Input variables:
%
%   renderer:   string, Graphviz utility, along with additional flags
%               (excepting -o and -T flags for output file and format),
%               used to render graph
%
%   outfile:    name of output file.  The extension will determine the
%               output format: txt = Graphviz simple text, png = png, ps =
%               postscript for pdf, bmp = bmp, svg = svg
%
%   infile:     name of dot input file to be rendered
%
%   intext:     cell array of strings holding dot input to be rendered
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
%
% Output variables:
%
%   status:     0 is Graphviz utility was run successfully, 1 if not
%
%   result:     standard output of Graphviz utility, including any warning
%               messages or errors.  If rendering fails and the user did
%               not specify any outputs, this string will be displayed.
%       
      
% Copyright 2008 Kelly Kearney


%------------------------
% Check input
%------------------------

% Output file

[outpath, outfiletemp, outext] = fileparts(outfile);

ext = {'.txt', '.png', '.ps', '.bmp', '.svg'};
format = {'plain', 'png', 'ps2', 'bmp', 'svg'};

isfmt = strcmp(ext, outext);

if any(isfmt)
    outformat = format{isfmt};
else
    error('Output file must be .txt, .png, .ps, .svg, or .bmp');
end

% Renderer

% rend = {'dot', 'neato', 'neaton'};
% isrend = strcmp(rend, renderer);
% 
% if ~any(isrend)
%     error('Renderer must be either ''dot'', ''neato'', or ''neaton''');
% end


% Determine whether structs, text, or file was input, and write to
% temporary file if necessary

tempfile = 'rendergraphtemp.dot';

if nargin == 3 && iscell(varargin{1})
    dotfile = tempfile;
    printtextarray(varargin{1}, dotfile);
elseif nargin == 3 && ischar(varargin{1}) && exist(varargin{1}, 'file')
    dotfile = varargin{1};
elseif nargin == 6 || (nargin == 3 && isstruct(varargin{1}))
    dotfile = tempfile;
    printtextarray(attgraphwrite(varargin{:}), dotfile);
else
    error('Input must be a filename, a series of attributed-graph statements, or Node-Edge-etc structures');
end
   
%------------------------
% Render output file
%------------------------

cmd = sprintf('%s %s -o %s -T%s', renderer, dotfile, outfile, outformat);
[s,r] = system(cmd);

if exist(tempfile, 'file')
%     delete(tempfile);
end

%------------------------
% Output
%------------------------

if nargout == 1
    varargout{1} = s;
elseif nargout == 2
    varargout{1} = s;
    varargout{2} = r;
elseif nargout == 0
    if s
        fprintf('Warning: Graph rendering failed:\n%s', r);
    end
end