function [Node, Edge] = dottextread(dottextfile)
%DOTTEXTREAD Read a plain text Graphviz dot file
%
% [Node, Edge] = dottextread(dottextfile)
%
% This function reads the information in a dot plain text file.  This is
% the type of file that is produced when a dot graph is exported as text,
% not the original dot file.
%
% Input variables:
%
%   dottextfile:    dot text file name
%
% Output variables:
%
%   Node:           n x 1 structure describing the n nodes found in the
%                   file, with the following fields:
%
%                   name:       node name (behind-the-scenes name)
%
%                   x:          x position, in pixels
%
%                   y:          y position
%
%                   width:      width of node shape
%
%                   height:     height of node shape
%
%                   label:      node label (visible label of final plot)
%
%                   style:      style of outline
%
%                   shape:      node shape
%
%                   color:      color of node outline
%
%                   fillcolor:  color of node fill
%
%   Edge:           m x 1 structure describing the m edges found in the
%                   file, with the following fields:
%
%                   tail:       name of node where edge starts
%
%                   head:       name of node where edge ends
%
%                   x:          1 x p vector of x coordinates of edge
%
%                   y:          1 x p vector of y coordinates of edge
%
%                   style:      edge style
%
%                   color:      edge color

% Copyright 2007 Kelly Kearney

% Read file into cell array

fileText = textread(dottextfile, '%s', 'delimiter', '\n');

% Check for weird <> behavior

weirdstr = regexp(fileText, '<.*>', 'match');
isemp = cellfun(@isempty, weirdstr);
weirdstr = weirdstr(~isemp);
weirdstr = cellfun(@(x) x{1}, weirdstr, 'uni', 0);
if ~isempty(weirdstr)
    fprintf('Warning: weird bracket-thing happening in %s:\n', dottextfile);
    fprintf('         %s\n', weirdstr{:});
    fileText = regexprep(fileText, '<', '"');
    fileText = regexprep(fileText, '>', '"');
end

% Protect quotes strings

quoteLoc = strfind(fileText, '"');
for iline = 1:length(fileText)
    if ~isempty(quoteLoc{iline})
        loc = reshape(quoteLoc{iline}, 2, []);
        for istr = 1:size(loc,2)
            oldstr = fileText{iline}(loc(1,istr):loc(2,istr));
            newstr = regexprep(oldstr, '\s', '_');
            fileText{iline} = regexprep(fileText{iline}, oldstr, newstr);
        end
    end
end

% Determine which lines describe nodes and edges

isnode = regexp(fileText, '^node');
isnode = ~cellfun('isempty', isnode);
isedge = regexp(fileText, '^edge');
isedge = ~cellfun('isempty', isedge);


% Parse node data

[nodename, xnode, ynode, width, height, label, style, shape, color, fillcolor] = cellfun(@(x) strread(x, 'node %s %f %f %f %f %s %s %s %s %s'), fileText(isnode));
label = regexprep(label, '"', '');
label = regexprep(label, '_', ' ');

xnode = num2cell(xnode);
ynode = num2cell(ynode);
width = num2cell(width);
height = num2cell(height);

Node = cell2struct([nodename, xnode, ynode, width, height, label, style, shape, color, fillcolor], {'name', 'x', 'y', 'width', 'height', 'label', 'style', 'shape', 'color', 'fillcolor'}, 2);

% Parse edge data

edgeText = fileText(isedge);
nedge = length(edgeText);

[tail, head, x, y, style, color] = deal(cell(nedge, 1));
nedgeNode = zeros(nedge,1);

for iedge = 1:nedge
    
    temp = textscan(edgeText{iedge}, '%*s %s %s %d', 1);
    
    tail{iedge} = temp{1}{1};
    head{iedge} = temp{2}{1};
    nedgepoints = temp{3};
    
    format = ['%*s %*s %*s %*d ' repmat('%f ', 1, nedgepoints*2) '%s %s'];
    temp = textscan(edgeText{iedge}, format, 1);
    
    xy = cell2mat(reshape(temp(1:end-2), 2, []));
    x{iedge} = xy(1,:);
    y{iedge} = xy(2,:);
    
    style{iedge} = temp{end-1}{1};
    color{iedge} = temp{end}{1};
   
end 

Edge = cell2struct([tail, head, x, y, style, color], {'tail', 'head', 'x', 'y', 'style', 'color'}, 2);

