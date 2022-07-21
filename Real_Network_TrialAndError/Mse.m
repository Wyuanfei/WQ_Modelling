function f = Mse(x, qual_obs,SelectIdx,Diameter)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');

k = [x(1),x(2),x(3),x(4)];


% for i = 1:2281
%     calllib('epanet2','ENsetlinkvalue',i,6,k(1));
% end
D = Diameter;

theta = ones(2281,1); % units of m/day
for i = 1:2281
    if D(i) <= 75
        theta(i) = k(1);
    elseif D(i) > 75 && D(i) <= 150
        theta(i) = k(2);
    elseif D(i) > 150 && D(i) <= 250
        theta(i) = k(3);
    else
        theta(i) = k(4);
    end
end

for i = 1:2281
    calllib('epanet2','ENsetlinkvalue',i,6,theta(i));
end

calllib('epanet2','ENsolveH');
calllib('epanet2','ENsolveQ');
calllib('epanet2','ENreport');

% sim = zeros(1,6);
% for i = 1:length(sim)
%     sim(i) = calllib('epanet2','ENgetnodevalue',i,"EN_HEAD",0);
% end

for i = 1:7
    [a sim(i,1)] = calllib('epanet2','ENgetnodevalue',SelectIdx(i),12,0);
end

obs = qual_obs(:,end);
% calllib('epanet2','ENclose');
f = (1/size(obs,1)/size(obs,2))*sum(sum((sim - obs).^2));
% [a h2]=calllib('epanet2','ENgetnodevalue',1,11,0);
% [a v1]=calllib('epanet2','ENgetlinkvalue',1,9,0);


% calllib(‘epanet2’,‘ENgetnodevalue’,1,11,0)
% 
% calllib(‘epanet2’,‘ENgetlinkvalue’,1,9,0)
end

