function CPT = CPT_GoodNewsDelivered(na, np)

% Conditional Probability Table
% Media delivers good news given the nature of action, existance of
% anti-incumbent media bias and pro-incumbent media bias
% CPT{i}(HOA, AB, OB}
% i - ordinal number of media

CPT = reshape([1 - na, np, 1, np, 1 - na, 0, 1, 0], [2 2 2]);

end