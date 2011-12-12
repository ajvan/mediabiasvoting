function result = elections(numLocalCommunities, upperBound, incumbent, ...
    alpha, pi, na, np, numActions)
%% INITIALIZATIONS

% Number of Voters per community without members of political parties (1-10000)
numVoters = 1 + floor(rand(1, numLocalCommunities) * upperBound);
% Number of Intelligent voters per community (~<10%)
numIntelligentVoters = 1 + floor(numVoters .* (rand(1, numLocalCommunities) * 0.1));
% Number of Influenced voters per community (~<30%)
numInfluencedVoters = 1 + floor(numVoters .* (rand(1, numLocalCommunities) * 0.3));
% Number of Regular voters per community (the difference)
numRegularVoters = numVoters - numIntelligentVoters - numInfluencedVoters;

% Number of members of Incumbent's political party
incumbentMembers = 1 + floor(numVoters .* (rand(1, numLocalCommunities) * 0.2));
% Number of members of Challenger's political party
challengerMembers = 1 + floor(numVoters .* (rand(1, numLocalCommunities) * 0.1));

% Total number of voters
% Number of voters + Members of political parties + Incumbent + Challenger
totalVoters = sum(numVoters) + sum(incumbentMembers) + sum(challengerMembers) + 2;

% Displaying the input parameters
display(['There are ' num2str(numLocalCommunities) ' local communities.']);
display(['There are ' num2str(totalVoters) ' voters.']);
display(['There are ' num2str(sum(numIntelligentVoters)) ' intelligent voters.']);
display(['There are ' num2str(sum(numInfluencedVoters)) ' influenced voters.']);
display(['There are ' num2str(sum(numRegularVoters)) ' regular voters.']);
display(['There are ' num2str(sum(incumbentMembers)) ' members of Incumbent''s party.']);
display(['There are ' num2str(sum(challengerMembers)) ' members of Challenger''s party.']);
display(' ');

% Number of nodes in Bayesian network
% Incumbent + his behaviour + Observed Action +
% Number of media/local communities + 2 * Bias of media + numVoters
N = 3 + 3 * sum(numLocalCommunities) + sum(numVoters);

% Probability that incumbent is opportunistic
beta = 0.5;

% Mean values of media bias
naMean = mean(na);
npMean = mean(np);

% Incumbent's salary in CHF (20000-40000) 
salary = 20000 + floor(rand(1) * 300) * 100;

% Weight for personal vote of Regular voter
personalW = 0.8;

% Number of actions done by incumbent
display(['The number of actions is ' num2str(numActions) '.']);
display(' ');

% Number of honest and dishonest actions done by Incumbent
honestActions = 0;
dishonestActions = 0;

% Number of Incumbent actions observed as honest or dishonest
honestActionsObserved = 0;
dishonestActionsObserved = 0;

% Number of good and bad news reported by each media
goodNewsReported = zeros(1, numLocalCommunities);
badNewsReported = zeros(1, numLocalCommunities);

%% GRAPH INITIALIZATION
[adj, par, wei] = graphInitialization(numLocalCommunities, numVoters, ...
    numIntelligentVoters, numInfluencedVoters, numRegularVoters);

%% CONDITIONAL PROBABILITY TABLES - BAYESIAN VARIABLE ENUMERATION
O = 1; % Incumbent is opportunistic
H = 2; % Incumbent choosing honest behaviour
HOA = 3; % Honest action observed by mass media
G = 4; % Media delivers good news

%% CONDITIONAL PROBABILITY TABLES
% Independent from the incumbent's behaviour
% 1 corresponds to TRUE, 2 corresponds to FALSE

% Conditional Probability Table
% Honest action observed by mass media given the nature of incumbent and
% nature of action
% CPT{HOA}(O, H)
CPT{HOA} = CPT_HonestActionObserved(pi);

% Dishonest action observed by mass media given the nature of incumbent and
% nature of action
% 1 - CPT{HOA}

% Conditional Probability Table
% Media delivers good news given the nature of action, existance of
% anti-incumbent media bias and pro-incumbent media bias
% CPT{i}(HOA, AB, OB}
% i - ordinal number of media
offset = 3;
for i = 1 : numLocalCommunities
    CPT{offset + 1} = CPT_GoodNewsDelivered(na(i),np(i));
    offset = offset + 3 + numVoters(i);
end

% Media delivers bad news given the nature of action, existance of
% anti-incumbent media bias and pro-incumbent media bias
% 1 - CPT{i}(HOA, AB, OB}
% i - ordinal number of media

%% OBSERVING VARIABLES
evidence{N} = [];

% Observing the incumbent's nature
if incumbent < beta
    evidence{1} = 1;
    display('Incumbent''s nature: OPPORTUNISTIC.');
else
    evidence{1} = 2;
    display('Incumbent''s nature: ETHICAL.');
end

% Observing the challenger's nature
if alpha >= 0.5
    display('Challenger''s nature: ETHICAL.');
else
    display('Challenger''s nature: OPPORTUNISTIC.');
end
display(' ');

% Observing the Anti-incumbent bias and Pro-incumbent bias
offset = 3;
for i = 1 : numLocalCommunities
    % Observe anti-incumbent bias
    if na(i) > 0
        evidence{offset + 2} = 1;
        display(['Media ' num2str(i) ' has Anti-incumbent bias in amount ' ...
            num2str(na(i) * 100) '%.']);
    else
        evidence{offset + 2} = 2;
        display(['Media ' num2str(i) ' does not have Anti-incumbent bias.']);
    end

    % Observe pro-incumbent bias
    if np(i) > 0
        evidence{offset + 3} = 1;
        display(['Media ' num2str(i) ' has Pro-incumbent bias in amount ' ...
            num2str(np(i) * 100) '%.']);
    else
        evidence{offset + 3} = 2;
        display(['Media ' num2str(i) ' does not have Pro-incumbent bias.']);
    end
    
    offset = offset + 3 + numVoters(i);
end
display(' ');

% Conditional Probability Table
% Initializing the number of Conditional probability tables for Regular
% voters
CPTreg{numLocalCommunities} = [];
CPTinf{numLocalCommunities} = [];

%% THE SIMULATION LOOP

% Counting the number of times a voter decided to vote for incumbent after
% receiving a news from media
individualVotes = int32(zeros(1, N));

for t = 1 : numActions   
    % Private rent obtained from action
    rent = rentFromAction(evidence{1}, naMean, npMean, pi, salary);

    % Probability of opportunistic incumbent chosing a dishonest action
    sigma = sigmaCalculation(evidence{1}, alpha, rent, naMean, npMean, pi, salary);
    
    % Conditional Probability Table
    % Incumbent chooses honest behaviour given the nature of incumbent
    % CPT{H}(O)
    CPT{H} = CPT_HonestBehaviour(rent, naMean, npMean, pi, salary, sigma);

    % Incumbent chooses dishonest behaviour given the nature of incumbent
    % 1 - CPT{H}(O)
    
    % Observing the incumbents behaviour
    sample = rand(1);
    if sample < CPT{H}(evidence{O})
        evidence{H} = 1;
        % display(['Incumbent''s behavior ' num2str(t) ' is: HONEST.']);
        honestActions = honestActions + 1;
    else
        evidence{H} = 2;
        % display(['Incumbent''s behavior ' num2str(t) ' is: DISHONEST.']);
        dishonestActions = dishonestActions + 1;
    end
    
    % Observing the nature of observed action
    sample = rand(1);
    if sample < CPT{HOA}(evidence{O}, evidence{H})
        evidence{HOA} = 1;
        % display(['Incumbent''s behavior ' num2str(t) ' is observed as: HONEST.']);
        honestActionsObserved = honestActionsObserved + 1;
    else
        evidence{HOA} = 2;
        % display(['Incumbent''s behavior ' num2str(t) ' is observed as: DISHONEST.']);
        dishonestActionsObserved = dishonestActionsObserved + 1;
    end
  
    % Observing the Media delivers good news
    offset = 3;
    for i = 1 : numLocalCommunities
        sample = rand(1);
        if sample < CPT{offset + 1}(evidence{HOA}, evidence{offset + 2}, ...
                evidence{offset + 3})
            evidence{offset + 1} = 1;
            % display(['After Incumbent''s behavior ' num2str(t) ' Media ' ...
                % num2str(i) ' delivers GOOD NEWS.']);
            goodNewsReported(i) = goodNewsReported(i) + 1;
        else
            evidence{offset + 1} = 2;
            % display(['After Incumbent''s behavior ' num2str(t) ' Media ' ...
                % num2str(i) ' delivers BAD NEWS.']);
            badNewsReported(i) = badNewsReported(i) + 1;
        end

        offset = offset + 3 + numVoters(i);
    end
    
    % Conditional Probability Table
    % Intelligent voter votes for incumbent given the nature of action observed
    % by mass media - unbiased information
    % CPTint(OHA)
    CPTint = CPT_IntelligentVoter(alpha, rent, pi, salary);
    
    % Intelligent voter votes for challenger given the nature of action observed
    % by mass media - unbiased information
    % 1 - CPTint{j}(OHA), j - ordinal number of Intelligent voter 
      
    % Conditional Probability Table
    % Influenced voter votes for incumbent given the nature of news reported by
    % media without influence of Intelligent voters 
    % CPTinf{i}(G)
    % i - ordinal number of Media
    for i = 1 : numLocalCommunities 
        CPTinf{i} = CPT_InfluencedVoter(alpha, rent, na(i), np(i), pi, salary, personalW);
    end
    
    % Influenced voter votes for challenger given the nature of news reported by
    % media without influence of Intelligent voters 
    % 1 - CPTinf{i}(G)
    % i - ordinal number of Media
    
    % Conditional probability table
    % Regular voter votes for incumbent given the nature of news reported by
    % media
    % CPTreg{i}
    % i - ordinal number of Media
    for i = 1 : numLocalCommunities 
        CPTreg{i} = CPT_RegularVoter(alpha, rent, na(i), np(i), pi, salary);
    end
    
    % Regular voter votes for challenger given the nature of news reported by
    % media
    % 1 - CPTreg{i}
    % j - ordinal number of Media
        
    %%  VOTING
    offset = 6;
    for i = 1 : numLocalCommunities
       
        % GIBBS SAMPLING FOR INFLUENCED AND INTELLIGENT
        distribution = gibbsSampling(adj, par, wei, numIntelligentVoters(i), ...
        numInfluencedVoters(i), offset, CPTint, CPTinf{i}, evidence{HOA}, evidence{G});

        % Observing the votes from Intelligent and Influenced voters
        for j = 1 : numIntelligentVoters(i) + numInfluencedVoters(i)
           sample = rand(1);
           if sample < distribution(j)
               evidence{offset + j} = 1;
               individualVotes(offset + j) = individualVotes(offset + j) + 1;
           else               evidence{offset + j} = 2;
           end
        end        
        
        % Voting for regular voters
        offset = offset + numIntelligentVoters(i) + numInfluencedVoters(i);
        for j = 1 : numRegularVoters(i)
            sample = rand(1);
            if sample < CPTreg{i}(evidence{offset - 2 - numIntelligentVoters(i) ...
                    - numInfluencedVoters(i)})
                evidence{offset + j} = 1;
                individualVotes(offset + j) = individualVotes(offset + j) + 1;
            else
                evidence{offset + j} = 2;
            end
        end
        
        offset = offset + numRegularVoters(i) + 3;
    end
    
    %%  SIMULATION 
    % Calculating pie data
    supportForIncumbent = sum(individualVotes > 0.5 * t);
    supportForIncumbent = 100 * (supportForIncumbent + sum(incumbentMembers))...
            / totalVoters;
    supportForChallenger = 100 - supportForIncumbent;
    pie = [supportForIncumbent, supportForChallenger];

    % Calculating bar data 
    honestActionsUntilNow = 100 * honestActions / t;
    dishonestActionsUntilNow = 100 - honestActionsUntilNow;
    honestActionsObservedUntilNow = 100 * honestActionsObserved / t;
    dishonestActionsObservedUntilNow = 100 - honestActionsObservedUntilNow;
    goodNewsReportedUntilNow = 100 * sum(goodNewsReported) / (t * numLocalCommunities);
    badNewsReportedUntilNow = 100 - goodNewsReportedUntilNow;
    bars = [honestActionsUntilNow, dishonestActionsUntilNow; ...
        honestActionsObservedUntilNow, dishonestActionsObservedUntilNow; ...
        goodNewsReportedUntilNow, badNewsReportedUntilNow];
         
    % Displaying the simulation
    figure(1)
    subplot(2,1,1), makePie(pie,{['Voting for Incumbent', 10]; ...
        ['Voting for Challenger', 10]}, ...
        ['SUPPORT FOR INCUMBENT IN LOCAL COMMUNITIES', 10, 'AT TIME ', num2str(t)]),
    subplot(2,1,2), makeBars(bars, {'Incumbent''s behavior (Honest / Dishonest)'; ...
        'Behaviors observed by Mass Media (Honest / Dishonest)'; ...
        'News reported by Local media (Good / Bad)'}, ...
        ['INCUMBENT''S MANDATE STATISTICS, \mu(\eta_a)=', num2str(100 * naMean), ...
        '%, \mu(\eta_p)=', num2str(100 *npMean), '%'])
    set(gcf, 'Position', get(0,'Screensize'));
end

%% DISPLAYING THE ELECTION RESULTS
display(' ');

% Displaying the statistics about Incumbent's mandate
display(['During his mandate Incumbent had ' num2str(honestActions) ...
    ' honest behaviors.']);
display(['During his mandate Incumbent had ' num2str(dishonestActions) ...
    ' dishonest behaviors.']);
display(' ');

% Displaying the statistics about number of observed actions
display(['Media observed ' num2str(honestActionsObserved) ...
    ' Incumbent''s behaviors as honest.']);
display(['Media observed ' num2str(dishonestActionsObserved) ...
    ' Incumbent''s behaviors as dishonest.']);
display(' ');

% Displaying the number of good and bad news delivered by local media
for i = 1 : numLocalCommunities
    display(['Local media ' num2str(i) ' delivered ' num2str(goodNewsReported(i)) ...
        ' good news, and ' num2str(badNewsReported(i)) ' bad news.']);
end
display(' ');

% COUNT THE VOTES, CALCULATE THE RESULT
% Summing all the votes
votingForIncumbent = (individualVotes > 0.5 * numActions);
votesForIncumbent = sum(votingForIncumbent) + sum(incumbentMembers) + 1;

% Displaying the number of votes for Incumbent
display(['After elections Incumbent got ' num2str(votesForIncumbent) ...
    ' votes or ' num2str(100 * votesForIncumbent/totalVoters) '%.']);
display(' ');

% Displaying the final election results
if votesForIncumbent/totalVoters > 0.5
    display('INCUMBENT GOT REELECTED!');
elseif votesForIncumbent/totalVoters == 0.5
    display('IT WAS A TIE!');
else
    display('INCUMBENT LOST THE ELECTIONS!');
end
display(' ');

result = votesForIncumbent/totalVoters;

end