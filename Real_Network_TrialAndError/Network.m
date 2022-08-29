%% Basic details
clc
clear
close all

epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master'; % Change the folder path
net_id = 'BWFLnet_MSc_2022_calibrated';
run( [epanet_path,'\start_toolkit'])

net = epanet([net_id,'.inp']);
load("wq_data.mat");

%% Basic parameters
% Save element count variables
nn = net.NodeJunctionCount;
n0 = net.NodeReservoirCount;
np = net.LinkCount; % count of pipes and valves
D = net.getLinkDiameter';

% Save node and link index vectors
Reservoir_Idx = net.getNodeReservoirIndex;
Junction_Idx = net.getNodeJunctionIndex;
Link_Idx = double(net.getLinkIndex);

% Nodes name and chlorine concentrations
Node_all_Name = {'BW9','BW7','BW1','BW2','BW3','BW4','BW5','BW6','BW12'};
Junction_Main = net.getNodeIndex(wq_data.node_ids([1,4,7,9]));
Main_Name = Node_all_Name([1,4,7,9]);
Junction_Hydrant = net.getNodeIndex(wq_data.node_ids([2,5,8]));
Hydrant_Name = Node_all_Name([2,5,8]);
Reservoir_Name = Node_all_Name([6,3]);


%% Graph creation
% Create A12 and A10 incidence matrices
LinkNodesList = net.getLinkNodesIndex;

A = zeros(np,nn+n0);
for k=1:np
    i = LinkNodesList(k,1);
    j = LinkNodesList(k,2);
    A(k,i) = -1;
    A(k,j) = 1;
end

A12 = A(:,Junction_Idx);
A10 = A(:,Reservoir_Idx);
A12 = sparse(A12);
A10 = sparse(A10);

% Obstain node XY and elevation information
XY = zeros(nn+n0,2);
XY(:,1) = net.getNodeCoordinates{1};
XY(:,2) = net.getNodeCoordinates{2};
elev = double(net.getNodeElevations(Junction_Idx))';

% Create adjacency matrix
A = [A12,A10];
AdjA = sparse(size(A,2),size(A,2));

for k = 1:size(A,1)
    node_in = find(A(k,:) == -1);
    node_out = find(A(k,:) == 1);
    AdjA(node_in,node_out) = 1;
    AdjA(node_out,node_in) = 1;
end
gr = graph(AdjA);

%% Graph plotting
% Plot the sensor location on the network map
figure
g1 = plot(gr);
g1.XData = XY(:,1);
g1.YData = XY(:,2);
g1.LineWidth = 2;
g1.EdgeColor = 'b';
g1.MarkerSize = 0.01;
g1.NodeColor = 'b';
g1.NodeLabel = '';
highlight(g1,Junction_Main,'NodeColor','green','Marker','s','MarkerSize',8);
labelnode(g1,Junction_Main,Main_Name);
highlight(g1,Junction_Hydrant,'NodeColor','red','Marker','s','MarkerSize',8);
labelnode(g1,Junction_Hydrant,Hydrant_Name);
highlight(g1,Reservoir_Idx,'NodeColor','k','Marker','s','MarkerSize',10);
labelnode(g1,Reservoir_Idx,Reservoir_Name);
g1.NodeFontSize = 8;
g1.NodeLabelColor = 'k';
g1.NodeFontWeight = 'bold';
g1.EdgeFontSize = 8;
g1.EdgeLabelColor = 'k';
g1.EdgeFontWeight = 'bold';
axis('off')
title('Sensor Locations in Network')
