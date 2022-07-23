function f = Mse_DandR(x, qual_obs,SelectIdx,Diameter,Roughness)
% loadlibrary('epanet2','epanet2')

% calllib('epanet2','ENopen','example1.inp','example1.rpt','');
obs = qual_obs;
k = [x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),x(9),x(10),x(11),x(12),x(13),x(14),x(15),...
    x(16),x(17),x(18),x(19),x(20),x(21),x(22)];

% for i = 1:2281
%     calllib('epanet2','ENsetlinkvalue',i,6,k(1));
% end
D = Diameter;
R = Roughness;
Junction_SelectIdx = SelectIdx;

% Roughness for bulk decay
theta = ones(2281,1); % units of m/day
for i = 1:2281
    if abs(R(i) - 0) <= 0.01
        if D(i) <= 150
            theta(i) = k(1);
        else
            theta(i) = k(2);
        end
    elseif abs(R(i) - 0.1000) <= 0.01
        if D(i) <= 150
            theta(i) = k(3);
        else
            theta(i) = k(4);
        end
    elseif abs(R(i) - 0.1399) <= 0.01
        if D(i) <= 150
            theta(i) = k(5);
        else
            theta(i) = k(6);
        end
    elseif abs(R(i) - 1.5267) <= 0.01
        if D(i) <= 150
            theta(i) = k(7);
        else
            theta(i) = k(8);
        end
    elseif abs(R(i) - 2.1576) <= 0.01
        if D(i) <= 150
            theta(i) = k(9);
        else
            theta(i) = k(10);
        end
    elseif abs(R(i) - 9.0114) <= 0.01
        if D(i) <= 150
            theta(i) = k(11);
        else
            theta(i) = k(12);
        end
    elseif abs(R(i) - 10.3677) <= 0.01
        if D(i) <= 150
            theta(i) = k(13);
        else
            theta(i) = k(14);
        end
    elseif abs(R(i) - 11.6809) <= 0.01
        if D(i) <= 150
            theta(i) = k(15);
        else
            theta(i) = k(16);
        end
    elseif abs(R(i) - 14.8687) <= 0.01
        if D(i) <= 150
            theta(i) = k(17);
        else
            theta(i) = k(18);
        end 
    elseif abs(R(i) - 16.2377) <= 0.01
        if D(i) <= 150
            theta(i) = k(19);
        else
            theta(i) = k(20);
        end
    else
        if D(i) <= 150
            theta(i) = k(21);
        else
            theta(i) = k(22);
        end
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

