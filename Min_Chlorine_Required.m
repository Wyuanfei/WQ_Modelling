clc
clear
close("all");

% add EPANET-Matlab toolkit path
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

d = epanet('Net1.inp');

Ctarget = 0.5;
SourceID = '2';

d.setTimeSimulationDuration(6*24*3600);

d.solveCompleteHydraulics;
nnodes = d.getNodeCount;
sourceindex = d.getNodeIndex(SourceID);
d.setQualityType('Chlorine','mg/L','');

d.openQualityAnalysis;
csource = 0.0;
violation = 0;

while (~violation && (csource <= 4.0))
    csource = csource + 0.1;
    d.setNodeSourceQuality(sourceindex, csource);

    d.initializeQualityAnalysis;
    tstep = 1;
    while (~violation && (tstep > 0.0))
        t = d.runQualityAnalysis;
        if (t > 432000)
            for i = 1:nnodes
                c = d.getNodeActualQuality(i);
                if c < Ctarget
                    violation = 1;
                    break;
                end
            end
        end
        tstep = d.nextQualityAnalysisStep;
    end
end

csource












