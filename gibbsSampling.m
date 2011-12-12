function distribution = gibbsSampling(adj, par, wei, numIntelligentVoters, ...
    numInfluencedVoters, offset, CPTint, CPTinf, HOA, G)

% Number of samples for Gibbs sampling 
numSamples = 100;

% Determining the opposite decision
if G == 1
    NG = 2;
else
    NG = 1;
end

if HOA == 1
    DOA = 2;
else
    DOA = 1;
end

% Probability of each node
nodeProbability = 0.5;

% Randomizing the initial values for Intelligent and Influenced voters
votes = 1 + floor(rand(1, numIntelligentVoters + numInfluencedVoters) * 2);
votes = [votes ; zeros(numSamples - 1, numIntelligentVoters + numInfluencedVoters)];
votes = int8(votes);

% GIBBS SAMPLING
for i = 2 : numSamples
    
    for j = 1 : numIntelligentVoters
        % For each intelligent voter read it's children nodes
        influenced = adj{offset + j};
        % Initializing the arrays for conditional probabilities of child
        % nodes
        influencedForIncumbent = ones(1, size(influenced, 2));
        influencedNotIncumbent = ones(1, size(influenced, 2));
        
        % For each child
        for k = 1 : size(influenced, 2)
            % Observe it's parent node - Intelligent voters
            influences = par{influenced(k)};
            % Observe influence weights
            weights = wei{influenced(k)};
            
            % Read initial probability from Conditional probability table
            % for influenced voters
            probabilityIncumbent = CPTinf(G);
            probabilityNotIncumbent = CPTinf(NG);
            
            % For each Influence if decision is to vote for Incumbent then
            % add the influence. Otherwise, subtract it
            for l = 2 : size(influences, 2)
               if votes(i - 1, influences(l) - offset) == 1
                   probabilityIncumbent = probabilityIncumbent + weights(l);
                   
                   if influences(l) - offset == j
                       probabilityNotIncumbent = probabilityNotIncumbent + weights(l);
                   else
                       probabilityNotIncumbent = probabilityNotIncumbent - weights(l);
                   end
               else
                   probabilityIncumbent = probabilityIncumbent - weights(l);
                   
                   if influences(l) - offset == j
                       probabilityNotIncumbent = probabilityNotIncumbent - weights(l);
                   else
                       probabilityNotIncumbent = probabilityNotIncumbent + weights(l);
                   end
               end
            end
            
            % Corrections
            if probabilityIncumbent < 0
                probabilityIncumbent = 0;
            end
            
            if probabilityIncumbent > 1
                probabilityIncumbent = 1;
            end
            
            if probabilityNotIncumbent < 0
                probabilityNotIncumbent = 0;
            end
            
            if probabilityNotIncumbent > 1
                probabilityNotIncumbent = 1;
            end
            
            % Put the corresponding probabilities into array for
            % conditional probabilities
            influencedForIncumbent(k) = probabilityIncumbent;
            influencedNotIncumbent(k) = probabilityNotIncumbent;
        end
        
        % Calculating the approximated probability of Intelligent voter voting for
        % incumbent
        probability = nodeProbability * CPTint(HOA) * ...
            prod(influencedForIncumbent);
        marginalization = nodeProbability * CPTint(HOA) * ...
            prod(influencedForIncumbent) + (1 - nodeProbability) * CPTint(DOA) * ...
            prod(influencedNotIncumbent);
        probability = probability / marginalization;
        
        % Observing the Intelligent voter's vote
        sample = rand(1);
        if sample < probability
            votes(i, j) = 1;
        else
            votes(i, j) = 2;
        end
    end
    
    % Shifting the offset
    infOffset = offset + numIntelligentVoters;
    
    % For each Influenced voter
    for j = 1 : numInfluencedVoters
        % Observe it's parent node - Intelligent voters
        influences = par{infOffset + j};
        % Observe influence weights
        weights = wei{infOffset + j};
        % Read initial probability from Conditional probability table
        % for influenced voters
        probabilityIncumbent = CPTinf(G);
        
        % For each Influence if decision is to vote for Incumbent then
        % add the influence. Otherwise, subtract it
        for l = 2 : size(influences, 2)
            if votes(i, influences(l) - offset) == 1
               probabilityIncumbent = probabilityIncumbent + weights(l);
            else
               probabilityIncumbent = probabilityIncumbent - weights(l);
           end
        end
                
        % Observing the Influenced voter's vote
        sample = rand(1);
        if sample < probabilityIncumbent
            votes(i, j + numIntelligentVoters) = 1;
        else
            votes(i, j + numIntelligentVoters) = 2;
        end     
    end
    
end

distribution = sum(votes == 1) / 100;

end