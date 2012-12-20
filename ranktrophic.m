function groups = ranktrophic(dietcomp, ispp, nlive, levels)
%RANKTROPHIC Rank functional groups based on trophic level
%
% groups = ranktrophic(dietcomp, ispp, nlive, levels)
%
% This function groups together the functional groups from an food web 
% model based on their approximate trophic level.  The trophic level
% calculation used is derived from the Ecopath model.  The intended purpose
% of this function is to create the rank-matched food web graphs described
% in foodweb2dot.m.
%
% Input variables:
%
%   dietcomp:   diet composition matrix, where dietcomp(i,j) is the
%               fraction of predator j's diet composed of prey i.
%
%   ispp:       logical vector indicating whether each group is a primary
%               producer (true = is)
%
%   nlive:      number of live, non-detrital groups
%
%   levels:     vector of trophic level values to use for grouping.  Each
%               level designates a rank group, and each functional group
%               will be assigned to the level closest to its own trophic
%               level.
%
%
% Output variables:
%
%   groups:     cell array of same length as levels.  Each element holds
%               the indices of functional groups matching that specific
%               level.

% Copyright 2008 Kelly Kearney

% Trophic levels

ngroup = size(dietcomp,1);

trophic = trophiclevel(dietcomp, ispp, nlive, ngroup);
trophic = round(trophic*10) / 10;

% Match to levels

[blah, lev] = arrayfun(@(x) min(abs(x - levels)), trophic);

% Organize functional groups by level

nlev = length(levels);

groups = cell(nlev,1);
for ilevel = 1:nlev
    groups{ilevel} = find(lev == ilevel);
end