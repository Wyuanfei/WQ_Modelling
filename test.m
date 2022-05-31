clc
clear
close("all");

% add EPANET-Matlab toolkit path
epanet_path = 'E:\Program Files\MATLAB\R2021b\toolbox\epanet\EPANET-Matlab-Toolkit-master';
run([epanet_path,'\start_toolkit']);

d = epanet('Net1.inp');

%%
d.getComputedTimeSeries;

