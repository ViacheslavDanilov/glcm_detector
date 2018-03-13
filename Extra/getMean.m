BWstd = BWarea; 
featuresStd = regionprops(BWstd, img, {'Centroid','Extrema','PixelValues','BoundingBox', 'WeightedCentroid'});
numStd = numel(featuresStd); 
imshowpair(BWstd, img, 'montage');
addTitle('Mean and Standard deviation of regions');
pmSymbol = char(177);
hold on
for count = 1 : numStd
    featuresStd(count).StandardDeviation = std(double(featuresStd(count).PixelValues));
    featuresStd(count).Mean = mean(double(featuresStd(count).PixelValues));
%     rectangle('Position', featuresStd(count).BoundingBox,'EdgeColor', 'c');
    posX = featuresStd(count).Extrema(1,1) - 4;
    posY = featuresStd(count).Extrema(1,2) - 3;
    str = sprintf("%d: %d%s%d", count, round(featuresStd(count).Mean,0), pmSymbol, round(featuresStd(count).StandardDeviation, 0));
    text(posX, posY, char(str), 'FontSize', 10, 'FontName', 'Times New Roman', 'Color', 'g');
end
set(gcf, 'Position', scrSz, 'Color', 'w');
hold off
vars.stdCalc = {'index', 'str1', 'str2', 'count', 'posX', 'posY', 'str'};
clear(vars.stdCalc{:});