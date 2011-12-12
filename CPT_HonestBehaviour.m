function CPT = CPT_HonestBehaviour(rent, naMean, npMean, pi, salary, sigma)

% Conditional Probability Table
% Incumbent chooses honest behaviour given the nature of incumbent

if rent < (1 - (naMean + npMean)) * (2 * pi - 1) * salary
            CPT = [1 - sigma, 1];
    else
            CPT = [0, 1];
end

end