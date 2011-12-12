function [na, np] = mediaBiasInitialization(numLocalCommunities, type, amount)

% Probabilities that media misreport news as "good" or "bad"
% na - anti-incumbent bias
% np - pro-incumbent bias
% na + np <= 1

% type = 1, Anti-incumbent bias
% type = 2, Pro-incumbent bias
% type = 3, Media bias in both directions

na = rand(1, numLocalCommunities);
np = rand(1, numLocalCommunities);

if amount == 1
    na = 0.2 * na;
    np = 0.2 * np;
elseif amount == 2
    na = 0.5 * na + 0.2;
    np = 0.5 * np + 0.2;
end

if type == 1
    np = zeros(1, numLocalCommunities);
elseif type == 2
    na = zeros(1, numLocalCommunities);
end

% SATISFYING CONSTRAINTS
for i = 1 : numLocalCommunities
       while na(i) + np(i) > 1
            na(i) = rand(1);
            np(i) = rand(1);

            if amount == 1
                na(i) = 0.2 * na(i);
                np(i) = 0.2 * np(i);
            elseif amount == 2
                na(i) = 0.5 * na(i) + 0.2;
                np(i) = 0.5 * np(i) + 0.2;
            end
            
            if type == 1
                np(i) = 0;
            elseif type == 2
                na(i) = 0;
            end
        end
end
   
end