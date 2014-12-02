function [fpack,ppack] = packagedep(files, pngfile)
%PACKAGEDEP Parse and plot file dependencies for file(s)
%
% [fpack,ppack] = packagedep(files, pngfile)
%
% Returns file and toolbox dependencies for a file or files, and also plots
% a directory tree of those files via graphviz.
%
% Input variables:
%
%   files:      string or cell array of strings, files to be analyzed (only
%               files and dependencies on the path will be found)
%
%   pngfile:    name of files for directory tree plot

% Copyright 2014 Kelly Kearney

[fpack, ppack] = matlab.codetools.requiredFilesAndProducts(files);

pkfiles = regexprep(fpack, '/Users/kakearney/Documents/MatlabPathFiles/', '');
    
[txt, A, stxt, nidx] = graphvizdirtree(pkfiles);
rendergraph('dot', pngfile, txt);

