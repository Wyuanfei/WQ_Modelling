clear
clc
epanet_path = 'C:\Users\bradw\OneDrive - Imperial College London\9_Software\EPANET-Matlab-Toolkit-master';
run( [epanet_path,'\start_toolkit'])
net = epanet('BWFLnet.inp');

%%% The basic EPANET model includes 24 hours patterns, 
%%% longer time windows can be simulated by modifying 
%%% the simulation duration

nt = 24;
nn = net.NodeJunctionCount;
n0 = net.NodeReservoirCount;
np = net.LinkCount;

%%% Initialize EPANET simulation
net.setQualityType('Chlorine')
net.setNodeSourceQuality(1:nn+n0,zeros(nn+n0,1));

%%% Use this to specify the hydrualic and water quality time steps 
%%%(in seconds)
net.setTimeQualityStep(5*60); 
net.setTimeHydraulicStep(60*60);
days = 1;
net.setTimeSimulationDuration(days*net.getTimeSimulationDuration);

%%% Link Bulk Reacction Coeff (in mg per second)
lambda = 0.55*ones(np,1)./(24*3600);
%%% Injected chlorine at water sources (mg/l)
%%% it can also vary during the day
cext = 0.2*ones(n0,nt); 
%%%% Initial concentrations at nodes (mg/l)
c0 = 0.1*ones(nn+n0,nt);

net.setLinkBulkReactionCoeff(1:np, -lambda);
net.setNodeInitialQuality(net.NodeIndex,c0);
base_cext = ones(n0,1);
pattern_cext = cext./(base_cext*ones(1,size(cext,2))); % extend vector over nt columns 
for i=1:n0
    patternId = sprintf('Res_C_%d',i);
    net.addPattern(patternId,pattern_cext(i,:));
    net.setNodeSourcePatternIndex(net.NodeReservoirIndex(i),net.getPatternIndex(patternId));
    net.setNodeSourceQuality(net.NodeReservoirIndex(i),base_cext(i));
    net.setNodeSourceType(net.NodeReservoirIndex(i),'CONCEN');  
end

hydraulic_res = net.getComputedHydraulicTimeSeries;
quality_res = net.getComputedQualityTimeSeries;
h = hydraulic_res.Head(1:nt,1:nn)';
q = 1e-3*hydraulic_res.Flow(1:nt,:)';

c_nodes = quality_res.NodeQuality';
c_pipes = quality_res.LinkQuality';

%%%% Check that injected concentration at water sources 
%%%% are as expected
figure,plot(0:days*24,c_nodes(nn+1:nn+n0,:)','-')
xlabel('Time Step')
ylabel('Concentration (mg/l)')

