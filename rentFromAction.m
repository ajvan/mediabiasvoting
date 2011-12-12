function rent = rentFromAction(incumbent, naMean, npMean, pi, salary)

% Private rent obtained from action

if incumbent == 1
    rent = 2 * rand(1) * (1 - (naMean + npMean)) * (2 * pi - 1) * salary;
else
    rent = 0;
end

end