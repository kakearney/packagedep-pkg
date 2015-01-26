function Node = compressnodexpos(Node, buffer, vbuf)
%COMPRESSNODEXPOS Remove extra space in the x-direction of a graph
%
% Node = compressnodexpos(Node, maxdist)
%
% This function adjusts the position attribute of each input node to
% eliminate any extra space in the x-direction of a graph.  
%
% Note: right now assumes all nodes are 1" boxes... should update this to
% be more flexible.
%
% Input variables:
%
%   Node:       node structure (see attgraphwrite.m).  Each node must
%               contain a 'pos' field, indicating the current x and y
%               position of the node.
%
%   xbuffer:    minimum horizontal distance, in points, between any two
%               nodes in the graph.
%
%   ybuffer:    minimum vertical distance, in points, between any two nodes
%               in the graph.  If not included, default is 0.
%
% Output variables:
%
%   Node:       node structure identical to input structure except with
%               modified x-coordinates in the 'pos' field.

% Copyright 2008 Kelly Kearney

pos = cat(1, Node.pos);
% xpos = pos(:,1);
% 
% unqxpos = unique(xpos);
% 
% dist = diff(unqxpos);
% dist(dist > maxdist) = maxdist;
% 
% newxpos = [unqxpos(1); unqxpos(1) + cumsum(dist)];
% 
% [loc, loc] = ismember(xpos, unqxpos);
% xpos = newxpos(loc);
% 
% pos = [xpos pos(:,2)];
% 
% for inode = 1:length(Node)
%     Node(inode).pos = pos(inode,:);
% end


% New method... sliding-tiles style

w = 0.5*72;
h = 0.5*72;
if nargin < 3 || isnan(vbuf)
    vbuf = 0;
end

istl = strncmp({Node.name}, '"TL', 3);

nnode = size(pos,1);

l = pos(:,1) - w;
r = pos(:,1) + w;
b = pos(:,2) - h;
t = pos(:,2) + h;

xbox1 = [l l r r l]';
ybox1 = [b t t b b]';

% Same as above, but sliding toward center

xcent = mean(pos(~istl,1));
dis = pos(:,1) - xcent;
dis(istl) = Inf;

[srt, order] = sort(abs(dis));

plotflag = false;
if plotflag
    figure;
    plot(xbox1, ybox1, 'b');
    hold on;
    text(pos(:,1), pos(:,2), cellstr(num2str((1:nnode)')), 'horiz', 'center', 'color', 'b');
    axis equal;
    xyrefline(xcent);
end

tbuf = t + vbuf;
bbuf = b - vbuf;


for in = 1:sum(~istl)
    ii = order(in);
    jj = order(1:in-1);
    
    willhit = (tbuf(ii) <= tbuf(jj) & tbuf(ii) >= bbuf(jj)) | ...
              (bbuf(ii) <= tbuf(jj) & bbuf(ii) >= bbuf(jj));
          
    if any(willhit)
        if sign(dis(ii)) == 1
            ltmp = l(jj(willhit));
            ltmp = ltmp(ltmp+w >= xcent);
            if isempty(ltmp)
                newleft = xcent - w;
            else
                newleft = max(ltmp) + buffer + w*2;   
            end
%             newleft = max(r(jj(willhit))) + buffer;
        else
            ltmp = l(jj(willhit));
            ltmp = ltmp(ltmp+w <= xcent);
            if isempty(ltmp)
                newleft = xcent - w;
            else
                newleft = min(ltmp) - buffer - w*2;
            end
            
%             ltmp = 
%             newleft = l(ii);
%             newleft = min(l(jj(willhit))) - buffer - w;
        end
    else
        newleft = xcent - w;
    end
    dx = l(ii) - newleft;
    l(ii) = newleft;
    r(ii) = r(ii) - dx;
end

lmin = min(l(~istl));
l(istl) = lmin - buffer - w*2;
r(istl) = l(istl) + w*2;

xbox2 = [l l r r l]';
ybox2 = [b t t b b]';
pos = [(l+r)./2 (b+t)./2];
for inode = 1:length(Node)
    Node(inode).pos = pos(inode,:);
end

if plotflag
    plot(xbox2, ybox2, 'r');
    text(pos(:,1), pos(:,2), cellstr(num2str((1:nnode)')), 'horiz', 'center', 'color', 'r');
    set(gca, 'xlim', minmax([xbox2(:); xbox1(:)], 'expand'), 'ylim', minmax([ybox2(:); ybox1(:)], 'expand'));
end





% 
% 
% 
% [bsrt, order] = sort(b);
% 
% 
% for in = 1:length(b)
%     
%     
%     ii = order(in);
%     jj = order(1:in-1);
%     kk = order(in+1:end);
%     
%     
%     willhit = (t(ii) <= t(jj) & t(ii) >= b(jj)) | ...
%               (b(ii) <= t(jj) & b(ii) >= b(jj));
%     if any(willhit)
%         newleft = max(r(jj(willhit))) + buffer;
%     else
%         newleft = lmin;
%     end
%     dx = l(ii) - newleft;
%     l(ii) = newleft;
%     r(ii) = r(ii) - dx;
% end




