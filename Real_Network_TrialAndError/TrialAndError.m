function [mse_train,mse_val,Sim] = TrialAndError(mse_function,theta_kw,Obs,Junc_Idx,np,order)

    for j = 1:np
        calllib('epanet2','ENsetlinkvalue',j,7,-theta_kw(j));
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
    Sim = Sim(:,1:end-1);
    mse_train = mse_function(Sim(order,2*96+1:3*96),Obs(order,2*96+1:3*96));
    mse_val = mse_function(Sim(order,3*96+1:end),Obs(order,3*96+1:end));

end

