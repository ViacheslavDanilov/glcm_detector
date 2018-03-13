img = x101_skel;
features = regionprops(img, {'Centroid', 'BoundingBox', 'Extrema'});
scrSz = get(0, 'Screensize');
num = numel(features);
%%
hold on;
imshow(img, 'InitialMagnification', 'fit');
for count = 1:num
    rectangle('Position', features(count).BoundingBox, 'EdgeColor','c');
    plot(features(count).Centroid(1), features(count).Centroid(2), 'go');
    posX = features(count).Extrema(1,1) - 3;
    posY = features(count).Extrema(1,2) - 3;
    str = sprintf("%d", count);
    text(posX, posY, char(str), 'FontSize', 14, 'FontName', 'Times New Roman', 'Color', 'g');
end
set(gcf, 'Position', scrSz, 'Color', 'w');
hold off;
%%
imtool(img)

