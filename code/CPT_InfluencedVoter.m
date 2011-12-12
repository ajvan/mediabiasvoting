function CPT = CPT_InfluencedVoter(alpha, rent, na, np, pi, salary, personalW)

% Probability of Influenced voter voting for incumbent without influence of
% Intelligent voters
gamma = rent / ((1 - (na + np)) * (2 * pi - 1) * salary);
 
% Conditional probability table
% Influenced voter votes for incumbent given the nature of news reported by
% media
if rent >= (1 - (na + np)) * (2 * pi - 1) * salary
    CPT = [personalW, 0];
elseif rent == 0
        CPT = [1, 0];
else
    if alpha >= 0.5
        CPT = [personalW * gamma, 0];
    else
        CPT = [personalW, personalW * (1 - gamma)];
    end
end

end