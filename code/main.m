display('----------------------------------------------------------');
display('MEDIA BIAS AND VOTING');
display('by I. Jovanovic, C. Lataniotis, F. Perazzi, A. Vouzas');
display('----------------------------------------------------------');

clear;
again = 'y';

while strcmp(again, 'y') || strcmp(again, 'Y')
    clear;
    display(' ');
    % Reading the number of Local communities
    reply = input('Insert the number of Local communities (2-5)? ', 's');
    numLocalCommunities = str2double(reply);
    while isnan(numLocalCommunities) || numLocalCommunities < 2 || ... 
            numLocalCommunities > 5
        reply = input('Insert the number of Local communities (2-5)? ', 's');
        numLocalCommunities = str2double(reply);
    end

    % Reading the upper bound on number of voters in Local community
    reply = input(['Insert the upper bound of voters in of Local communities',...
        '(300<bound<4000)? '], 's');
    upperBound = str2double(reply);
    while isnan(upperBound) || upperBound < 300 || upperBound > 4000
         reply = input(['Insert the upper bound of voters in of Local communities',...
        '(300<bound<4000)? '], 's');
        upperBound = str2double(reply);
    end

    % Reading the Incumbent's nature
    reply = input('Insert the nature of Incumbent (O/E)? ', 's');
    while ~strcmp(reply, 'e') && ~strcmp(reply, 'E') && ~strcmp(reply, 'o') ...
            && ~strcmp(reply, 'O')
        reply = input('Insert the nature of Incumbent (O/E)? ', 's');
    end
    if strcmp(reply, 'e') || strcmp(reply, 'E')
       incumbent = 0.5 + 0.5 * rand(1);
       alpha = 0.5 * rand(1);
    else
        incumbent = 0.5 * rand(1);
        alpha = 0.5 + 0.5 * rand(1);
    end

    % Probability that mass media observing true nature of incumbent's action
    pi = piInitialization(alpha);

    % Reading the nature of media bias
    % Probabilities that media misreport news as "good" or "bad"
    % na - anti-incumbent bias
    % np - pro-incumbent bias
    display('Insert the nature of media bias');
    reply = input(['Anti-Incumbent, Pro-Incumbent, Media bias in both ', ...
        'directions (A/P/B)? '], 's');
    while ~strcmp(reply, 'a') && ~strcmp(reply, 'A') && ~strcmp(reply, 'p') && ...
            ~strcmp(reply, 'P') && ~strcmp(reply, 'b') && ~strcmp(reply, 'B')
        reply = input(['Anti-Incumbent, Pro-Incumbent, Media bias in both ', ...
        'directions (A/P/B)? '], 's');
    end
    if strcmp(reply, 'a') || strcmp(reply, 'A')
       type = 1;
    elseif strcmp(reply, 'p') || strcmp(reply, 'P')
        type = 2;
    else
        type = 3;
    end
    
    amount = input('Insert the amount of media bias (H/L)? ', 's');
    while ~strcmp(amount, 'h') && ~strcmp(amount, 'H') && ~strcmp(amount, 'l') ...
            && ~strcmp(amount, 'L')
        amount = input('Insert the amount of media bias (H/L)? ', 's');
    end
    if strcmp(reply, 'l') || strcmp(reply, 'L')
       amount = 1;
    else
        amount = 2;
    end
    
    [na, np] = mediaBiasInitialization(numLocalCommunities, type, amount);
    
    % Reading the number of Incumbent's actions
    reply = input('Insert the number of Incumbent''s actions? ', 's');
    numActions = str2double(reply);
    while isnan(numActions) || numActions <= 0
        reply = input('Insert the number of Incumbent''s actions? ', 's');
        numActions = str2double(reply);
    end
    
    % STARTING THE ELECTION PROCESS
    result = elections(numLocalCommunities, upperBound, incumbent, ...
    alpha, pi, na, np, numActions);
    
    % Another simulation?
    again = input('Another simulation (Y/N) [enter:N]? ', 's');
    if isempty(again)
        again = 'n';
    end
    while ~strcmp(again, 'y') && ~strcmp(again, 'Y') && ~strcmp(again, 'n') ...
            && ~strcmp(again, 'N')
        again = input('Another simulation (Y/N) [enter:N]? ', 's');
    end
end