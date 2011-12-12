function [adj, par, wei] = graphInitialization(numLocalCommunities, numVoters, ...
    numIntelligentVoters, numInfluencedVoters, numRegularVoters)
% GRAPH INITIALIZATION
% Adjacency list

% Number of nodes in Bayesian network
% Incumbent + his behaviour + Observed Action +
% Number of media/local communities + 2 * Bias of media + numVoters
N = 3 + 3 * sum(numLocalCommunities) + sum(numVoters);

% Initializing and connecting first two nodes
adj{N} = [];
adj{1} = [2, 3];
adj{2} = 3;

% Variable index offset
offset = 3;

% Initialization of local community by local community
for i = 1 : numLocalCommunities
    % Connecting Observed action with Media and Intelligent voters
    adj{3} = [adj{3}, offset + 1, offset + 4 : offset + 3 + numIntelligentVoters(i)];
    % Connecting Media with Influenced and Regular voters
    adj{offset + 1} = offset + 4 + numIntelligentVoters(i) : offset + 3 + numVoters(i);
    % Connecting Ethycal bias with Media
    adj{offset + 2} = offset + 1;
    % Connecting Opportunistic bias with Media
    adj{offset + 3} = offset + 1;
    
    % Randomizing connections of Intelligent voters to Influenced voters
    % while making sure that there every Influenced voters gets connected
    % to at least 1 Intelligent voter
    influences = rand(numIntelligentVoters(i), numInfluencedVoters(i));
    influences = influences > 0.9;
    while ~isempty(find(sum(influences) == 0, 1))
        correction = find(sum(influences) == 0, 1);
        influences(:, correction) = rand(numIntelligentVoters(i), 1) > 0.9;
    end
    
    % Connecting Intelligent voters to Influenced voters
    for j = 1 : numIntelligentVoters(i)
        adj{offset + 3 + j} = offset + 3 + numIntelligentVoters(i) + ... 
            find(influences(j, :) ~= 0);
    end
    
    % Shifting the offset
    offset = offset + 3 + numVoters(i);
end

% Determining the parenting relationships between nodes in Bayesian network
par{N} = [];
for i = 1 : N
    if ~isempty(adj{i})
        for j = 1 : size(adj{i}, 2)
            par{adj{i}(j)} = [par{adj{i}(j)} i];
        end
    end
end

% Initialize weights for Influenced voters
% Normalize weights to sum to 0.2
offset = 6;
wei{N} = [];
for i = 1 : size(numInfluencedVoters, 2)
    offset = offset + numIntelligentVoters(i);
    for j = 1 : numInfluencedVoters(i)
        wei{offset + j} = rand(1, size(par{offset + j}, 2));
        wei{offset + j}(1) = 0;
        wei{offset + j} = 0.2 * wei{offset + j} ./ sum(wei{offset + j});
    end
    offset = offset + numInfluencedVoters(i) + numRegularVoters(i) + 3;
end