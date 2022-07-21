clc
clear
close all

epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';

net_id = 'BWFLnet_Sept2021';
run( [epanet_path,'\start_toolkit'])
net = epanet([net_id,'.inp']);

%%
hydraulic_res = net.getComputedHydraulicTimeSeries;

%%
np = net.getLinkPipeCount + net.getLinkPumpCount + net.getLinkValveCount;
nn = net.getNodeJunctionCount;
nt = net.getNodeTankCount;
n0 = net.getNodeReservoirCount;

%%
% take the first 6 hours as example
timestep = net.TimeHydraulicStep;
qepa = hydraulic_res.Flow(1:24,1:np)';
hepa = hydraulic_res.Head(1:24,1:nn)';

%%
lambda = 0.55*ones(size(hydraulic_res.Flow,2),1); % set bulk decay coefficients
net.setQualityType('Chlorine')
net.setNodeSourceQuality(net.NodeIndex,zeros(net.NodeCount,1)); % maybe don't need this...
net.setLinkBulkReactionCoeff(net.LinkIndex, -lambda);
net.setTimeQualityStep(5*60); % maybe don't need this (epanet file is already set to 5 mins)
net.setNodeInitialQuality(net.NodeIndex,zeros(size(hydraulic_res.Head,2))); % zero initial quality
base_cext = ones(n0,1);
pattern_cext = 0.5./(base_cext*ones(1,96));

%%
for i=1:n0
    patternId = sprintf('Res_C_%d',i);
    net.addPattern(patternId,pattern_cext(i,:));
    net.setNodeSourcePatternIndex(net.NodeReservoirIndex(i),net.getPatternIndex(patternId));
    net.setNodeSourceQuality(net.NodeReservoirIndex(i),base_cext(i));
    net.setNodeSourceType(net.NodeReservoirIndex(i),'CONCEN');  
end

%%
quality_res = net.getComputedQualityTimeSeries;
c_nodes_initial = [quality_res.NodeQuality(end,1:nn)';quality_res.NodeQuality(end,net.NodeReservoirIndex)'];

%%
%%% plotting code....
LinkNodesList = net.getLinkNodesIndex;

A = zeros(np,nn+nt);
for k=1:np
    i = LinkNodesList(k,1);
    j = LinkNodesList(k,2);
    A(k,i) = -1;
    A(k,j) = 1;
end

JunctionIdx=double(net.getNodeJunctionIndex);
ReservoirIdx=double(net.getNodeReservoirIndex);
TankIdx=double(net.getNodeTankIndex);
A12 = A(:,JunctionIdx);
A10 = A(:,ReservoirIdx);
A13 = A(:,TankIdx);

%%
XY = zeros(nn+n0+nt,2);
XY(:,1) = net.getNodeCoordinates{1};
XY(:,2) = net.getNodeCoordinates{2};

%% Quality
elev = net.getNodeElevations;
h0 = net.getNodeHydaulicHead(ReservoirIdx);
t = 1;

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

figure(1),
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
labelnode(p,ReservoirIdx,{'Reservoir','Reservoir'});
p.NodeFontSize = 11;
p.NodeLabelColor = 'k';
p.NodeFontWeight = 'bold';
p.EdgeFontSize = 11;
p.EdgeLabelColor = 'k';
p.EdgeFontWeight = 'bold';

% [r,n] = size(varargin{1});
% if n > 1
%     node_value = [varargin{1}(:,t)-elev; h0(:,t) - h0(:,t)];
%     title('Simulated Pressure Head (m)');
% else
%     node_value = varargin{1};
%     title('Simulated CL2 Residual (mg/L)')
% end
node_value = quality_res.NodeQuality(97,:)';
G.Nodes.Value = node_value;
G.Nodes.NodeColors = G.Nodes.Value;
p.NodeCData = G.Nodes.NodeColors;

hcb = colorbar;
hcb.Label.String = 'Simulated CL2 Residual (mg/L)';
hcb.Label.Interpreter = 'latex';

colormap("jet")
axis('off')

%% Flow
edgeweights = abs(qepa(:,1)); % t=1, steady state
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
figure(2),
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
labelnode(p1,ReservoirIdx,{'Reservoir','Reservoir'});
p1.NodeFontSize = 11;
p1.NodeLabelColor = 'k';
p1.NodeFontWeight = 'bold';
p1.EdgeFontSize = 11;
p1.EdgeLabelColor = 'k';
p1.EdgeFontWeight = 'bold';

p1.EdgeCData = G1.Edges.Weight;

hcb = colorbar;
hcb.Label.String = 'Simulated Flow Rates (L/s)';
hcb.Label.Interpreter = 'latex';

colormap("jet")

axis('off')
title('Simulated Flow Rates (L/s)')

%%
% AdjA=sparse(size(A,2),size(A,2));
% 
% for i=1:size(A,1)
%     u=find(A(i,:)==-1);
%     v=find(A(i,:)==1);
%     AdjA(u,v)=1;
%     AdjA(v,u)=1;
% end
% gr = graph(AdjA);
% % alpha1 = epa.cnodes(:,20);%(1/nt)*sum(epa.cnodes(:,2:end,5),2);
% % alpha1(abs(alpha1)==0)=min(abs(alpha1(abs(alpha1)>0)));
% figure,
% p=plot(gr);
% p.XData=XY(:,1);
% p.YData=XY(:,2);
% p.LineWidth=2;
% p.NodeColor='k';
% p.EdgeColor='k';
% p.NodeLabel='';
% p.MarkerSize = 5;
% p.NodeCData = alpha1;
% hcb = colorbar;
% hcb.Label.String = 'Chlorine Conc. (mg/l)';
% %caxis([0,cmax])
% hcb.FontSize = 18;
% hcb.Label.Interpreter = 'latex';
% colormap(flipud(jet))%flipud(jet)
% axis('off')
%%
% Topographic sorting algorithm 
days = 1;
c_nodes = quality_res.NodeQuality';

%%
figure(3),
plot(0:0.25:days*24,c_nodes(3,:)','-b')

xlabel('Time Step','FontWeight','bold')
ylabel('Cl2 Concentration (mg/L)','FontWeight','bold')
legend('EPANET Model','location','best')











