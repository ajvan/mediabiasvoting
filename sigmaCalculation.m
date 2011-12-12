function sigma = sigmaCalculation(incumbent, alpha, rent, naMean, npMean, pi, salary)

% Probability of opportunistic incumbent chosing a dishonest action
if incumbent == 1  
    if alpha >= 0.5
       if rent < (1 - (naMean + npMean)) * (2 * pi - 1) * salary
           sigma = (2 * alpha - 1) * (1 - naMean) * pi + npMean * (1 - pi);
           sigma = sigma / ((1 - (naMean + npMean)) * (2 * pi - 1) * alpha);
           sigma = sigma * 0.3;
       else
           sigma = 1;
       end
    else
       if rent < (1 - (naMean + npMean)) * (2 * pi - 1) * salary
           sigma = (1 - 2 * alpha) * ((1 - npMean) * (1 - pi) + naMean * pi);
           sigma = sigma / ((1 - (naMean + npMean)) * (2 * pi - 1) * alpha);
           sigma = sigma * 0.3;
       else
           sigma = 1;
       end
    end
else
    sigma = 0;
end

end