function CPT = CPT_RegularVoter(alpha, rent, na, np, pi, salary)

% Probability of Regular voter voting for incumbent
gamma = rent / ((1 - (na + np)) * (2 * pi - 1) * salary);
 
% Conditional probability table
% Regular voter votes for incumbent given the nature of news reported by
% media
if rent >= (1 - (na + np)) * (2 * pi - 1) * salary
    CPT = [1, 0];
elseif rent == 0
    CPT = [1, 0];
else
    if alpha >= 0.5
        CPT = [gamma, 0];
    else
        CPT = [1, 1 - gamma];
    end
end

end