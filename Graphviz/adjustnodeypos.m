function Node = adjustnodeypos(Node, trophic)
%ADJUSTNODEYPOS Adjust the y-position of food web nodes
%
% New = adjustnodeypos(Node, trophic)
%
% This function adjusts the position of food web nodes based on the trophic
% level of each functional group.  Node must contain trophic level nodes,
% indicated by the name "TLx.x", that create an approximate y-axis.  The
% remaining nodes correspond, respectively, to the values in the second
% input.
%
% Input variables:
%
%   Node:       n x 1 structure of node definitions
%
%   trophic:    m x 1 array of trophic levels, corresponding to the
%               non-axis (see above) nodes in Node.
%
% Output variables:
%
%   New:        n x 1 structure, identical to Node except that the second
%               column of the 'pos' field has been adjusted.

% Copyright 2008 Kelly Kearney

% Find trophic nodes and their trophic level values

names = {Node.name};
istl = strncmp('"TL', names, 3);

tlnames = names(istl);
tlnames = regexprep(tlnames, '"TL', ''); 
tlnames = regexprep(tlnames, '"', '');
tllevel = cellfun(@str2num, tlnames);

% Calculate new y positions

pos  = cat(1, Node.pos);
tlypos = pos(istl,2);

pp = polyfit(tllevel, tlypos', 1);

newypos = polyval(pp, [tllevel'; trophic]);

% Change pos field value

for inode = 1:length(Node)
    Node(inode).pos(2) = newypos(inode);
end




