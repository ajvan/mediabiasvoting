function  makeBars( X, labels, ptitle)
% Draws a bars for displaying the statistics about Incumbent's mandate

% Drawing bars
bar(X);
title(ptitle, 'FontWeight','bold');
set(gca, 'XTickLabel', labels);
ylabel('%');

end

