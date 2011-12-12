function pi = piInitialization(alpha)

% Probability that mass media observing true nature of incumbent's action
% pi e [0.5, 1]
% alpha >= 0.5 -> pi > alpha
% alpha < 0.5 -> pi > 1 - alpha

pi = 0.5 + rand(1) * 0.5;
if alpha >= 0.5
    while pi <= alpha
        pi = 0.5 + rand(1) * 0.5;
    end
else
    while pi <= 1 - alpha
        pi = 0.5 + rand(1) * 0.5;
    end
end

end