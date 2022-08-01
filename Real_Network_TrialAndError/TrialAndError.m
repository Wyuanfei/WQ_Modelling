function [mse,Sim] = TrialAndError(mse_function,lambda,Obs,Junc_Idx,np)

    for j = 1:np
        calllib('epanet2','ENsetlinkvalue',j,6,-lambda(j));
    end
    calllib('epanet2','ENopenQ');
    calllib('epanet2','ENinitQ',0);
    tleft=1; Sim=[]; 
    t = 0;
    while (tleft>0)
        [errcode, t] = calllib('epanet2','ENrunQ',t);
        for k = 1:size(Obs,1)
            [errcode, Sim_k(k,1)] = calllib('epanet2','ENgetnodevalue',Junc_Idx(k),12,0);
        end
        Sim = [Sim, Sim_k];
        [errcode, tleft] = calllib('epanet2','ENnextQ',tleft);
    end
    calllib('epanet2','ENcloseQ');
    mse = mse_function(Sim(:,2*96+1:3*96),Obs);

end

