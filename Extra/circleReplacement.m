%% Replace the region by a filled circle
BWtemp = zeros(sz(1), sz(2));
if ~isempty(featuresGLCM)
    featuresIns = regionprops(BWglcm, img, {'Solidity', 'Extent', 'Eccentricity', 'EquivDiameter', 'WeightedCentroid'});
    numIns = numel(featuresIns);
    for count = 1:numIns
        shape = insertShape(BWtemp, 'FilledCircle', [featuresIns(count).WeightedCentroid, featuresIns(count).EquivDiameter/2],...
                        'Color', 'white', 'Opacity', 1);
        BWtemp = imfuse(BWtemp, shape);
    end
    if ~ismatrix(BWtemp)
        BWins = rgb2gray(BWtemp);
    else
        BWins = BWtemp;
    end
    BWins = imbinarize(BWins);
else
    BWins = BWglcm;
end
imshow(BWins);
vars.glcmCondition = {'count', 'index', 'str1', 'str2'};
clear(vars.glcmCondition{:});