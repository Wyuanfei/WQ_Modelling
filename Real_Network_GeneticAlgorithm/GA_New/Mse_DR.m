function f = Mse_DR(x, qual_obs,SelectIdx,Diameter,Roughness)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');
obs = qual_obs;
k = [x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),x(9),x(10),x(11),x(12),x(13),x(14),x(15)];


% for i = 1:2281
%     calllib('epanet2','ENsetlinkvalue',i,6,k(1));
% end
D = Diameter;
R = Roughness;
Junction_SelectIdx = SelectIdx;

% Roughness for bulk decay
thetaR = ones(2281,1); % units of m/day
for i = 1:2281
    if abs(R(i) - 0) <= 0.01
        thetaR(i) = k(1);
    elseif abs(R(i) - 0.1000) <= 0.01
        thetaR(i) = k(2);
    elseif abs(R(i) - 0.1399) <= 0.01
        thetaR(i) = k(3);
    elseif abs(R(i) - 1.5267) <= 0.01
        thetaR(i) = k(4);
    elseif abs(R(i) - 2.1576) <= 0.01
        thetaR(i) = k(5); 
    elseif abs(R(i) - 9.0114) <= 0.01
        thetaR(i) = k(6); 
    elseif abs(R(i) - 10.3677) <= 0.01
        thetaR(i) = k(7); 
    elseif abs(R(i) - 11.6809) <= 0.01
        thetaR(i) = k(8); 
    elseif abs(R(i) - 14.8687) <= 0.01
        thetaR(i) = k(9); 
    elseif abs(R(i) - 16.2377) <= 0.01
        thetaR(i) = k(10); 
    else
        thetaR(i) = k(11);
    end
end

for i = 1:2281
    calllib('epanet2','ENsetlinkvalue',i,7,thetaR(i));
end

% Diameter for link decay
thetaD = ones(2281,1); % units of m/day
for i = 1:2281
    if D(i) <= 75
        thetaD(i) = k(12);
    elseif D(i) > 75 && D(i) <= 150
        thetaD(i) = k(13);
    elseif D(i) > 150 && D(i) <= 250
        thetaD(i) = k(14);
    else
        thetaD(i) = k(15);
    end
end

for i = 1:2281
    calllib('epanet2','ENsetlinkvalue',i,7,thetaD(i));
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
    for i = 1:size(obs,1)
        [errcode, QsNi(i,1)] = calllib('epanet2','ENgetnodevalue',Junction_SelectIdx(i),12,0);
    end
    QsN=[QsN, QsNi];
    [errcode, tleft] = calllib('epanet2','ENnextQ',tleft);
end
calllib('epanet2','ENcloseQ');


sim = QsN(:,2*96+1:3*96);

f = (1/size(obs,1)/size(obs,2))*sum(sum((sim - obs).^2));


end

