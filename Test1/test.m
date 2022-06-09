%% Example 21
clc
clear
close("all");

% add EPANET-Matlab toolkit path
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

d = epanet('Net1.inp');

%%
d.setOptionsPatternDemandMultiplier(10);
d.setTimeSimulationDuration(0);
d.solveCompleteHydraulics;
deficient_nodes = d.getStatistic.DeficientNodes;
check_error(deficient_nodes == 4);

%%
type = 'PDA';
pmin = 0;
preq = 0.1;
pexp = 0.5;
d.setDemandModel(type,pmin,preq,pexp);
d.solveCompleteHydraulics;

deficient_nodes_PDA = d.getStatistic.DeficientNodes;
demand_reduction = d.getStatistic.DemandReduction;
check_error(deficient_nodes_PDA == 6);
check_error(abs(demand_reduction - 32.66) < 0.01);

%%
junctionIndex_12 = d.getNodeIndex('12');
demand_deficit_12 = d.getNodeDemandDeficit(junctionIndex_12);
check_error(abs(demand_deficit_12)<0.01);

%%
junctionIndex_21 = d.getNodeIndex('21');
demand_deficit_21 = d.getNodeDemandDeficit(junctionIndex_21);
check_error(abs(demand_deficit_12 - 413.67)<0.01);

d.unload

%% Example 22
% add EPANET-Matlab toolkit path
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

d = epanet('Net1.inp');
%%
Nindex = d.getNodeIndex('2');
Lindex = d.getLinkIndex('110');

d.setNodeTankInitialLevel(Nindex,130);
d.setNodeTankMaximumWaterLevel(Nindex,130);

% Set duration to 1 hr.
d.setTimeSimulationDuration(3600);

% Solve hydraulics with default of no tank spillage allowed.
d.solveCompleteHydraulics;

% Check that tank remains full.
level = d.getNodeTankInitialLevel(Nindex);
check_error(abs(level - 130) < 0.001);

% Check that there is no spillage.
spillage = d.getNodeActualDemand(Nindex);
check_error(abs(spillage) < 0.001);

% Check that inflow link is closed.
inflow = d.getLinkFlows(Lindex);
check_error(abs(inflow) < 0.001);

% Turn tank overflow option on.
d.setNodeTankCanOverFlow(Nindex,1);

% Solve hydraulics again.
d.solveCompleteHydraulics;

% Check that tank remains full.
level = d.getNodeTankInitialLevel(Nindex);
check_error(abs(level - 130) < 0.001);

% Check that there is spillage equal to tank inflow
% (inflow has neg. sign since tank is start node of inflow pipe).
spillage = d.getNodeActualDemand(Nindex);
check_error(abs(spillage) > 0.001);

inflow = d.getLinkFlows(Lindex);
check_error(abs(-spillage - inflow) < 0.001);

% Save project to file and then close it.
d.saveInputFile('net1_overflow.inp');
d.unload

% Re-open saved file & run it.
d = epanet('net1_overflow.inp');
Result = d.solveCompleteHydraulics;

% Check that tank spillage has same value as before.
spillage2 = d.getNodeActualDemand(Nindex);
check_error(abs(spillage2 - spillage) < 0.001);

% Unload library.
d.unload

%% Example 23
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

d = epanet('Net1.inp');

Linkindex = 3;
disp(d.getLinkNodesIndex(Linkindex));
LinkID = d.getLinkNameID(Linkindex);


d.plot('nodes','yes','links','yes');

startNode = 4;
endNode = 6;
d.setLinkNodesIndex(Linkindex,startNode,endNode);
disp(d.getLinkNodesIndex(Linkindex));

d.plot('nodes','yes','links','yes');

%% Example 24
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);
d = epanet('Net1.inp');


while ~isempty(d.getPatternIndex)
    indexPattern = d.getPatternIndex;
    d.deletePattern(indexPattern(1));
end

d.saveInputFile('Net1_NoPattern.inp');
d.unload;

%% Example 25
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);
d = epanet('Net1.inp');

%%
disp('Node name IDs:');
disp(d.getNodeNameID);

junction_prefix = 'J';
Link_prefix = 'L';
Tank_prefix = 'T';

for i = d.getNodeIndex
    d.setNodeNameID(i, [junction_prefix,'-',num2str(i)]);
end

disp('New Node name IDs:');
disp(d.getNodeNameID);

d.unload
%% Example_26
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

clc;
clear H;

tic
try
    unloadlibrary('epanet2');
catch
end
d = epanet('Net1.inp');
number_scenarios = 100;

parfor i = 1:number_scenarios
    loadlibrary('epanet2','epanet2.h')
    d.loadEPANETFile(d.TempInpFile);
    elevations = d.getNodeElevations - d.getNodeElevations*rand(1)*.5;
    d.setNodeElevations(elevations);

    H{i} = d.getComputedHydraulicTimeSeries;
    d.closeNetwork;
end
d.unload
toc

%% Example EX2
clc
clear
close("all");
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);
d = epanet('Net1.inp');

nodeID = '32';
r = 1:0.5:10;
NodeIndex = d.getNodeIndex(nodeID);

NodeBaseDemand = d.getNodeBaseDemands{1}(NodeIndex);
NodeFireDemand = NodeBaseDemand.*r;

d.openHydraulicAnalysis;
P = [];
for i = 1:length(NodeFireDemand)
    d.setNodeBaseDemands(NodeIndex, NodeFireDemand(i));
    d.initializeHydraulicAnalysis;
    d.runHydraulicAnalysis;
    P(i) = d.getNodePressure(NodeIndex);
end
d.closeHydraulicAnalysis;

plot(NodeFireDemand,P,'-x');

%% Example EX_3











