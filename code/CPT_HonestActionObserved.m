function HOA = CPT_HonestActionObserved(pi)

% Conditional Probability Table
% Honest action observed by mass media given the nature of incumbent and
% nature of action
% CPT{HOA}(O, H)

HOA = reshape([pi, pi, 1 - pi, 0], [2 2]);

end