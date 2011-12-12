function  makePie(X, labels, ptitle)
% Draws a pie for displaying Incumbent support in Local communities

% Drawing a pie
explode = zeros(size(X));
[~, offset] = max(X);
explode(offset) = 1;
h = pie(X, explode); 

colormap winter

textObjs = findobj(h, 'Type','text');
oldStr = get(textObjs, {'String'});
val = get(textObjs, {'Extent'});
oldExt = cat(1, val{:});

Names = labels;
newStr = strcat(Names, oldStr);
set(textObjs, {'String'}, newStr);

val1 = get(textObjs, {'Extent'});
newExt = cat(1, val1{:});
offset = sign(oldExt(:, 1)) .* (newExt(:, 3) - oldExt(:, 3)) / 2;
pos = get(textObjs, {'Position'});
textPos =  cat(1, pos{:});
textPos(:,1) = textPos(:, 1) + offset;
set(textObjs, {'Position'}, num2cell(textPos, [3, 2]));

title(ptitle, 'FontWeight', 'bold');
end
