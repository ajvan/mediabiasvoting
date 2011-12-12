function CPT = CPT_IntelligentVoter(alpha, rent, pi, salary)

% Conditional Probability Table
% Intelligent voter votes for incumbent given the nature of action observed
% by mass media - unbiased information

% Probability of Intelligent voter voting for incumbent
omega = rent / ((2 * pi - 1) * salary);

% Conditional probability table

if rent >= (2 * pi - 1) * salary
    CPT = [1, 0];
elseif rent == 0
    CPT = [1, 0];
else
    if alpha >= 0.5
        CPT = [omega, 0];
    else
        CPT = [1, 1 - omega];
    end
end

end