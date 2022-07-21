function [c, ceq] = simple_constraint(x)
%SIMPLE_CONSTRAINT Nonlinear inequality constraints.

%   Copyright 2005-2007 The MathWorks, Inc.

c = [1.5 + x(1)*x(2) + x(1) - x(2); 
     -x(1)*x(2) + 10];

% No nonlinear equality constraints:
ceq = [];

end