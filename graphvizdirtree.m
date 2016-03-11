function [txt, A, stxt, nidx] = graphvizdirtree(files)
%GRAPHVIZDIRTREE Create directory tree plot
%
% [txt, A, stxt, nidx] = graphvizdirtree(files)
%
% Input variables:
%
%   files:  cell array including all files to include in the tree
%
% Output variables:
%
%   txt:    cell array of strings, text of graphviz .dot file (can be
%           passed to rendergraph.m)
%
%   A:      dot graph structure used to create txt. Doesn't include
%           subgraph edges  
%
%   stxt:   subgraph text.  If you modify graph settings (by
%           changing/adding fields of A) and pass to attgraphwrite, you'll
%           need to tack this on to the end of the resulting text (before
%           the last })
%
%   nidx:   index of the Node structure in A that corresponds to the input
%           files

% First, figure out adjacency matrix of folder/file nodes

files = cellfun(@(x) regexp(x, filesep, 'split'), files, 'uni', 0);

idx = [];
nidx = zeros(size(files));
for ii = 1:length(files)
    n = length(files{ii});
    nodetmp = cell(n,1);
    for in = 1:length(nodetmp)
        nodetmp{in} = fullfile(files{ii}{1:in});
    end
    if ii == 1
        node = nodetmp;
    else
        [tf,loc] = ismember(nodetmp, node);
        node = [node; nodetmp(~tf)];
    end
    [tf,loc] = ismember(nodetmp,node);
    nidx(ii) = loc(end);
    idx = [idx; loc(1:n-1) loc(2:end)];
end

idx = unique(idx, 'rows');

nnode = length(node);

[pth, nlabel, ex] = cellfun(@fileparts, node, 'uni', 0);
nlabel = cellfun(@(x,y) [x y], nlabel, ex, 'uni', 0);


% adj = sparse(idx(:,1), idx(:,2), ones(size(idx,1),1), nnode, nnode);

% Rather than pointing directly from one folder to another, want vertical
% line dropping from a folder and then branching to subfolders/files

srcsnk = [...
    idx(:,1)        idx(:,2)+nnode
    idx(:,2)+nnode  idx(:,2)];

nedge = size(srcsnk,1);

adj = sparse(srcsnk(:,1), srcsnk(:,2), ones(nedge,1), nnode*2, nnode*2);

subgraph = cell(nnode, 1);
for ii = 1:nnode
    cidx = find(adj(ii,:));
    subgraph{ii} = [ii cidx];
end
issingle = cellfun(@length, subgraph) == 1;
subgraph = subgraph(~issingle);

rmidx = sub2ind(size(adj), idx(:,1), idx(:,2)+nnode);
adj(rmidx) = 0;

% Create file

A = graph2dot(adj, [], 'n');

[A.Node(1:nnode).shape] = deal('box');
[A.Node(1:nnode).label] = deal(nlabel{:});
[A.Node(1:nnode).width] = deal(2);
[A.Node(1:nnode).fixedsize] = deal('true');
[A.Node(nnode+1:end).shape] = deal('point');
A.Graph.rankdir = 'LR';
A.Graph.concentrate = 'true';

txt = attgraphwrite(A);

stxt = cell(size(subgraph));
for is = 1:length(subgraph)
    
    chain = sprintf('n%02d -> ', subgraph{is});
    stxt{is} = ['{rank=same;' chain(1:end-4) '[arrowhead=none]}'];
end

txt = [txt(1:end-1); stxt; txt(end)];


    
% {
%         rank=same;
%         b_dir_1 -> b_point_1 -> b_point_2 [arrowhead=none]
%     }

%


