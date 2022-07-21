function f = vectorized_fitness(x,p1,p2)
%VECTORIZED_FITNESS Summary of this function goes here
%   Detailed explanation goes here
f = p1 *(x(:,1).^2 - x(:,2)).^2 + (p2 - x(:,1)).^2;
end

