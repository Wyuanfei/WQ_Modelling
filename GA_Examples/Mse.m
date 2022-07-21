function f = Mse(x, head_obs)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');

C = [x(1),x(2),x(3),x(4),x(5),x(6)];
for i = 1:6
    calllib('epanet2','ENsetlinkvalue',i,2,C(i));
end

calllib('epanet2','ENsolveH');
% calllib('epanet2','ENsolveQ')
% calllib('epanet2','ENreport')

% sim = zeros(1,6);
% for i = 1:length(sim)
%     sim(i) = calllib('epanet2','ENgetnodevalue',i,"EN_HEAD",0);
% end
sim = zeros(1,6);
for i = 1:6
    [a sim(i)] = calllib('epanet2','ENgetnodevalue',i,10,0);
end

obs = head_obs;
% calllib('epanet2','ENclose');
f = (1/size(obs,1)/size(obs,2))*sum((sim - obs).^2);
% [a h2]=calllib('epanet2','ENgetnodevalue',1,11,0);
% [a v1]=calllib('epanet2','ENgetlinkvalue',1,9,0);


% calllib(‘epanet2’,‘ENgetnodevalue’,1,11,0)
% 
% calllib(‘epanet2’,‘ENgetlinkvalue’,1,9,0)
end

