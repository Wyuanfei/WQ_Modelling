function [G1,p1,edgemap] = PlotNetwork(model,t,Q)
% Returns
%
% INPUT:
%    [filename] = A local .mat file containing A12, A10, and junctionXYData
% OUTPUT:
%  [G] = graph object
%  [p] = figure object
% Waldron 2017

% data_filename = 'BWFLnetData';

%====================
%load(data_filename,'A12','A10','XY','ReservoirIdx','BVs');

A12 = model.A12_d(:,:,t);
A10 = model.A10;
XY = model.XY;
ReservoirIdx = model.ReservoirIdx;
BVs = model.BVs;

if nargin == 3
    edgeweights = abs(Q(:,t));
else
    edgeweights = nan; %no weighted edges
end

% edgeweights = abs(Q(:,1)); %no weighted edges

A = [A12,A10];
AdjA = sparse(size(A,2),size(A,2));
for i = 1:size(A,1)
    u = find(A(i,:) == -1);
    v = find(A(i,:) == 1);
    edgemap(i,:) = [u v i];
    if isnan(edgeweights)
        AdjA(u,v) = 1;
    else
        AdjA(u,v) = edgeweights(i);
    end
end  

% if ~isnan(edgeweights)
%     AdjA = AdjA + AdjA.'; % need symmetric adjacency matrix
% end

edgemap = sortrows(edgemap);

G1 = digraph(AdjA);
G1.Edges.edgemap = edgemap(:,3);

if BVs ~= 0
    for k = 1:size(BVs,1)
        b = find(G1.Edges{:,3} == BVs(k));
        BV_idx(:,k) = double(G1.Edges{b,1});
        BV_label(k) = b;
    end
end

p1 = plot(G1,'XData',XY(:,1),'YData',XY(:,2));
p1.ShowArrows = 'on';
%p.LineWidth = 1;
p1.MarkerSize = 0.05;
p1.LineWidth = 3;
p1.NodeLabel = '';
axis('off')
p1.EdgeColor = 'k';
p1.NodeColor = 'b';
highlight(p1,ReservoirIdx,'NodeColor','k','Marker','s','MarkerSize',10);
highlight(p1,BV_idx(1,:),BV_idx(2,:),'EdgeColor','r','LineWidth',5,'NodeColor','k','Marker','o','MarkerSize',10);
labelnode(p1,ReservoirIdx,{'Reservoir','Reservoir'});
labeledge(p1,BV_label,{'BV','BV'});
p1.NodeFontSize = 11;
p1.NodeLabelColor = 'k';
p1.NodeFontWeight = 'bold';
p1.EdgeFontSize = 11;
p1.EdgeLabelColor = 'k';
p1.EdgeFontWeight = 'bold';

p1.EdgeCData = G1.Edges.Weight;

colorbar
colormap(jet)

axis('off')
title('Simulated Flow Rates (L/s)')

end

