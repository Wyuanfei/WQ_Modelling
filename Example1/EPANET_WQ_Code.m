clc
clear
close all

epanet_path = ...;

net_id = 'BWFLnet_Sept2021';
run( [epanet_path,'\start_toolkit'])
net = epanet([net_id,'.inp']);
hydraulic_res = net.getComputedHydraulicTimeSeries;

qepa = hydraulic_res.Flow(1:24,1:np)';
hepa = hydraulic_res.Head(1:24,1:nn)';

np = size(qepa,1);
nn = ...;
nt = size(qepa,2);

lambda = 0.55*ones(size(hydraulic_res.Flow,2),1); % set bulk decay coefficients
net.setQualityType('Chlorine')
net.setNodeSourceQuality(net.NodeIndex,zeros(net.NodeCount,1)); % maybe don't need this...
net.setLinkBulkReactionCoeff(net.LinkIndex, -lambda);
net.setTimeQualityStep(5*60); % maybe don't need this (epanet file is already set to 5 mins)
net.setNodeInitialQuality(net.NodeIndex,zeros(size(hydraulic_res.Head,2))); % zero initial quality
base_cext = ones(n0,1);
pattern_cext = 0.5./(base_cext*ones(1,nt));
for i=1:n0
    patternId = sprintf('Res_C_%d',i);
    net.addPattern(patternId,pattern_cext(i,:));
    net.setNodeSourcePatternIndex(net.NodeReservoirIndex(i),net.getPatternIndex(patternId));
    net.setNodeSourceQuality(net.NodeReservoirIndex(i),base_cext(i));
    net.setNodeSourceType(net.NodeReservoirIndex(i),'CONCEN');  
end
quality_res = net.getComputedQualityTimeSeries;
c_nodes_initial = [quality_res.NodeQuality(end,1:nn)';quality_res.NodeQuality(end,net.NodeReservoirIndex)'];


%%% plotting code....

A = [network.A12 network.A10];
XY = network.XY;
AdjA=sparse(size(A,2),size(A,2));
for i=1:size(A,1)
    u=find(A(i,:)==-1);
    v=find(A(i,:)==1);
    AdjA(u,v)=1;
    AdjA(v,u)=1;
end
gr = graph(AdjA);

alpha1 = epa.cnodes(:,20);%(1/nt)*sum(epa.cnodes(:,2:end,5),2);
alpha1(abs(alpha1)==0)=min(abs(alpha1(abs(alpha1)>0)));
figure,
p=plot(gr);
p.XData=XY(:,1);
p.YData=XY(:,2);
p.LineWidth=2;
p.NodeColor='k';
p.EdgeColor='k';
p.NodeLabel='';
p.MarkerSize = 5;
p.NodeCData = alpha1;
hcb = colorbar;
hcb.Label.String = 'Chlorine Conc. (mg/l)';
%caxis([0,cmax])
hcb.FontSize = 18;
hcb.Label.Interpreter = 'latex';
colormap(flipud(jet))%flipud(jet)
axis('off')


