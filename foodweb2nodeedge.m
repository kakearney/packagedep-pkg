function [Node, Edge] = foodweb2nodeedge(dietcomp, varargin);
%FOODWEB2NODEEDGE Create node and edge structures for a food web
%
% [Node, Edge] = ewein2nodeedge(dietcomp, label)
%
% This function creates the node and edge structures for a food web graph,
% where each node represents a functional group, and each edge runs from a
% predator node to a prey node (this directionality is the reverse from the
% usual way of considering flow of food/biomass up a food web, but is
% necessary to achieve the typical vertical structure of a food web when
% rendered with dot, where top predators are shown above their prey).
%
%
% Input variables:
%
%   dietcomp:   diet composition matrix, where dietcomp(i,j) is the
%               fraction of predator j's diet composed of prey i.
%
%   labels:     Cell array of strings, corresponding to labels for each
%               functional group node
%
% Output variables:
%
%   Node:       ngroup x 1 structure with the following fields:
%
%               name:   'FGxx', where xx is a 2-digit group number
%
%               label:  label strings (this field only added if labels were
%                       supplied in the input)
%
%   Edge:       nedge x 1 structure with the following fields
%
%               head:   name of prey node
%
%               tail:   name of predator node

% Copyright 2008 Kelly Kearney

ngroup = size(dietcomp,1);

% Predator/prey connections (who eats who?)

ilink = find(dietcomp);
[prey, predator] = ind2sub(size(dietcomp), ilink);

% Functional group nodes

name = cellstr(num2str((1:ngroup)', 'FG%02d'));

if nargin > 1
    label = cellfun(@(a) sprintf('"%s"', a), varargin{1}, 'uni', 0);
    Node = struct('name', name, 'label', label);
else
    Node = struct('name', name);
end

% Feeding edges

head = cellstr(num2str(prey, 'FG%02d'));
tail = cellstr(num2str(predator, 'FG%02d'));

Edge = struct('head', head, 'tail', tail);



