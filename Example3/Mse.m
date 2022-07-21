function f = Mse(x, traindata, LinkIndex, NodeIndex, ReservoirIndex, NodeSele_Idx)
% loadlibrary('epanet2','epanet2')

calllib('epanet2','ENopen','BWFLnet_Sept2021.inp','BWFLnet_Sept2021.rpt','');

k = x(1);
np = length(LinkIndex);
for i = 1:np
    calllib('epanet2','ENsetlinkvalue',LinkIndex(i),6,k);
end

% calllib('epanet2','ENsolveH');
calllib('epanet2','ENsolveQ');
% calllib('epanet2','ENreport')

% sim = zeros(1,6);
% for i = 1:length(sim)
%     sim(i) = calllib('epanet2','ENgetnodevalue',i,"EN_HEAD",0);
% end
nn = length(NodeIndex);
n0 = length(ReservoirIndex);

for i = 1:(nn+n0)
    [a sim_all(i,1)] = calllib('epanet2','ENgetnodevalue',i,12,0);
end
sim = sim_all(NodeSele_Idx);

obs = traindata;
% calllib('epanet2','ENclose');
f = (1/size(obs,1)/size(obs,2))*sum(sum((sim - obs).^2));
% [a h2]=calllib('epanet2','ENgetnodevalue',1,11,0);
% [a v1]=calllib('epanet2','ENgetlinkvalue',1,9,0);


% calllib(‘epanet2’,‘ENgetnodevalue’,1,11,0)
% 
% calllib(‘epanet2’,‘ENgetlinkvalue’,1,9,0)
end

