clc
clear
close("all")

type simple_objective
type simple_constraint

ObjectiveFunction = @simple_objective;

lb = [0 0];   % Lower bounds
ub = [1 13];  % Upper bounds

ConstraintFunction = @simple_constraint;
nvars = 2;

rng default % For reproducibility
[x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],lb,ub,ConstraintFunction);

%%
options = optimoptions("ga",'PlotFcn',{@gaplotbestf,@gaplotmaxconstr}, ...
    'Display','iter');

[x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],lb,ub, ...
    ConstraintFunction,options)








