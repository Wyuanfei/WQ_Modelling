% Get hydraulic model from EPANET
% Initial version downloaded from InfrasSense Labs research group Github on 20 October 2021
% Minor changes made by Bradley W Jenks

clc
clear
close all

% add path to toolkit

epanet_path = 'C:\Users\bradw\OneDrive - Imperial College London\9_Software\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);
filename = '2loopsNet.inp';
data_filename = '2loopsNet';

net = epanet(filename);



%%%%%%%%%%%%%%%%%%%%%%%%%%% Nodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Order: [junctions reservoirs tanks];
nodeIdx=double(net.getNodeIndex);
nodeIds=net.getNodeNameID;
JunctionIdx=double(net.getNodeJunctionIndex);
ReservoirIdx=double(net.getNodeReservoirIndex);
TankIdx=double(net.getNodeTankIndex);

NodeIdListMap = containers.Map(nodeIds,nodeIdx);

elev = double(net.getNodeElevations(JunctionIdx))';

if ~isempty(TankIdx)
    tank_elev = double(net.getNodeElevations(TankIdx));
    tank_initial_levels = double(net.getNodeTankInitialLevel(TankIdx));
    tank_diameter = double(net.getNodeTankDiameter(TankIdx));
    tank_max_level = double(net.getNodeTankMaximumWaterLevel(TankIdx));
    tank_min_level = double(net.getNodeTankMinimumWaterLevel(TankIdx));
    nn=double(net.getNodeJunctionCount);
    n0=double(net.getNodeReservoirCount);
    n_tanks = double(net.getNodeTankCount);
    
else
    tank_elev = [];
    tank_initial_levels = [];
    tank_diameter = [];
    tank_max_level = [];
    tank_min_level = [];
    nn=double(net.getNodeJunctionCount);
    n0=double(net.getNodeReservoirCount);
    n_tanks = 0;
end

% XY coordinates of nodes
XY = zeros(nn+n0+n_tanks,2);
XY(:,1) = net.getNodeCoordinates{1};
XY(:,2) = net.getNodeCoordinates{2};

% Extract junction demand and reservoir head pattern indices
Categories = net.getNodeDemandCategoriesNumber;
Patterns = net.getPattern;
PatternIdx_all = net.getNodeDemandPatternIndex;
PatternIdx = net.getNodePatternIndex;

% Pattern manipulation for SS WQ model comparison
Patterns_SSa = Patterns(:,1);
Patterns_SSb = repmat(Patterns_SSa,1,size(Patterns,2));
net.setPatternMatrix(Patterns_SSb);

% Solve EPANET hydraulic simulation
epanet_results = net.getComputedHydraulicTimeSeries;
nl=size(epanet_results.Head,1);
H_epanet = epanet_results.Head(:,JunctionIdx)';
Q_epanet = epanet_results.Flow(:,:)';
tank_H_epanet =  epanet_results.Head(:,TankIdx)';

demands = epanet_results.Demand(:,JunctionIdx)';
base_d = net.getNodeBaseDemands{1};
demands(find(base_d(JunctionIdx)==0),:)=0;

H0 = epanet_results.Head(:,ReservoirIdx)';


%%%%%%%%%%%%%%%%%%%%%%%%%%% Links %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
np=double(net.getLinkPipeCount + net.getLinkPumpCount + net.getLinkValveCount);

PipeIdx = net.getLinkPipeIndex;
%PipeIds=net.getLinkPipeNameID;
ValveIdx = net.getLinkValveIndex;
%ValveIds=net.getLinkValveNameID;
PumpIdx = net.getLinkPumpIndex;
%PumpIds=net.getLinkPumpNameID;

% Order: [pipes valves pumps]
linkIds = net.getLinkNameID;
linkIdx = double(net.getLinkIndex);

L = net.getLinkLength';
D = net.getLinkDiameter'; 

C = net.getLinkRoughnessCoeff';

SimOptionsMap = containers.Map();
SimOptionsMap('Headloss') = net.getBinOptionsInfo.BinOptionsHeadloss;

% Unit conversions where required
if strcmp(net.getUnits.LinkFlowUnits,'CMH')
    demands = demands/3600;
    Q_epanet = Q_epanet/3600;
    if strcmp(net.getUnits.LinkPipeDiameterUnits,'millimeters')
        D = D/1000; %conversion from mm to m
    end
    
elseif strcmp(net.getUnits.LinkFlowUnits,'LPS')
    demands = demands/1000;
    Q_epanet = Q_epanet/1000;
    if strcmp(net.getUnits.LinkPipeDiameterUnits,'millimeters')
        D = D/1000; %conversion from mm to m
    end
elseif strcmp(net.getUnits.LinkFlowUnits,'GPM')
    gpm2lps=0.06309;
    inch2mm=25.400;
    ft2metres=0.3048;
    H0_all = ft2metres*H0_all;
    elev = ft2metres*elev;
    if ~isempty(TankIdx)
        tank_elev = ft2metres*tank_elev;
        tank_initial_levels = ft2metres*tank_initial_levels;
        tank_diameter = ft2metres*tank_diameter;
        tank_max_level = ft2metres*tank_max_level;
        tank_min_level = ft2metres*tank_min_level;
        tank_H_epanet = ft2metres*tank_H_epanet;
    end
    L = ft2metres*L;
    D = (inch2mm*D)/1000;
    demands = (gpm2lps*demands)/1000;
    Q_epanet = (gpm2lps*Q_epanet)/1000;
    H_epanet = (ft2metres*H_epanet);
end

% Print headloss formulation method used
hl_meth = SimOptionsMap('Headloss');

% Assign appropriate headloss coefficients based on formulation method
if strcmp(SimOptionsMap('Headloss'),'H-W')
    n_exp = 1.852*ones(np,1);
elseif strcmp(SimOptionsMap('Headloss'),'D-W')
    n_exp = 2*ones(np,1);
end

C(ValveIdx) = net.LinkMinorLossCoeff(ValveIdx);
% Arbritrary length (twice diameter) set to valves?
L(ValveIdx) = 2*D(ValveIdx);
n_exp(ValveIdx)=2;



%%%%%%%%%%%%%%%%%%%%%%%%%% Connectivity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LinkNodesList = net.getLinkNodesIndex;

A = zeros(np,nn+n0+n_tanks);
for k=1:np
    i = LinkNodesList(k,1);
    j = LinkNodesList(k,2);
    A(k,i) = -1;
    A(k,j) = 1;
end

A12 = A(:,JunctionIdx);
A10 = A(:,ReservoirIdx);
A13 = A(:,TankIdx);

A12 = sparse(A12);
A10 = sparse(A10);
A13 = sparse(A13);


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OriginalPRVs =  {'V1598','V1614','V1815','V1950','V1972',...
%                  'V1990','V1998','V2000','V2086','V2087',...
%                  'V2090','V2093','V2094','V2096','V2097',...
%                  'V2126','V2265','V2709','V2710','V2711',...
%                  'V2712','V2713','V2714','V2715','V2716'};
% OriginalBoosters = {'J1603','J1665'};
% OriginalResWTP = {'R5','R6','R8','R9'};

% LinkInitialStatus =  net.getLinkInitialStatus;
% closed_links = find(LinkInitialStatus==0);
% 
% A12(closed_links ,:) = [];
% A10(closed_links ,:) = [];
% n_exp(closed_links ) = [];
% np = np - length(closed_links);
% C(closed_links )=[];
% D(closed_links )=[];
% L(closed_links )=[];
% linkIds(closed_links)=[];
% linkIdx = 1:np;
% Q_epanet(closed_links,:)=[];


LinkIdListMap = containers.Map(linkIds,linkIdx);

PRVs= [];
PRVs_labels = [];
BVs=[];
C_BVs=[];

% Control valve indices (values below refer to BWFLnet)
% PRVs = [LinkIdListMap('link_2214');LinkIdListMap('link_2312');LinkIdListMap('link_2602')];
% PRVs_labels = [];
% BVs = [LinkIdListMap('link_2605');LinkIdListMap('link_2606')];
% C_BVs = epanet_results.Setting(:,BVs)';

% Water quality data
s_qual = net.getNodeSourceQuality;

% Save extracted network information to data structure
save(data_filename,'BVs','C_BVs','nl','A12','A10','nn','n0','np','nodeIds','linkIds',...
    'JunctionIdx','ReservoirIdx','LinkIdListMap','NodeIdListMap','XY','PRVs','PRVs_labels',...
     'elev','H0','demands','L','D','C','n_exp','ValveIdx','SimOptionsMap','s_qual','H_epanet','Q_epanet','Patterns_SSb')   