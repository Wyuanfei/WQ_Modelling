function f = Mse(x, qual_obs,SelectIdx,Diameter)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');

k = [x(1),x(2),x(3),x(4)];


% for i = 1:2281
%     calllib('epanet2','ENsetlinkvalue',i,6,k(1));
% end
D = Diameter;
Junction_SelectIdx = SelectIdx;

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

obs = qual_obs(:,end);
sim = QsN(:,2*96+1:3*96);

f = (1/size(obs,1)/size(obs,2))*sum(sum((sim - obs).^2));


end

