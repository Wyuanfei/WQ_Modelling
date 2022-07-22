function f = Mse_R(x, qual_obs,SelectIdx,Roughness)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');

k = [x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),x(9),x(10),x(11)];

R = Roughness;
Junction_SelectIdx = SelectIdx;

theta = ones(2281,1); % units of m/day
for i = 1:2281
    if abs(R(i) - 0) <= 0.01
        theta(i) = k(1);
    elseif abs(R(i) - 0.1000) <= 0.01
        theta(i) = k(2);
    elseif abs(R(i) - 0.1399) <= 0.01
        theta(i) = k(3);
    elseif abs(R(i) - 1.5267) <= 0.01
        theta(i) = k(4);
    elseif abs(R(i) - 2.1576) <= 0.01
        theta(i) = k(5); 
    elseif abs(R(i) - 9.0114) <= 0.01
        theta(i) = k(6); 
    elseif abs(R(i) - 10.3677) <= 0.01
        theta(i) = k(7); 
    elseif abs(R(i) - 11.6809) <= 0.01
        theta(i) = k(8); 
    elseif abs(R(i) - 14.8687) <= 0.01
        theta(i) = k(9); 
    elseif abs(R(i) - 16.2377) <= 0.01
        theta(i) = k(10); 
    else
        theta(i) = k(11);
    end
end

for i = 1:2281
    calllib('epanet2','ENsetlinkvalue',i,6,theta(i));
end

% calllib('epanet2','ENsolveH');
% calllib('epanet2','ENsolveQ');
% calllib('epanet2','ENreport');

calllib('epanet2','ENopenQ');
calllib('epanet2','ENinitQ',0);
tleft=1; QsN=[]; 
t = 0;
while (tleft>0)
    %Add code which changes something related to quality
    [errcode, t] = calllib('epanet2','ENrunQ',t);
    for i = 1:7
        [errcode, QsNi(i,1)] = calllib('epanet2','ENgetnodevalue',Junction_SelectIdx(i),12,0);
    end
    QsN=[QsN, QsNi];
    [errcode, tleft] = calllib('epanet2','ENnextQ',tleft);
end
calllib('epanet2','ENcloseQ');

obs = qual_obs;
sim = QsN(:,2*96+1:3*96);

f = (1/size(obs,1)/size(obs,2))*sum(sum((sim - obs).^2));


end

