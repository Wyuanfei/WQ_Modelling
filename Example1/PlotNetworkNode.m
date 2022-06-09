function [G,p] = PlotNetwork(modeldata,model,t,varargin)
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
%load(data_filename,'A12','A10','XY','ReservoirIdx','BVs','H0_all','elev');

A12 = model.A12_d(:,:,t);
A10 = model.A10;
XY = model.XY;
elev = model.elev;
h0 = modeldata.H0;
ReservoirIdx = model.ReservoirIdx;
BVs = model.BVs;

A = [A12,A10];
AdjA = sparse(size(A,2),size(A,2));
for i = 1:size(A,1)
    u = find(A(i,:) == -1);
    v = find(A(i,:) == 1);
    edgemap(i,:) = [u v i];
    
    AdjA(u,v) = 1;
   
end  

% if ~isnan(edgeweights)
%     AdjA = AdjA + AdjA.'; % need symmetric adjacency matrix
% end

edgemap = sortrows(edgemap);

G = digraph(AdjA);
G.Edges.edgemap = edgemap(:,3);

if BVs ~= 0
    for k = 1:size(BVs,1)
        b = find(G.Edges{:,3} == BVs(k));
        BV_idx(:,k) = double(G.Edges{b,1});
        BV_label(k) = b;
    end
end

p = plot(G,'XData',XY(:,1),'YData',XY(:,2));
p.ShowArrows = 'on';
p.LineWidth = 1;
p.MarkerSize = 5;
p.LineWidth = 1;
p.NodeLabel = '';
axis('off')
p.EdgeColor = 'k';
%p.NodeColor = 'b';
highlight(p,ReservoirIdx,'NodeColor','k','Marker','s','MarkerSize',10);
highlight(p,BV_idx(1,:),BV_idx(2,:),'EdgeColor','k','LineWidth',5,'NodeColor','k','Marker','o','MarkerSize',10);
labelnode(p,ReservoirIdx,{'Reservoir','Reservoir'});
labeledge(p,BV_label,{'BV','BV'});
p.NodeFontSize = 11;
p.NodeLabelColor = 'k';
p.NodeFontWeight = 'bold';
p.EdgeFontSize = 11;
p.EdgeLabelColor = 'k';
p.EdgeFontWeight = 'bold';

[r,n] = size(varargin{1});
if n > 1
    node_value = [varargin{1}(:,t)-elev; h0(:,t) - h0(:,t)];
    title('Simulated Pressure Head (m)');
else
    node_value = varargin{1};
    title('Simulated CL2 Residual (mg/L)')
end

G.Nodes.Value = node_value;
G.Nodes.NodeColors = G.Nodes.Value;
p.NodeCData = G.Nodes.NodeColors;

colorbar
colormap(jet)

axis('off')

end

