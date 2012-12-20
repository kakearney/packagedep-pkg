function Edge = coloredges(Edge, dc, cmap)
%COLOREDGES Add color field to a Graphviz food web edge structure
%
% Edge = coloredges(Edge, dc, cmap)
%
% This function adds a 'color' field to a food web Edge structure based on
% the fraction of each predator's diet composed of each prey.
%
% Input variables:
%
%   Edge:   edge strucure (see attgraphwrite.m)
%
%   dc:     diet composition matrix, where dc(i,j) specifies the fraction
%           of predator j's diet composed of prey i.
%
%   cmap:   colormap used to color each edge.  The first color will
%           correspond to a dc value of 0 and the last color to a dc value
%           of 1.
%
% Output variables:
%
%   Edge:   edge structure, same as input structure but with added 'color'
%           field

% Copyright 2008 Kelly Kearney

step = linspace(0,1,size(cmap,1));

for iprey = 1:size(dc,1)
    for ipred = 1:size(dc,2)
        if dc(iprey,ipred) > 0
            
            preynode = sprintf('FG%02d', iprey);
            prednode = sprintf('FG%02d', ipred);
            isnode = strcmp(preynode, {Edge.tail}) & strcmp(prednode, {Edge.head});
            
            Edge(isnode).color = rgb2hsv(interp1(step, cmap, dc(iprey,ipred)));
        end
    end
end