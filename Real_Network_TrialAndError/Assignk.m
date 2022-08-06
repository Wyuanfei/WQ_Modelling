function lambdaNew = Assignk(lambda,k,R_CData)

for i = 1:length(lambda)
    for j = 1:length(k)
        if R_CData(i) == j
            lambdaNew(i) = k(j);
        else
            continue
        end
    end
end

end

