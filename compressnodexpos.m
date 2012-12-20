function Node = compressnodexpos(Node, maxdist)
%COMPRESSNODEXPOS Remove extra space in the x-direction of a graph
%
% Node = compressnodexpos(Node, maxdist)
%
% This function adjusts the position attribute of each input node to
% eliminate any extra space in the x-direction of a graph.  Space is
% defined assuming that all nodes were moved to the same y-coordinates.
%
% Input variables:
%
%   Node:       node structure (see attgraphwrite.m).  Each node must
%               contain a 'pos' field, indicating the current x and y
%               position of the node.
%
%   maxdist:    maximum horizontal distance, in points, between any two
%               nodes in the graph.
%
% Output variables:
%
%   Node:       node structure identical to input structure except with
%               modified x-coordinates in the 'pos' field.

% Copyright 2008 Kelly Kearney

pos = cat(1, Node.pos);
xpos = pos(:,1);

unqxpos = unique(xpos);

dist = diff(unqxpos);
dist(dist > maxdist) = maxdist;

newxpos = [unqxpos(1); unqxpos(1) + cumsum(dist)];

[loc, loc] = ismember(xpos, unqxpos);
xpos = newxpos(loc);

pos = [xpos pos(:,2)];

for inode = 1:length(Node)
    Node(inode).pos = pos(inode,:);
end


